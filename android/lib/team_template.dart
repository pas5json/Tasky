import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/tasks_screen.dart';

// ============================================================================
// CUSTOMIZATION ZONE: CHANGE THESE 6 VARIABLES FOR YOUR TEAM APP!
// ============================================================================

// 1. App Title (Appears in top AppBar)
const String appTitle = 'Tasky';

// 2. What noun does your app manage?
const String itemNoun = 'Task';

// 3. Hint text inside the input box
const String inputHintText = 'Enter a new task...';

// 4. Icon displayed beside each item in your list
const IconData itemIcon = Icons.check_circle_outline;

// 5. Your team theme accent color
const Color themeColor = Color(0xFF3FA499);

// 6. Default starter items for your team app
final List<String> defaultStarterItems = [
  'Review Flutter sprint slides',
  'Prepare team project demo',
];

// ============================================================================
// Sprint 3 screen for Tasky:
// - Week 14: profile name is saved to disk (SharedPreferences) and loaded
//   again on restart — no app amnesia.
// - Week 15: dynamic CRUD list — add tasks, read via ListView.builder,
//   delete with the trash icon.
// ============================================================================
class TeamHomeScreen extends StatefulWidget {
  const TeamHomeScreen({super.key});

  @override
  State<TeamHomeScreen> createState() => _TeamHomeScreenState();
}

class _TeamHomeScreenState extends State<TeamHomeScreen> {
  // --- Week 14: Local Storage keys -------------------------------------------
  static const String _nameKey = 'tasky_profile_name';
  static const String _itemsKey = 'tasky_saved_items';

  // --- Week 15: CRUD state ----------------------------------------------------
  List<String> _items = List<String>.from(defaultStarterItems);
  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _itemInputController = TextEditingController();
  String _savedName = '';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  /// Week 14: read the profile name AND the saved task list back from disk.
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getString(_itemsKey);
    List<String> items = List<String>.from(defaultStarterItems);
    if (savedItems != null) {
      items = List<String>.from(jsonDecode(savedItems) as List);
    }
    if (!mounted) return;
    setState(() {
      _savedName = prefs.getString(_nameKey) ?? '';
      _nameInputController.text = _savedName;
      _items = items;
    });
  }

  /// Week 14: write the profile name to the phone's persistent notebook.
  Future<void> _saveName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = _nameInputController.text.trim();
    await prefs.setString(_nameKey, name);
    if (!mounted) return;
    setState(() {
      _savedName = name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile saved: $name')),
    );
  }

  /// C (Create): pin a new task onto the rail and remember it on disk.
  Future<void> _addItem() async {
    final text = _itemInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add(text); // 1. Add to in-memory list
      });
      _itemInputController.clear(); // 2. Clear input box
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_itemsKey, jsonEncode(_items));
    }
  }

  /// D (Delete): rip the task off the rail and update disk.
  Future<void> _deleteItem(int index) async {
    setState(() {
      _items.removeAt(index); // Removes the item at that specific row number!
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemsKey, jsonEncode(_items));
  }

  @override
  void dispose() {
    _nameInputController.dispose();
    _itemInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(appTitle),
        actions: [
          IconButton(
            tooltip: 'Open the full Tasky app flow',
            icon: const Icon(Icons.apps),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Open the tasks menu',
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TasksScreen(username: _savedName, isLoggedIn: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ================= GREETING CARD (Week 14) ==========================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _savedName.isEmpty
                      ? 'Logged In: Guest'
                      : 'Logged In: $_savedName',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameInputController,
                        decoration: const InputDecoration(
                          hintText: 'Type your name...',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _saveName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save name'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ================= INPUT BOX (Week 15: C) ===========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemInputController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addItem(),
                    decoration: InputDecoration(
                      hintText: inputHintText,
                      isDense: true,
                      prefixIcon: Icon(itemIcon, color: themeColor, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add $itemNoun'),
                ),
              ],
            ),
          ),
          // ================= DYNAMIC LIST (Week 15: R + D) ====================
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Text(
                      'No ${itemNoun.toLowerCase()}s yet\nAdd one above!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(itemIcon, color: themeColor),
                          title: Text(_items[index]),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteItem(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
