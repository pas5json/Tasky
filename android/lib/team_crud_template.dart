import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ags_flutter_starter/screens/login_screen.dart';

// ============================================================================
// WEEK 14 LOCAL STORAGE KEYS (shared with main.dart for the auto-login check)
// ============================================================================
const String userNameKey = 'user_name';
const String loggedInKey = 'is_logged_in';

// ============================================================================
// ALTA GLOBAL SCHOOL: IT SHS (GRADES 10 & 11)
// SPRINT 3: WEEK 16 - STRATEGY 2 IMPLEMENTATION (SHELL + CORE ENGINE)
// PACKAGES: INTL + MATERIAL 3 BUILT-IN WIDGETS (DATEPICKER, CHIPS, BADGE)
// TEACHER: MELDI (100% ONLINE VIA GOOGLE MEET)
// ============================================================================
//
// ARCHITECTURE OVERVIEW (STRATEGY 2: SHELL + CORE ENGINE):
// 1. Tier 1 (Shell): WelcomeScreen in this file — type your name and tap
//    "Enter App". The name and an "is_logged_in" flag are written to
//    SharedPreferences (Week 14), so when the app is restarted while logged in
//    it skips the shell and reopens the dashboard as that same user. "Switch"
//    clears the flag and brings the shell back with the last name prefilled
//    (still editable). The e-mail / password LoginScreen stays reachable from
//    the shell for anyone who wants the full account flow.
// 2. Tier 2 (Core Engine): DashboardScreen in this file — dynamic CRUD,
//    Material 3 showDatePicker, ChoiceChip/FilterChip, Badge, intl formatting.
//
// TO INSTALL PACKAGES IN VS CODE TERMINAL:
// flutter pub add shared_preferences intl
// ============================================================================

// ============================================================================
// CUSTOMIZATION ZONE: CHANGE THESE VARIABLES FOR YOUR TEAM APP!
// ============================================================================

/// 1. Your App Name (Appears in top AppBar and Welcome Screen)
/// Examples: 'Tasky', 'PocketWise', 'ResQ', 'HabitHero', 'BullsEye'
const String appTitle = 'Tasky';

/// 2. What noun does your app manage?
/// Examples: 'Task', 'Expense', 'Contact', 'Habit', 'Target'
const String itemNoun = 'Task';

/// 3. Hint text shown inside the input box
/// Examples: 'Enter new task...', 'Enter expense description...', 'Enter habit...'
const String inputHintText = 'Enter a new task...';

/// 4. Icon displayed beside each item in your list
/// Examples:
/// - Tasks: Icons.check_circle_outline
/// - Expenses: Icons.attach_money
/// - Contacts: Icons.phone
/// - Habits: Icons.fitness_center
/// - Goals: Icons.flag
const IconData itemIcon = Icons.check_circle_outline;

/// 5. Your team theme accent color
/// Examples: Color(0xFF0E7C86) [Teal], Color(0xFF2563EB) [Blue], Color(0xFF7C3AED) [Purple]
const Color themeColor = Color(0xFF0E7C86);

/// 6. Category / Tag options for your team app
/// Examples:
/// - Tasky: ['General', 'Priority', 'Review']
/// - PocketWise: ['Food', 'Transport', 'Study']
/// - HabitHero: ['Morning', 'Afternoon', 'Evening']
const List<String> itemCategories = ['General', 'Priority', 'Review'];

/// 7. Default starter items for your team app
final List<TeamItem> defaultStarterItems = [
  TeamItem(
    title: 'Review Flutter sprint slides',
    date: DateTime.now(),
    category: 'Priority',
  ),
  TeamItem(
    title: 'Prepare team project demo',
    date: DateTime.now().add(const Duration(days: 2)),
    category: 'General',
  ),
];

// ============================================================================
// DATA MODEL: TEAM ITEM (WITH JSON SERIALIZATION FOR LOCAL STORAGE)
// ============================================================================

class TeamItem {
  final String title;
  final DateTime date;
  final String category;
  bool isCompleted;

  TeamItem({
    required this.title,
    required this.date,
    required this.category,
    this.isCompleted = false,
  });

  TeamItem.simple(String title, {String category = 'General'})
      : this(title: title, date: DateTime.now(), category: category);

  TeamItem clone() => TeamItem(
        title: title,
        date: date,
        category: category,
        isCompleted: isCompleted,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date.toIso8601String(),
        'category': category,
        'isCompleted': isCompleted,
      };

  factory TeamItem.fromJson(Map<String, dynamic> json) {
    return TeamItem(
      title: json['title'] as String? ?? 'Untitled Item',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      category: json['category'] as String? ?? 'General',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Backward-compatible parser for Week 15 raw string items
  factory TeamItem.fromRawString(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return TeamItem.fromJson(decoded);
      }
    } catch (_) {}
    return TeamItem(
      title: raw,
      date: DateTime.now(),
      category: 'General',
    );
  }
}

