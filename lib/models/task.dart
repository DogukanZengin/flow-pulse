enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

class Project {
  final String id;
  final String name;
  final String? description;
  final String color; // Hex color code
  final DateTime createdAt;
  final bool isArchived;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.createdAt,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_archived': isArchived ? 1 : 0,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      color: map['color'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isArchived: map['is_archived'] == 1,
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? projectId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int estimatedMinutes; // Estimated time to complete
  final int actualMinutes; // Actual time spent
  final List<String> tags;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.projectId,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.estimatedMinutes = 25, // Default Pomodoro session
    this.actualMinutes = 0,
    this.tags = const [],
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDue = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return today == taskDue;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
      'priority': priority.index,
      'project_id': projectId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'estimated_minutes': estimatedMinutes,
      'actual_minutes': actualMinutes,
      'tags': tags.join(','),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: TaskStatus.values[map['status']],
      priority: TaskPriority.values[map['priority']],
      projectId: map['project_id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      dueDate: map['due_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'])
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'])
          : null,
      estimatedMinutes: map['estimated_minutes'] ?? 25,
      actualMinutes: map['actual_minutes'] ?? 0,
      tags: map['tags']?.isNotEmpty == true 
          ? (map['tags'] as String).split(',')
          : [],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    int? estimatedMinutes,
    int? actualMinutes,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      tags: tags ?? this.tags,
    );
  }
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get emoji {
    switch (this) {
      case TaskStatus.pending:
        return '📝';
      case TaskStatus.inProgress:
        return '🔄';
      case TaskStatus.completed:
        return '✅';
      case TaskStatus.cancelled:
        return '❌';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  String get emoji {
    switch (this) {
      case TaskPriority.low:
        return '🟢';
      case TaskPriority.medium:
        return '🟡';
      case TaskPriority.high:
        return '🟠';
      case TaskPriority.urgent:
        return '🔴';
    }
  }
}