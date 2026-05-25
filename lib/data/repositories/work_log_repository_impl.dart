import 'package:daydone_ai/data/datasources/work_log_local_datasource.dart';
import 'package:daydone_ai/data/models/work_log_model.dart';
import 'package:daydone_ai/domain/entities/work_log.dart';
import 'package:daydone_ai/domain/repositories/work_log_repository.dart';

class WorkLogRepositoryImpl implements WorkLogRepository {
  final WorkLogLocalDatasource _local;

  WorkLogRepositoryImpl(this._local); // ← รับ datasource เข้ามา

  @override
  Future<List<WorkLog>> getAll() async {
    final models = await _local.getAll();
    return models.map((m) => m.toDomain()).toList(); // Model → Entity
  }

  @override
  Future<WorkLog?> getById(int id) async {
    final all = await _local.getAll();
    try {
      return all.firstWhere((m) => m.id == id).toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(WorkLog log) async {
    await _local.save(WorkLogModel.fromDomain(log)); // Entity → Model
  }

  @override
  Future<void> delete(int id) async {
    await _local.delete(id);
  }
}