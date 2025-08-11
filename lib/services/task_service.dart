import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class TaskService {
  static Database? _database;
  static const String _tasksTable = 'tasks';
  static const String _projectsTable = 'projects';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flowpulse_tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create projects table
    await db.execute('''
      CREATE TABLE $_projectsTable(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE $_tasksTable(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        status INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        project_id TEXT,
        created_at INTEGER NOT NULL,
        due_date INTEGER,
        completed_at INTEGER,
        estimated_minutes INTEGER DEFAULT 25,
        actual_minutes INTEGER DEFAULT 0,
        tags TEXT,
        FOREIGN KEY (project_id) REFERENCES $_projectsTable (id)
      )
    ''');

    // Insert default project
    await db.insert(_projectsTable, {
      'id': 'default',
      'name': 'Personal',
      'description': 'Default project for personal tasks',
      'color': '#2196F3',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_archived': 0,
    });
  }

  // ===== PROJECT METHODS =====

  /// Create a new project
  static Future<String> createProject(Project project) async {
    final db = await database;
    await db.insert(_projectsTable, project.toMap());
    return project.id;
  }

  /// Get all projects
  static Future<List<Project>> getAllProjects({bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _projectsTable,
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  /// Get project by ID
  static Future<Project?> getProject(String projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _projectsTable,
      where: 'id = ?',
      whereArgs: [projectId],
    );
    if (maps.isEmpty) return null;
    return Project.fromMap(maps.first);
  }

  /// Update project
  static Future<void> updateProject(Project project) async {
    final db = await database;
    await db.update(
      _projectsTable,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  /// Archive/unarchive project
  static Future<void> archiveProject(String projectId, bool archive) async {
    final db = await database;
    await db.update(
      _projectsTable,
      {'is_archived': archive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  /// Delete project (and all its tasks)
  static Future<void> deleteProject(String projectId) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete all tasks in the project
      await txn.delete(_tasksTable, where: 'project_id = ?', whereArgs: [projectId]);
      // Delete the project
      await txn.delete(_projectsTable, where: 'id = ?', whereArgs: [projectId]);
    });
  }

  // ===== TASK METHODS =====

  /// Create a new task
  static Future<String> createTask(Task task) async {
    final db = await database;
    await db.insert(_tasksTable, task.toMap());
    return task.id;
  }

  /// Get all tasks
  static Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get tasks by status
  static Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get tasks by project
  static Future<List<Task>> getTasksByProject(String projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get pending tasks
  static Future<List<Task>> getPendingTasks() async {
    return await getTasksByStatus(TaskStatus.pending);
  }

  /// Get completed tasks
  static Future<List<Task>> getCompletedTasks() async {
    return await getTasksByStatus(TaskStatus.completed);
  }

  /// Get tasks due today
  static Future<List<Task>> getTasksDueToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'due_date >= ? AND due_date < ? AND status != ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
        TaskStatus.completed.index,
      ],
      orderBy: 'priority DESC, due_date ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get overdue tasks
  static Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'due_date < ? AND status != ? AND status != ?',
      whereArgs: [
        now.millisecondsSinceEpoch,
        TaskStatus.completed.index,
        TaskStatus.cancelled.index,
      ],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get tasks by priority
  static Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'priority = ? AND status != ?',
      whereArgs: [priority.index, TaskStatus.completed.index],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get high priority tasks
  static Future<List<Task>> getHighPriorityTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'priority >= ? AND status != ? AND status != ?',
      whereArgs: [
        TaskPriority.high.index,
        TaskStatus.completed.index,
        TaskStatus.cancelled.index,
      ],
      orderBy: 'priority DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Search tasks
  static Future<List<Task>> searchTasks(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'title LIKE ? OR description LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Update task
  static Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      _tasksTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Complete task
  static Future<void> completeTask(String taskId, {int? actualMinutes}) async {
    final db = await database;
    final updateData = {
      'status': TaskStatus.completed.index,
      'completed_at': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (actualMinutes != null) {
      updateData['actual_minutes'] = actualMinutes;
    }

    await db.update(
      _tasksTable,
      updateData,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  /// Mark task as in progress
  static Future<void> startTask(String taskId) async {
    final db = await database;
    await db.update(
      _tasksTable,
      {'status': TaskStatus.inProgress.index},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  /// Cancel task
  static Future<void> cancelTask(String taskId) async {
    final db = await database;
    await db.update(
      _tasksTable,
      {'status': TaskStatus.cancelled.index},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  /// Delete task
  static Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete(
      _tasksTable,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  /// Get task statistics
  static Future<Map<String, dynamic>> getTaskStatistics() async {
    final db = await database;
    
    // Total tasks
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tasksTable');
    final totalTasks = totalResult.first['count'] as int;

    // Completed tasks
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tasksTable WHERE status = ?',
      [TaskStatus.completed.index],
    );
    final completedTasks = completedResult.first['count'] as int;

    // Pending tasks
    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tasksTable WHERE status = ?',
      [TaskStatus.pending.index],
    );
    final pendingTasks = pendingResult.first['count'] as int;

    // In progress tasks
    final inProgressResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tasksTable WHERE status = ?',
      [TaskStatus.inProgress.index],
    );
    final inProgressTasks = inProgressResult.first['count'] as int;

    // Overdue tasks
    final overdueResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tasksTable WHERE due_date < ? AND status != ? AND status != ?',
      [DateTime.now().millisecondsSinceEpoch, TaskStatus.completed.index, TaskStatus.cancelled.index],
    );
    final overdueTasks = overdueResult.first['count'] as int;

    // Completion rate
    final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    // Average completion time
    final avgTimeResult = await db.rawQuery(
      'SELECT AVG(actual_minutes) as avg_time FROM $_tasksTable WHERE status = ? AND actual_minutes > 0',
      [TaskStatus.completed.index],
    );
    final avgCompletionTime = (avgTimeResult.first['avg_time'] as double?) ?? 0.0;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'inProgressTasks': inProgressTasks,
      'overdueTasks': overdueTasks,
      'completionRate': completionRate,
      'avgCompletionTime': avgCompletionTime,
    };
  }

  /// Get productivity trends (tasks completed per day over last 30 days)
  static Future<Map<DateTime, int>> getProductivityTrends() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final result = await db.rawQuery('''
      SELECT 
        DATE(completed_at / 1000, 'unixepoch') as date,
        COUNT(*) as count
      FROM $_tasksTable 
      WHERE status = ? AND completed_at >= ?
      GROUP BY DATE(completed_at / 1000, 'unixepoch')
      ORDER BY date
    ''', [TaskStatus.completed.index, thirtyDaysAgo.millisecondsSinceEpoch]);

    final trends = <DateTime, int>{};
    for (final row in result) {
      final dateStr = row['date'] as String;
      final date = DateTime.parse(dateStr);
      final count = row['count'] as int;
      trends[date] = count;
    }

    return trends;
  }

  /// Link task to a focus session
  static Future<void> linkTaskToSession(String taskId, int sessionId) async {
    // This would require extending the session table to include task_id
    // For now, we'll store it as a reference in the task
    final db = await database;
    // Implementation would depend on how you want to structure the relationship
  }

  /// Get tasks that are good candidates for focus sessions
  static Future<List<Task>> getFocusTaskCandidates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tasksTable,
      where: 'status = ? OR status = ?',
      whereArgs: [TaskStatus.pending.index, TaskStatus.inProgress.index],
      orderBy: 'priority DESC, due_date ASC, created_at ASC',
      limit: 10,
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }
}