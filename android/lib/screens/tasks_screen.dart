import 'package:flutter/material.dart';
import '../models/task.dart';
import 'login_screen.dart';
import 'new_task_screen.dart';

class TasksScreen extends StatefulWidget {
  final String username;
  final bool isLoggedIn;

  const TasksScreen({
    super.key,
    this.username = 'Guest',
    this.isLoggedIn = false,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [
    Task(
      id: '1',
      title: 'EXAMPLE TASK 1',
      deadline: DateTime.now().add(const Duration(days: 2)),
      reminder: 'Tomorrow',
    ),
    Task(
      id: '2',
      title: 'EXAMPLE TASK2',
      deadline: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
      reminder: 'In 2 hours',
    ),
    Task(
      id: '3',
      title: 'EXAMPLE TASK 3 ',
      deadline: DateTime.now().add(const Duration(days: 5)),
      reminder: 'Next week',
    ),
    Task(
      id: '4',
      title: 'EXAMPLE TASK 4',
      deadline: DateTime.now(),
      reminder: 'Today',
    ),
    Task(
      id: '5',
      title: 'EXAMPLE TASK 5',
      deadline: DateTime.now().add(const Duration(days: 3)),
      reminder: 'In 3 days',
    ),
    Task(
      id: '6',
      title: 'EXAMPLE TASK 6',
      deadline: DateTime.now().add(const Duration(days: 4)),
      reminder: 'Soon',
    ),
  ];

  String searchQuery = '';
  String statusFilter = 'All'; // All | Active | Completed

  late final TextEditingController searchTextController;

  /// Lifecycle: create the search controller before the first build.
  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
  }

  /// Lifecycle: release it when the tasks screen leaves the tree.
  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _toggleTask(Task task) {
    setState(() {
      int index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(isCompleted: !task.isCompleted);
      }
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.removeWhere((t) => t.id == task.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${task.title}" deleted')),
    );
  }

  void _markAllAsComplete() {
    setState(() {
      for (int i = 0; i < tasks.length; i++) {
        if (!tasks[i].isCompleted) {
          tasks[i] = tasks[i].copyWith(isCompleted: true);
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All tasks marked as complete!')),
    );
  }

  /// Profile avatar -> opens the profile menu (log out / log in).
  void _showProfileSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF3FA499),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.isLoggedIn ? widget.username : 'Guest',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _backToLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isLoggedIn
                        ? const Color(0xFFE57373)
                        : const Color(0xFF3FA499),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                      widget.isLoggedIn ? Icons.logout : Icons.login,
                      size: 18),
                  label: Text(widget.isLoggedIn ? 'Log out' : 'Log in'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Clears the whole navigation stack and returns to a fresh LoginScreen.
  /// Works as "log out" for signed-in users and "log in" for guests.
  void _backToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showCalendarView() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar View'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateChanged: (date) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: ${date.toLocal()}')),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSearchAndFilter() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Search & Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LIVE search: updates the list behind the dialog with every
              // keystroke — the dialog only closes when YOU tap Done/Close.
              TextField(
                autofocus: true,
                controller: searchTextController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setDialogState(() {});
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Filter by:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: statusFilter == 'All',
                    onSelected: (_) {
                      setDialogState(() {});
                      setState(() {
                        statusFilter = 'All';
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Active'),
                    selected: statusFilter == 'Active',
                    onSelected: (_) {
                      setDialogState(() {});
                      setState(() {
                        statusFilter = 'Active';
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Completed'),
                    selected: statusFilter == 'Completed',
                    onSelected: (_) {
                      setDialogState(() {});
                      setState(() {
                        statusFilter = 'Completed';
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'TODAY';
    } else if (taskDate == tomorrow) {
      return 'TMRW';
    } else {
      return '${taskDate.month}/${taskDate.day}';
    }
  }

  /// Applies BOTH filters: text search AND status (All/Active/Completed).
  List<Task> get filteredTasks {
    Iterable<Task> result = tasks;

    if (statusFilter == 'Active') {
      result = result.where((task) => !task.isCompleted);
    } else if (statusFilter == 'Completed') {
      result = result.where((task) => task.isCompleted);
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((task) =>
          task.title.toLowerCase().contains(query));
    }
    return result.toList();
  }

  /// Human-readable summary of the active filter, shown above the list.
  String get _filterLabel {
    final parts = <String>[];
    if (statusFilter != 'All') parts.add(statusFilter);
    if (searchQuery.isNotEmpty) parts.add('\u201C$searchQuery\u201D');
    return parts.isEmpty ? '' : parts.join(' \u00B7 ');
  }

  /// "veronica tan" -> "Veronica"
  String get _displayName {
    final name = widget.username.trim();
    if (name.isEmpty || name == 'Guest') return 'Guest';
    if (name.contains('@')) return name.split('@').first;
    return name.split(' ').first;
  }

  String get _subtitle {
    final name = widget.username.trim();
    if (name.isEmpty || name == 'Guest') {
      return 'Browsing as guest';
    }
    if (name.contains('@')) return name;
    return 'Signed in as $name';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3FA499),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hi, $_displayName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (widget.isLoggedIn)
              Text(
                _subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB8E6DC),
                ),
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: IconButton(
              tooltip: 'Profile',
              onPressed: _showProfileSheet,
              icon: CircleAvatar(
                backgroundColor: const Color(0xFFB8E6DC),
                child: const Icon(Icons.person, color: Color(0xFF3FA499)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Action buttons
          Container(
            color: const Color(0xFF3FA499),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewTaskScreen(
                          onTaskCreated: _addTask,
                        ),
                      ),
                    );
                  },
                  child:
                      _buildActionButton(Icons.add_circle_outline, 'New task'),
                ),
                GestureDetector(
                  onTap: _showCalendarView,
                  child:
                      _buildActionButton(Icons.calendar_today, 'View calendar'),
                ),
                GestureDetector(
                  onTap: _showSearchAndFilter,
                  child: _buildActionButton(Icons.search, 'Search & Filter'),
                ),
              ],
            ),
          ),
          // Active filter banner (only when a filter is applied)
          if (_filterLabel.isNotEmpty)
            Container(
              width: double.infinity,
              color: const Color(0xFFB8E6DC),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter: $_filterLabel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3FA499),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        searchQuery = '';
                        statusFilter = 'All';
                        searchTextController.clear();
                      });
                    },
                    child: const Text(
                      'Clear ✕',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3FA499),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Tasks list
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'No tasks found'
                              : 'No tasks yet\nTap New task to create one',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskItem(task);
                    },
                  ),
          ),
          // Mark all as complete button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF3FA499),
            child: ElevatedButton(
              onPressed: _markAllAsComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8E6DC),
                foregroundColor: const Color(0xFF3FA499),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Mark all as complete',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTaskScreen(
                onTaskCreated: _addTask,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF3FA499),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => _toggleTask(task),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: task.isCompleted
                        ? const Color(0xFF3FA499)
                        : Colors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  color:
                      task.isCompleted ? const Color(0xFF3FA499) : Colors.white,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'DEADLINE\n${_formatDate(task.deadline)}',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Delete button
            GestureDetector(
              onTap: () => _deleteTask(task),
              child: Icon(
                Icons.delete,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