// ============================================================================
// TIER 1: WELCOME SCREEN (THE SHELL)
// WEEK 6 NAVIGATION + WEEK 7 FORM VALIDATION + WEEK 14 LOCAL STORAGE
// ============================================================================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _existingSavedName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Keep the button label in sync while the name is edited.
    _nameController.addListener(_onNameChanged);
    _checkExistingUser();
  }

  void _onNameChanged() {
    if (mounted) setState(() {});
  }

  /// Week 14: read the name saved on the previous run (no app amnesia).
  Future<void> _checkExistingUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString(userNameKey);
      if (savedName != null && savedName.trim().isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _existingSavedName = savedName.trim();
          // Prefilled, but still editable so another name can be used.
          _nameController.text = savedName.trim();
        });
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  /// Save the name to the phone disk, then enter the dashboard.
  Future<void> _handleEnter() async {
    if (!_formKey.currentState!.validate()) return;

    final enteredName = _nameController.text.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userNameKey, enteredName);
      // Stay signed in: the next app start reopens the dashboard directly.
      await prefs.setBool(loggedInKey, true);
    } catch (_) {}

    if (!mounted) return;

    // Week 6 Navigation: pushReplacement so Back does not return to the shell.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(initialUserName: enteredName),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typedName = _nameController.text.trim();
    final buttonLabel =
        typedName.isEmpty ? 'Enter App' : 'Continue as $typedName';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Alta Dark Design Token
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: _isLoading
                ? const CircularProgressIndicator(color: themeColor)
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon Pill Badge
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: themeColor, width: 2),
                          ),
                          child: const Icon(itemIcon,
                              size: 64, color: Colors.white),
                        ),
                        const SizedBox(height: 20),

                        // App Title
                        const Text(
                          appTitle,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Shell Login Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Welcome to Your Team App',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Enter your name to unlock your $itemNoun dashboard.',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 20),

                              // Week 7: TextFormField with Validation
                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: 'Student / User Name',
                                  hintText: 'e.g., Gavenzzo, Aaron, Justin',
                                  prefixIcon: const Icon(Icons.person,
                                      color: themeColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFAFAF7),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your name to proceed.';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _handleEnter(),
                              ),
                              const SizedBox(height: 20),

                              // Primary Submit Button
                              ElevatedButton(
                                onPressed: _handleEnter,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  buttonLabel,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Optional: the full e-mail / password flow.
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.mail_outline, size: 16),
                                label: const Text(
                                  'Sign in with e-mail & password',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TIER 2: DASHBOARD SCREEN (THE CORE ENGINE)
// INTEGRATES: INTL DATE FORMATTING + DATEPICKER + CHIPS + BADGE + CRUD
// ============================================================================

class DashboardScreen extends StatefulWidget {
  final String? initialUserName;
  const DashboardScreen({super.key, this.initialUserName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _userName;
  List<TeamItem> _items = [];
  String _selectedFilter = 'All';

  // Input state
  final TextEditingController _itemInputController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = itemCategories.first;

  static const String _itemsKey = 'team_items_v2';

  @override
  void initState() {
    super.initState();
    _userName = widget.initialUserName ?? 'Student';
    _loadAllSavedData();
  }

  Future<void> _loadAllSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // The freshly signed-in name wins; otherwise fall back to the name that
      // was persisted on the previous run.
      final String savedName = widget.initialUserName ??
          prefs.getString(userNameKey) ??
          'Student';
      final List<String>? savedJsonList =
          prefs.getStringList(_itemsKey) ??
              prefs.getStringList('team_items_list');

      if (!mounted) return;
      setState(() {
        _userName = savedName;
        if (savedJsonList != null && savedJsonList.isNotEmpty) {
          _items =
              savedJsonList.map((str) => TeamItem.fromRawString(str)).toList();
        } else {
          _items = defaultStarterItems.map((item) => item.clone()).toList();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userName = widget.initialUserName ?? _userName;
        _items = defaultStarterItems.map((item) => item.clone()).toList();
      });
    }
  }

  Future<void> _persistItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList =
          _items.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_itemsKey, encodedList);
    } catch (_) {}
  }

  // Week 16: Material 3 showDatePicker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: themeColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // CRUD: CREATE
  void _addItem() {
    final text = _itemInputController.text.trim();

    // Defensive Check 2: reject blank input instead of creating an empty card.
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid $itemNoun name!')),
      );
      return;
    }

    final newItem = TeamItem(
      title: text,
      date: _selectedDate,
      category: _selectedCategory,
    );

    setState(() {
      _items.insert(0, newItem);
      _itemInputController.clear();
      _selectedDate = DateTime.now();
    });

    _persistItems();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Added $itemNoun: "$text" for ${DateFormat('d MMM').format(newItem.date)}'),
          backgroundColor: themeColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // CRUD: TOGGLE COMPLETE
  void _toggleItemStatus(int index) {
    setState(() {
      _items[index].isCompleted = !_items[index].isCompleted;
    });
    _persistItems();
  }

  // CRUD: DELETE
  void _deleteItem(int index) {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
    });
    _persistItems();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted $itemNoun: "${removed.title}"'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Notification tray: lists every item that is not finished yet.
  void _showIncompleteNotifications() {
    final pending = _items.where((item) => !item.isCompleted).toList();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF7F2EC),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active, color: themeColor),
                    const SizedBox(width: 8),
                    Text(
                      'Incomplete $itemNoun${pending.length == 1 ? '' : 's'} (${pending.length})',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (pending.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: const [
                        Icon(Icons.celebration, color: themeColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('No incomplete tasks — everything is done!'),
                        ),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: pending.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = pending[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(itemIcon, color: themeColor),
                          title: Text(item.title),
                          subtitle: Text(
                            '${DateFormat('d MMM yyyy').format(item.date)} · ${item.category}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _toggleItemStatus(_items.indexOf(item));
                            },
                            style:
                                TextButton.styleFrom(foregroundColor: themeColor),
                            child: const Text('Done'),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Switch user: keep the current name on disk, then reopen the shell with
  // that name prefilled so a different name can be typed instead.
  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userNameKey, _userName);
      // Signed out on purpose: a restart should show the shell again.
      await prefs.setBool(loggedInKey, false);
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  // Filtered Items Getter
  List<TeamItem> get _filteredItems {
    if (_selectedFilter == 'All') return _items;
    if (_selectedFilter == 'Active') {
      return _items.where((i) => !i.isCompleted).toList();
    }
    if (_selectedFilter == 'Completed') {
      return _items.where((i) => i.isCompleted).toList();
    }
    return _items.where((i) => i.category == _selectedFilter).toList();
  }

  @override
  void dispose() {
    _itemInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _items.where((i) => !i.isCompleted).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        title: const Text(appTitle),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Week 16: Material 3 Badge widget displaying active item count
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Badge.count(
                count: activeCount,
                backgroundColor: const Color(0xFFFFD166), // Yellow Accent
                textColor: const Color(0xFF1E293B),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: '$activeCount active $itemNoun(s)',
                  onPressed: _showIncompleteNotifications,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Switch User (Shell)',
            onPressed: _handleLogout,
          ),
        ],
      ),
      // Defensive Check 1: the whole dashboard scrolls, so the software
      // keyboard can never push the layout past its bounds.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -------------------------------------------------------------
              // 1. GREETING CARD (WEEK 14 STORAGE + STRATEGY 2 STATE)
              // -------------------------------------------------------------
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: themeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: themeColor.withValues(alpha: 0.15),
                      foregroundColor: themeColor,
                      child: const Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logged In: $_userName',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Today: ${DateFormat('EEEE, d MMM yyyy').format(DateTime.now())}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Switch',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: themeColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // -------------------------------------------------------------
              // 2. INPUT CARD: CREATE + INTL DATEPICKER + CHOICE CHIPS
              // -------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemInputController,
                            decoration: InputDecoration(
                              hintText: inputHintText,
                              prefixIcon:
                                  const Icon(itemIcon, color: themeColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            onSubmitted: (_) => _addItem(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text('Add $itemNoun'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Controls Row: Date Picker Button + Category Chips
                    Row(
                      children: [
                        // Week 16: showDatePicker Trigger with intl date
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_month, size: 16),
                          label: Text(
                            DateFormat('d MMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: themeColor,
                            side: BorderSide(
                                color: themeColor.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Week 16: Category ChoiceChips
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: itemCategories.map((cat) {
                                final isSelected = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: ChoiceChip(
                                    label: Text(cat,
                                        style: const TextStyle(fontSize: 11)),
                                    selected: isSelected,
                                    selectedColor:
                                        themeColor.withValues(alpha: 0.2),
                                    onSelected: (val) {
                                      if (val) {
                                        setState(() => _selectedCategory = cat);
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 3. FILTER STRIP (MATERIAL 3 FILTER CHIPS)
              // -------------------------------------------------------------
              Row(
                children: [
                  Text(
                    'Active ${itemNoun}s (${_items.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    children: ['All', 'Active', 'Completed'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return FilterChip(
                        label:
                            Text(filter, style: const TextStyle(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // -------------------------------------------------------------
              // 4. DYNAMIC LIST (READ, UPDATE/TOGGLE, DELETE)
              // -------------------------------------------------------------
              if (_filteredItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const Icon(itemIcon, size: 52, color: Colors.black26),
                      const SizedBox(height: 10),
                      Text(
                        'No ${itemNoun.toLowerCase()}s match the filter.',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type above and tap "Add $itemNoun"',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black38),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final masterIndex = _items.indexOf(item);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: item.isCompleted,
                          activeColor: themeColor,
                          onChanged: (_) => _toggleItemStatus(masterIndex),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: item.isCompleted
                                ? Colors.black38
                                : const Color(0xFF1E293B),
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            // Formatted Date
                            const Icon(Icons.calendar_today,
                                size: 11, color: Color(0xFF757575)),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('d MMM yyyy').format(item.date),
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF757575)),
                            ),
                            const SizedBox(width: 8),

                            // Category Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFFEF4444)),
                          tooltip: 'Delete this item',
                          onPressed: () => _deleteItem(masterIndex),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
