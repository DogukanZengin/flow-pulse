import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../models/session.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/task_service.dart';
import '../services/analytics_service.dart';

enum ExportFormat {
  csv,
  pdf,
  json,
}

enum ExportType {
  sessions,
  tasks,
  analytics,
  combined,
}

class ExportResult {
  final bool success;
  final String? filePath;
  final String? error;

  ExportResult({required this.success, this.filePath, this.error});
}

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Export data based on parameters
  Future<ExportResult> exportData({
    required ExportType type,
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    String? customFileName,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 30));
      endDate ??= DateTime.now();

      switch (format) {
        case ExportFormat.csv:
          return await _exportToCsv(type, startDate, endDate, customFileName);
        case ExportFormat.pdf:
          return await _exportToPdf(type, startDate, endDate, customFileName);
        case ExportFormat.json:
          return await _exportToJson(type, startDate, endDate, customFileName);
      }
    } catch (e) {
      return ExportResult(success: false, error: e.toString());
    }
  }

  /// Export sessions data to CSV
  Future<ExportResult> _exportToCsv(
    ExportType type,
    DateTime startDate,
    DateTime endDate,
    String? customFileName,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = customFileName ?? _generateFileName(type, ExportFormat.csv);
      final file = File('${directory.path}/$fileName');

      List<List<String>> csvData = [];

      switch (type) {
        case ExportType.sessions:
          csvData = await _getSessionsCsvData(startDate, endDate);
          break;
        case ExportType.tasks:
          csvData = await _getTasksCsvData();
          break;
        case ExportType.analytics:
          csvData = await _getAnalyticsCsvData(startDate, endDate);
          break;
        case ExportType.combined:
          csvData = await _getCombinedCsvData(startDate, endDate);
          break;
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csvString);

      return ExportResult(success: true, filePath: file.path);
    } catch (e) {
      return ExportResult(success: false, error: e.toString());
    }
  }

  /// Export data to PDF
  Future<ExportResult> _exportToPdf(
    ExportType type,
    DateTime startDate,
    DateTime endDate,
    String? customFileName,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = customFileName ?? _generateFileName(type, ExportFormat.pdf);
      final file = File('${directory.path}/$fileName');

      final pdf = pw.Document();

      switch (type) {
        case ExportType.sessions:
          await _addSessionsPdfPages(pdf, startDate, endDate);
          break;
        case ExportType.tasks:
          await _addTasksPdfPages(pdf);
          break;
        case ExportType.analytics:
          await _addAnalyticsPdfPages(pdf, startDate, endDate);
          break;
        case ExportType.combined:
          await _addCombinedPdfPages(pdf, startDate, endDate);
          break;
      }

      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      return ExportResult(success: true, filePath: file.path);
    } catch (e) {
      return ExportResult(success: false, error: e.toString());
    }
  }

  /// Export data to JSON
  Future<ExportResult> _exportToJson(
    ExportType type,
    DateTime startDate,
    DateTime endDate,
    String? customFileName,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = customFileName ?? _generateFileName(type, ExportFormat.json);
      final file = File('${directory.path}/$fileName');

      Map<String, dynamic> jsonData = {};

      switch (type) {
        case ExportType.sessions:
          jsonData = await _getSessionsJsonData(startDate, endDate);
          break;
        case ExportType.tasks:
          jsonData = await _getTasksJsonData();
          break;
        case ExportType.analytics:
          jsonData = await _getAnalyticsJsonData(startDate, endDate);
          break;
        case ExportType.combined:
          jsonData = await _getCombinedJsonData(startDate, endDate);
          break;
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      await file.writeAsString(jsonString);

      return ExportResult(success: true, filePath: file.path);
    } catch (e) {
      return ExportResult(success: false, error: e.toString());
    }
  }

  // ===== CSV DATA METHODS =====

  Future<List<List<String>>> _getSessionsCsvData(DateTime startDate, DateTime endDate) async {
    final sessions = await DatabaseService.getSessionsByDateRange(startDate, endDate);
    
    final csvData = <List<String>>[];
    csvData.add([
      'Date',
      'Start Time',
      'End Time',
      'Duration (minutes)',
      'Type',
      'Completed',
    ]);

    for (final session in sessions) {
      csvData.add([
        _dateFormat.format(session.startTime),
        _dateTimeFormat.format(session.startTime),
        _dateTimeFormat.format(session.endTime),
        (session.duration / 60).round().toString(),
        session.type.displayName,
        session.completed ? 'Yes' : 'No',
      ]);
    }

    return csvData;
  }

  Future<List<List<String>>> _getTasksCsvData() async {
    final tasks = await TaskService.getAllTasks();
    
    final csvData = <List<String>>[];
    csvData.add([
      'Title',
      'Description',
      'Status',
      'Priority',
      'Project',
      'Created',
      'Due Date',
      'Completed',
      'Estimated Minutes',
      'Actual Minutes',
      'Tags',
    ]);

    for (final task in tasks) {
      csvData.add([
        task.title,
        task.description ?? '',
        task.status.displayName,
        task.priority.displayName,
        task.projectId ?? '',
        _dateTimeFormat.format(task.createdAt),
        task.dueDate != null ? _dateTimeFormat.format(task.dueDate!) : '',
        task.completedAt != null ? _dateTimeFormat.format(task.completedAt!) : '',
        task.estimatedMinutes.toString(),
        task.actualMinutes.toString(),
        task.tags.join('; '),
      ]);
    }

    return csvData;
  }

  Future<List<List<String>>> _getAnalyticsCsvData(DateTime startDate, DateTime endDate) async {
    final analyticsService = AnalyticsService();
    final analyticsData = await analyticsService.getAnalyticsData(
      startDate: startDate,
      endDate: endDate,
    );
    
    final csvData = <List<String>>[];
    csvData.add([
      'Date',
      'Focus Time (minutes)',
      'Break Time (minutes)',
      'Sessions Completed',
      'Completion Rate',
      'Streak',
    ]);

    for (final data in analyticsData) {
      csvData.add([
        _dateFormat.format(data.date),
        data.totalFocusTime.toString(),
        data.totalBreakTime.toString(),
        data.sessionsCompleted.toString(),
        (data.completionRate * 100).toStringAsFixed(1) + '%',
        data.streak.toString(),
      ]);
    }

    return csvData;
  }

  Future<List<List<String>>> _getCombinedCsvData(DateTime startDate, DateTime endDate) async {
    final sessions = await _getSessionsCsvData(startDate, endDate);
    final tasks = await _getTasksCsvData();
    final analytics = await _getAnalyticsCsvData(startDate, endDate);

    final combined = <List<String>>[];
    
    // Add sessions section
    combined.add(['=== SESSIONS ===']);
    combined.addAll(sessions);
    combined.add(['']); // Empty row

    // Add tasks section
    combined.add(['=== TASKS ===']);
    combined.addAll(tasks);
    combined.add(['']); // Empty row

    // Add analytics section
    combined.add(['=== ANALYTICS ===']);
    combined.addAll(analytics);

    return combined;
  }

  // ===== PDF METHODS =====

  Future<void> _addSessionsPdfPages(pw.Document pdf, DateTime startDate, DateTime endDate) async {
    final sessions = await DatabaseService.getSessionsByDateRange(startDate, endDate);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'FlowPulse Sessions Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Paragraph(
            text: 'Period: ${_dateFormat.format(startDate)} to ${_dateFormat.format(endDate)}',
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Date', 'Type', 'Duration', 'Completed'],
            data: sessions.map((session) => [
              _dateFormat.format(session.startTime),
              session.type.displayName,
              '${(session.duration / 60).round()}m',
              session.completed ? '✓' : '✗',
            ]).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _addTasksPdfPages(pw.Document pdf) async {
    final tasks = await TaskService.getAllTasks();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'FlowPulse Tasks Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Title', 'Status', 'Priority', 'Due Date'],
            data: tasks.map((task) => [
              task.title.length > 30 ? '${task.title.substring(0, 30)}...' : task.title,
              task.status.displayName,
              task.priority.displayName,
              task.dueDate != null ? _dateFormat.format(task.dueDate!) : '-',
            ]).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _addAnalyticsPdfPages(pw.Document pdf, DateTime startDate, DateTime endDate) async {
    final analyticsService = AnalyticsService();
    final analyticsData = await analyticsService.getAnalyticsData(
      startDate: startDate,
      endDate: endDate,
    );
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'FlowPulse Analytics Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Paragraph(
            text: 'Period: ${_dateFormat.format(startDate)} to ${_dateFormat.format(endDate)}',
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Date', 'Focus Time', 'Sessions', 'Completion Rate'],
            data: analyticsData.map((data) => [
              _dateFormat.format(data.date),
              '${data.totalFocusTime}m',
              data.sessionsCompleted.toString(),
              '${(data.completionRate * 100).round()}%',
            ]).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _addCombinedPdfPages(pw.Document pdf, DateTime startDate, DateTime endDate) async {
    await _addSessionsPdfPages(pdf, startDate, endDate);
    await _addTasksPdfPages(pdf);
    await _addAnalyticsPdfPages(pdf, startDate, endDate);
  }

  // ===== JSON METHODS =====

  Future<Map<String, dynamic>> _getSessionsJsonData(DateTime startDate, DateTime endDate) async {
    final sessions = await DatabaseService.getSessionsByDateRange(startDate, endDate);
    
    return {
      'export_type': 'sessions',
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'sessions': sessions.map((session) => {
        'id': session.id,
        'start_time': session.startTime.toIso8601String(),
        'end_time': session.endTime.toIso8601String(),
        'duration_seconds': session.duration,
        'duration_minutes': (session.duration / 60).round(),
        'type': session.type.name,
        'completed': session.completed,
      }).toList(),
    };
  }

  Future<Map<String, dynamic>> _getTasksJsonData() async {
    final tasks = await TaskService.getAllTasks();
    
    return {
      'export_type': 'tasks',
      'exported_at': DateTime.now().toIso8601String(),
      'tasks': tasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'status': task.status.name,
        'priority': task.priority.name,
        'project_id': task.projectId,
        'created_at': task.createdAt.toIso8601String(),
        'due_date': task.dueDate?.toIso8601String(),
        'completed_at': task.completedAt?.toIso8601String(),
        'estimated_minutes': task.estimatedMinutes,
        'actual_minutes': task.actualMinutes,
        'tags': task.tags,
      }).toList(),
    };
  }

  Future<Map<String, dynamic>> _getAnalyticsJsonData(DateTime startDate, DateTime endDate) async {
    final analyticsService = AnalyticsService();
    final analyticsData = await analyticsService.getAnalyticsData(
      startDate: startDate,
      endDate: endDate,
    );
    
    return {
      'export_type': 'analytics',
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'analytics': analyticsData.map((data) => {
        'date': data.date.toIso8601String(),
        'total_focus_time_minutes': data.totalFocusTime,
        'total_break_time_minutes': data.totalBreakTime,
        'sessions_completed': data.sessionsCompleted,
        'completion_rate': data.completionRate,
        'streak': data.streak,
      }).toList(),
    };
  }

  Future<Map<String, dynamic>> _getCombinedJsonData(DateTime startDate, DateTime endDate) async {
    final sessions = await _getSessionsJsonData(startDate, endDate);
    final tasks = await _getTasksJsonData();
    final analytics = await _getAnalyticsJsonData(startDate, endDate);

    return {
      'export_type': 'combined',
      'exported_at': DateTime.now().toIso8601String(),
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'sessions': sessions['sessions'],
      'tasks': tasks['tasks'],
      'analytics': analytics['analytics'],
    };
  }

  // ===== UTILITY METHODS =====

  String _generateFileName(ExportType type, ExportFormat format) {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final typeName = type.name;
    final extension = format.name;
    return 'flowpulse_${typeName}_$timestamp.$extension';
  }

  /// Get list of available export formats for a given type
  List<ExportFormat> getAvailableFormats(ExportType type) {
    // All types support all formats for now
    return ExportFormat.values;
  }

  /// Get estimated file size (rough estimate)
  Future<String> getEstimatedFileSize(ExportType type, ExportFormat format) async {
    // This is a rough estimate - in a real app you'd calculate more accurately
    switch (type) {
      case ExportType.sessions:
        return format == ExportFormat.pdf ? '~500KB' : '~50KB';
      case ExportType.tasks:
        return format == ExportFormat.pdf ? '~300KB' : '~30KB';
      case ExportType.analytics:
        return format == ExportFormat.pdf ? '~400KB' : '~40KB';
      case ExportType.combined:
        return format == ExportFormat.pdf ? '~1MB' : '~100KB';
    }
  }
}