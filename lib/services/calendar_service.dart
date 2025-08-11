import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final String calendarId;
  final bool canCreateFocusSession;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.start,
    required this.end,
    required this.calendarId,
    required this.canCreateFocusSession,
  });

  Duration get duration => end.difference(start);
  
  bool get isUpcoming => start.isAfter(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(start.year, start.month, start.day);
    return today == eventDay;
  }
}

class FocusBlock {
  final String id;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final String? description;
  final String? projectId;
  
  FocusBlock({
    required this.id,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    this.description,
    this.projectId,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));
  
  Event toCalendarEvent(String calendarId) {
    final utc = tz.UTC;
    return Event(
      calendarId,
      title: '🎯 $title',
      description: description ?? 'FlowPulse focus session',
      start: tz.TZDateTime.from(startTime, utc),
      end: tz.TZDateTime.from(endTime, utc),
    );
  }
}

enum CalendarIntegrationStatus {
  disabled,
  permissionDenied,
  noCalendarsFound,
  enabled,
  syncing,
  error,
}

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  
  List<Calendar> _availableCalendars = [];
  String? _selectedCalendarId;
  CalendarIntegrationStatus _status = CalendarIntegrationStatus.disabled;
  
  // Settings
  bool _autoCreateFocusBlocks = false;
  bool _syncWithCalendar = false;
  int _defaultFocusBlockDuration = 25; // minutes
  List<String> _focusKeywords = ['focus', 'deep work', 'coding', 'writing', 'study'];

  // Getters
  List<Calendar> get availableCalendars => _availableCalendars;
  String? get selectedCalendarId => _selectedCalendarId;
  CalendarIntegrationStatus get status => _status;
  bool get autoCreateFocusBlocks => _autoCreateFocusBlocks;
  bool get syncWithCalendar => _syncWithCalendar;
  int get defaultFocusBlockDuration => _defaultFocusBlockDuration;

  /// Initialize calendar service
  Future<bool> initialize() async {
    try {
      _status = CalendarIntegrationStatus.syncing;
      
      // Request calendar permissions
      final permissionStatus = await _requestCalendarPermissions();
      if (!permissionStatus) {
        _status = CalendarIntegrationStatus.permissionDenied;
        return false;
      }

      // Retrieve available calendars
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        _availableCalendars = calendarsResult.data!
            .where((calendar) => !calendar.isReadOnly!)
            .toList();
        
        if (_availableCalendars.isEmpty) {
          _status = CalendarIntegrationStatus.noCalendarsFound;
          return false;
        }

        _status = CalendarIntegrationStatus.enabled;
        return true;
      } else {
        _status = CalendarIntegrationStatus.error;
        return false;
      }
    } catch (e) {
      _status = CalendarIntegrationStatus.error;
      debugPrint('Calendar initialization error: $e');
      return false;
    }
  }

  /// Request calendar permissions
  Future<bool> _requestCalendarPermissions() async {
    final status = await Permission.calendar.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.calendar.request();
      return result.isGranted;
    }
    
    return false;
  }

  /// Set the selected calendar for focus block creation
  Future<void> setSelectedCalendar(String calendarId) async {
    if (_availableCalendars.any((cal) => cal.id == calendarId)) {
      _selectedCalendarId = calendarId;
      await _saveSettings();
    }
  }

  /// Enable/disable sync with calendar
  Future<void> setSyncEnabled(bool enabled) async {
    _syncWithCalendar = enabled;
    await _saveSettings();
    
    if (enabled && _status != CalendarIntegrationStatus.enabled) {
      await initialize();
    }
  }

  /// Enable/disable auto-creation of focus blocks
  Future<void> setAutoCreateFocusBlocks(bool enabled) async {
    _autoCreateFocusBlocks = enabled;
    await _saveSettings();
  }

  /// Set default focus block duration
  Future<void> setDefaultFocusBlockDuration(int minutes) async {
    _defaultFocusBlockDuration = minutes;
    await _saveSettings();
  }

  /// Get upcoming calendar events for the next few days
  Future<List<CalendarEvent>> getUpcomingEvents({int daysAhead = 7}) async {
    if (!_syncWithCalendar || _status != CalendarIntegrationStatus.enabled) {
      return [];
    }

    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: daysAhead));
      
      final events = <CalendarEvent>[];
      
      for (final calendar in _availableCalendars) {
        final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id!,
          RetrieveEventsParams(
            startDate: now,
            endDate: endDate,
          ),
        );

        if (eventsResult.isSuccess && eventsResult.data != null) {
          for (final event in eventsResult.data!) {
            if (event.start != null && event.end != null) {
              events.add(CalendarEvent(
                id: event.eventId!,
                title: event.title ?? 'Untitled Event',
                description: event.description,
                start: event.start!.toLocal(),
                end: event.end!.toLocal(),
                calendarId: calendar.id!,
                canCreateFocusSession: _canCreateFocusSession(event),
              ));
            }
          }
        }
      }

      // Sort by start time
      events.sort((a, b) => a.start.compareTo(b.start));
      return events;
    } catch (e) {
      debugPrint('Error retrieving calendar events: $e');
      return [];
    }
  }

  /// Get today's calendar events
  Future<List<CalendarEvent>> getTodayEvents() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    final allEvents = await getUpcomingEvents(daysAhead: 1);
    return allEvents.where((event) => event.isToday).toList();
  }

  /// Create a focus block in the calendar
  Future<bool> createFocusBlock(FocusBlock focusBlock) async {
    if (_selectedCalendarId == null || _status != CalendarIntegrationStatus.enabled) {
      return false;
    }

    try {
      final event = focusBlock.toCalendarEvent(_selectedCalendarId!);
      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return result?.isSuccess ?? false;
    } catch (e) {
      debugPrint('Error creating focus block: $e');
      return false;
    }
  }

  /// Suggest focus times based on calendar availability
  Future<List<DateTime>> suggestFocusTimes({
    DateTime? date,
    int durationMinutes = 25,
    int maxSuggestions = 5,
  }) async {
    date ??= DateTime.now();
    final suggestions = <DateTime>[];
    
    if (!_syncWithCalendar || _status != CalendarIntegrationStatus.enabled) {
      // Return default suggestions if calendar not available
      return _getDefaultFocusTimes(date, maxSuggestions);
    }

    try {
      // Get events for the day
      final startOfDay = DateTime(date.year, date.month, date.day, 9); // 9 AM
      final endOfDay = DateTime(date.year, date.month, date.day, 18); // 6 PM
      
      final dayEvents = await _getEventsForDay(date);
      
      // Find gaps between events
      final gaps = _findFreeTimeSlots(dayEvents, startOfDay, endOfDay);
      
      // Convert gaps to focus time suggestions
      for (final gap in gaps) {
        if (gap.duration >= Duration(minutes: durationMinutes)) {
          // Suggest multiple times within longer gaps
          DateTime currentTime = gap.start;
          while (currentTime.add(Duration(minutes: durationMinutes)).isBefore(gap.end) &&
                 suggestions.length < maxSuggestions) {
            if (currentTime.isAfter(DateTime.now())) {
              suggestions.add(currentTime);
            }
            currentTime = currentTime.add(const Duration(hours: 1));
          }
        }
        
        if (suggestions.length >= maxSuggestions) break;
      }

      return suggestions.take(maxSuggestions).toList();
    } catch (e) {
      debugPrint('Error suggesting focus times: $e');
      return _getDefaultFocusTimes(date, maxSuggestions);
    }
  }

  /// Check if an event is suitable for creating a focus session
  bool _canCreateFocusSession(Event event) {
    if (event.title == null) return false;
    
    final title = event.title!.toLowerCase();
    final description = event.description?.toLowerCase() ?? '';
    
    // Check for focus-related keywords
    for (final keyword in _focusKeywords) {
      if (title.contains(keyword) || description.contains(keyword)) {
        return true;
      }
    }
    
    // Check duration (sessions longer than 30 minutes might be good for focus)
    final duration = event.end?.difference(event.start ?? DateTime.now());
    return duration != null && duration.inMinutes >= 30;
  }

  /// Get events for a specific day
  Future<List<CalendarEvent>> _getEventsForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final events = <CalendarEvent>[];
    
    for (final calendar in _availableCalendars) {
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(
          startDate: startOfDay,
          endDate: endOfDay,
        ),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        for (final event in eventsResult.data!) {
          if (event.start != null && event.end != null) {
            events.add(CalendarEvent(
              id: event.eventId!,
              title: event.title ?? 'Untitled',
              description: event.description,
              start: event.start!.toLocal(),
              end: event.end!.toLocal(),
              calendarId: calendar.id!,
              canCreateFocusSession: false, // Not needed for this use case
            ));
          }
        }
      }
    }

    events.sort((a, b) => a.start.compareTo(b.start));
    return events;
  }

  /// Find free time slots between events
  List<({DateTime start, DateTime end, Duration duration})> _findFreeTimeSlots(
    List<CalendarEvent> events,
    DateTime dayStart,
    DateTime dayEnd,
  ) {
    final gaps = <({DateTime start, DateTime end, Duration duration})>[];
    
    if (events.isEmpty) {
      final duration = dayEnd.difference(dayStart);
      gaps.add((start: dayStart, end: dayEnd, duration: duration));
      return gaps;
    }

    // Gap before first event
    if (events.first.start.isAfter(dayStart)) {
      final duration = events.first.start.difference(dayStart);
      gaps.add((start: dayStart, end: events.first.start, duration: duration));
    }

    // Gaps between events
    for (int i = 0; i < events.length - 1; i++) {
      final currentEnd = events[i].end;
      final nextStart = events[i + 1].start;
      
      if (nextStart.isAfter(currentEnd)) {
        final duration = nextStart.difference(currentEnd);
        gaps.add((start: currentEnd, end: nextStart, duration: duration));
      }
    }

    // Gap after last event
    if (events.last.end.isBefore(dayEnd)) {
      final duration = dayEnd.difference(events.last.end);
      gaps.add((start: events.last.end, end: dayEnd, duration: duration));
    }

    return gaps;
  }

  /// Get default focus time suggestions when calendar is not available
  List<DateTime> _getDefaultFocusTimes(DateTime date, int maxSuggestions) {
    final suggestions = <DateTime>[];
    final baseHours = [9, 11, 14, 16, 19]; // 9 AM, 11 AM, 2 PM, 4 PM, 7 PM
    
    for (final hour in baseHours.take(maxSuggestions)) {
      final suggestion = DateTime(date.year, date.month, date.day, hour);
      if (suggestion.isAfter(DateTime.now())) {
        suggestions.add(suggestion);
      }
    }
    
    return suggestions;
  }

  /// Save settings (implementation would use SharedPreferences)
  Future<void> _saveSettings() async {
    // Implementation would save to SharedPreferences
    // For now, just placeholder
  }

  /// Load settings (implementation would use SharedPreferences)
  Future<void> _loadSettings() async {
    // Implementation would load from SharedPreferences
    // For now, just placeholder
  }

  /// Auto-suggest focus blocks based on calendar analysis
  Future<List<FocusBlock>> suggestFocusBlocks({DateTime? date}) async {
    date ??= DateTime.now();
    final suggestions = <FocusBlock>[];
    
    if (!_autoCreateFocusBlocks) return suggestions;
    
    final focusTimes = await suggestFocusTimes(
      date: date,
      durationMinutes: _defaultFocusBlockDuration,
      maxSuggestions: 3,
    );
    
    for (int i = 0; i < focusTimes.length; i++) {
      suggestions.add(FocusBlock(
        id: 'suggested_${i}_${date.millisecondsSinceEpoch}',
        title: 'Focus Session ${i + 1}',
        startTime: focusTimes[i],
        durationMinutes: _defaultFocusBlockDuration,
        description: 'Auto-suggested focus block based on your calendar availability',
      ));
    }
    
    return suggestions;
  }
}