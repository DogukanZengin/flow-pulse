class Session {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in seconds
  final SessionType type;
  final bool completed;

  Session({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.type,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'duration': duration,
      'type': type.index,
      'completed': completed ? 1 : 0,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time']),
      duration: map['duration'],
      type: SessionType.values[map['type']],
      completed: map['completed'] == 1,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}m ${seconds}s';
  }
}

enum SessionType {
  focus,
  shortBreak,
  longBreak,
}

extension SessionTypeExtension on SessionType {
  String get displayName {
    switch (this) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }
}