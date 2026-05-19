class WorkLog {
  final String id;
  final DateTime date;
  final String content;
  final List<String> tags;

  const WorkLog({
    required this.id,
    required this.date,
    required this.content,
    required this.tags,
  });
}