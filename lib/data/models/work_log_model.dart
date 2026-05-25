import 'package:daydone_ai/domain/entities/work_log.dart';

class WorkLogModel {
  final int? id;
  final DateTime date;
  final String content;
  final List<String> tags;

  const WorkLogModel({
    this.id,
    required this.date,
    required this.content,
    required this.tags,
  });

  // แปลง Map (จาก DB) → WorkLogModel
  factory WorkLogModel.fromMap(Map<String, dynamic> map) {
    return WorkLogModel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      content: map['content'] as String,
      tags: (map['tags'] as String).split(','),
    );
  }

  // แปลง WorkLogModel → Map (ส่งให้ DB)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'tags': tags.join(','),
    };
  }
    // แปลง Model → Domain Entity
  WorkLog toDomain() {
    return WorkLog(
      id: id,
      date: date,
      content: content,
      tags: tags,
    );
  }

  // แปลง Domain Entity → Model
  factory WorkLogModel.fromDomain(WorkLog log) {
    return WorkLogModel(
      id: log.id,
      date: log.date,
      content: log.content,
      tags: log.tags,
    );
  }
}