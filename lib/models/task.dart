class Task {
  final String id;
  final String title;
  final DateTime deadline;
  bool isCompleted;
  final String? reminder;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    this.reminder,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    String? reminder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      reminder: reminder ?? this.reminder,
    );
  }
}
