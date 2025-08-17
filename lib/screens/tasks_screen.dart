import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../models/task.dart';
import '../services/task_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Task> _allTasks = [];
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  List<Task> _todayTasks = [];
  List<Task> _overdueTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    
    try {
      final allTasks = await TaskService.getAllTasks();
      final pendingTasks = await TaskService.getPendingTasks();
      final completedTasks = await TaskService.getCompletedTasks();
      final todayTasks = await TaskService.getTasksDueToday();
      final overdueTasks = await TaskService.getOverdueTasks();

      setState(() {
        _allTasks = allTasks;
        _pendingTasks = pendingTasks;
        _completedTasks = completedTasks;
        _todayTasks = todayTasks;
        _overdueTasks = overdueTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F4C75), // Deep Navy Blue
              Color(0xFF3282B8), // Ocean Blue
              Color(0xFF0FB9B1), // Turquoise
              Color(0xFF4FC3F7), // Light Ocean Blue
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  const Icon(Icons.science, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Research Notes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _showSearchDialog,
                  tooltip: 'Search Research Notes',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showMoreOptions,
                  tooltip: 'Research Tools',
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              isScrollable: false,
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
              tabs: [
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.today, size: 16),
                      const SizedBox(height: 1),
                      Text('Today (${_todayTasks.length})', style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending_actions, size: 16),
                      const SizedBox(height: 1),
                      Text('Planned (${_pendingTasks.length})', style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(height: 1),
                      Text('Done (${_completedTasks.length})', style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.waves, size: 16),
                      const SizedBox(height: 1),
                      Text('All (${_allTasks.length})', style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 120), // Space for floating nav
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTaskList(_todayTasks, showOverdue: true),
                          _buildTaskList(_pendingTasks),
                          _buildTaskList(_completedTasks),
                          _buildTaskList(_allTasks),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 100), // Above floating nav
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _createNewTask,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, {bool showOverdue = false}) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore,
              size: 64,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No research missions yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to plan your first expedition',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length + (showOverdue && _overdueTasks.isNotEmpty ? _overdueTasks.length + 1 : 0),
        itemBuilder: (context, index) {
          if (showOverdue && _overdueTasks.isNotEmpty) {
            if (index == 0) {
              return _buildSectionHeader('Overdue', Colors.red);
            }
            if (index <= _overdueTasks.length) {
              return _buildTaskCard(_overdueTasks[index - 1]);
            }
            if (index == _overdueTasks.length + 1) {
              return _buildSectionHeader('Due Today', Colors.blue);
            }
            return _buildTaskCard(tasks[index - _overdueTasks.length - 2]);
          }
          
          return _buildTaskCard(tasks[index]);
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    final oceanTitle = title == 'Overdue' ? '🚨 Abandoned Expeditions' : 
                      title == 'Due Today' ? '🎯 Today\'s Priority Missions' : title;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 8),
          Text(
            oceanTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: color)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: task.isCompleted ? null : (value) => _toggleTaskCompletion(task),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          task.title,
          style: task.isCompleted
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[600],
                )
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description?.isNotEmpty == true) ...[
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey[500] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Text(task.priority.emoji),
                const SizedBox(width: 4),
                if (task.dueDate != null) ...[
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: isOverdue 
                        ? Colors.red 
                        : isDueToday 
                            ? Colors.orange
                            : Colors.grey[600],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatDueDate(task.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue 
                          ? Colors.red 
                          : isDueToday 
                              ? Colors.orange
                              : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (task.estimatedMinutes > 0) ...[
                  Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 2),
                  Text(
                    '${task.estimatedMinutes}m',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(task, value),
          itemBuilder: (context) => [
            if (!task.isCompleted) ...[
              const PopupMenuItem(value: 'start', child: Text('🤿 Start Research Dive')),
              const PopupMenuItem(value: 'edit', child: Text('📝 Edit Mission')),
              const PopupMenuItem(value: 'complete', child: Text('✅ Mark Completed')),
            ],
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _showTaskDetails(task),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return '${difference.abs()} days ago';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference <= 7) {
      return '${difference} days';
    } else {
      return DateFormat('MMM d').format(dueDate);
    }
  }

  void _handleTaskAction(Task task, String action) {
    switch (action) {
      case 'start':
        _startFocusSession(task);
        break;
      case 'edit':
        _editTask(task);
        break;
      case 'complete':
        _toggleTaskCompletion(task);
        break;
      case 'delete':
        _deleteTask(task);
        break;
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      if (task.isCompleted) return; // Don't uncomplete tasks for now
      
      await TaskService.completeTask(task.id, actualMinutes: task.estimatedMinutes);
      await _loadTasks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Research mission completed! 🎉🐠')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  void _startFocusSession(Task task) {
    // This would integrate with the timer to start a focus session for this task
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🤿 Starting research dive for "${task.title}"'),
        action: SnackBarAction(
          label: 'Begin Dive',
          onPressed: () {
            // Navigate to timer screen with this task
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _editTask(Task task) {
    _showTaskDialog(task: task);
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ Cancel Research Mission'),
        content: Text('Are you sure you want to cancel the mission "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel Mission'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TaskService.deleteTask(task.id);
        await _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Research mission cancelled')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting task: $e')),
          );
        }
      }
    }
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(task.priority.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(task.status.emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
            if (task.description?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                task.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            _buildDetailRow('Status', task.status.displayName),
            _buildDetailRow('Priority', task.priority.displayName),
            if (task.dueDate != null)
              _buildDetailRow('Due Date', DateFormat('MMM d, y').format(task.dueDate!)),
            if (task.estimatedMinutes > 0)
              _buildDetailRow('Estimated Time', '${task.estimatedMinutes} minutes'),
            if (task.actualMinutes > 0)
              _buildDetailRow('Time Spent', '${task.actualMinutes} minutes'),
            if (task.tags.isNotEmpty)
              _buildDetailRow('Tags', task.tags.join(', ')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _editTask(task);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: task.isCompleted ? null : () {
                      Navigator.of(context).pop();
                      _startFocusSession(task);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _createNewTask() {
    _showTaskDialog();
  }

  void _showTaskDialog({Task? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        onSaved: () {
          Navigator.of(context).pop();
          _loadTasks();
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            Navigator.of(context).pop();
            _performSearch(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      final results = await TaskService.searchTasks(query);
      // Show search results in a new screen or dialog
      // For now, just show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found ${results.length} tasks matching "$query"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Task Analytics'),
            onTap: () {
              Navigator.of(context).pop();
              _showTaskAnalytics();
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Tasks'),
            onTap: () {
              Navigator.of(context).pop();
              _exportTasks();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Task Settings'),
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to task settings
            },
          ),
        ],
      ),
    );
  }

  void _showTaskAnalytics() async {
    final stats = await TaskService.getTaskStatistics();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Task Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total Tasks', '${stats['totalTasks']}'),
              _buildStatRow('Completed', '${stats['completedTasks']}'),
              _buildStatRow('Pending', '${stats['pendingTasks']}'),
              _buildStatRow('In Progress', '${stats['inProgressTasks']}'),
              _buildStatRow('Overdue', '${stats['overdueTasks']}'),
              _buildStatRow('Completion Rate', '${(stats['completionRate'] * 100).round()}%'),
              if (stats['avgCompletionTime'] > 0)
                _buildStatRow('Avg. Time', '${stats['avgCompletionTime'].round()}m'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _exportTasks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }
}

class TaskDialog extends StatefulWidget {
  final Task? task;
  final VoidCallback onSaved;

  const TaskDialog({super.key, this.task, required this.onSaved});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  int _estimatedMinutes = 25;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _priority = task.priority;
      _dueDate = task.dueDate;
      _estimatedMinutes = task.estimatedMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380, maxHeight: 560),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A5F), // Deep Ocean Modal
                  Color(0xFF2E5984), // Research Station Blue
                  Color(0xFF3A7CA8), // Equipment Blue
                  Color(0xFF4A90A4), // Laboratory Teal
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: const Color(0xFF00B4D8).withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task == null ? '🔬 New Mission' : '📝 Edit Mission',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Mission Title *',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                            hintText: 'Research objective',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Research Notes',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                            hintText: 'Details...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<TaskPriority>(
                          value: _priority,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          dropdownColor: const Color(0xFF1E3A5F),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          items: TaskPriority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Row(
                                children: [
                                  Text(priority.emoji),
                                  const SizedBox(width: 8),
                                  Text(
                                    priority.displayName,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _priority = value!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: const Text(
                            'Mission Deadline',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            _dueDate == null 
                                ? 'No deadline set' 
                                : DateFormat('MMM d, y').format(_dueDate!),
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _pickDueDate,
                                ),
                              ),
                              if (_dueDate != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _dueDate = null),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Dive time (min):',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: TextFormField(
                                initialValue: _estimatedMinutes.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final minutes = int.tryParse(value) ?? 25;
                                  setState(() => _estimatedMinutes = minutes.clamp(5, 240));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2E5984), // Ocean Blue
                            Color(0xFF3A7CA8), // Deep Ocean
                            Color(0xFF4A90A4), // Research Blue
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E5984).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading || _titleController.text.trim().isEmpty ? null : _saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.task == null ? 'Plan Mission' : 'Update Mission',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  Future<void> _saveTask() async {
    setState(() => _isLoading = true);
    
    try {
      final task = Task(
        id: widget.task?.id ?? 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        estimatedMinutes: _estimatedMinutes,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        status: widget.task?.status ?? TaskStatus.pending,
        completedAt: widget.task?.completedAt,
        actualMinutes: widget.task?.actualMinutes ?? 0,
      );

      if (widget.task == null) {
        await TaskService.createTask(task);
      } else {
        await TaskService.updateTask(task);
      }
      
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}