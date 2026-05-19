import 'package:daydone_ai/domain/entities/work_log.dart';

abstract class WorkLogRepository {
  Future<List<WorkLog>> getAll();
  Future<WorkLog?> getById(int id);
  Future<void> save(WorkLog log);
  Future<void> delete(int id);
}

