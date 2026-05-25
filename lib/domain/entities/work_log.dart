class WorkLog {
  final int? id;
  final DateTime date;
  final String content;
  final List<String> tags;

  const WorkLog({
    this.id,
    required this.date,
    required this.content,
    required this.tags,
  });
}