import 'package:daydone_ai/data/datasources/work_log_local_datasource.dart';
import 'package:daydone_ai/data/repositories/work_log_repository_impl.dart';
import 'package:daydone_ai/domain/repositories/work_log_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/work_log.dart';

part 'work_log_notifier.g.dart';

// ใช้แบบนี้แทน — ไม่ต้อง build_runner
final workLogLocalDatasourceProvider = Provider<WorkLogLocalDatasource>((ref) {
  return WorkLogLocalDatasource();
});

final workLogRepositoryProvider = Provider<WorkLogRepository>((ref) {
  final datasource = ref.watch(workLogLocalDatasourceProvider);
  return WorkLogRepositoryImpl(datasource);
});

@riverpod
class WorkLogNotifier extends _$WorkLogNotifier {
  @override
Future<List<WorkLog>> build() async {
  final repo = ref.watch(workLogRepositoryProvider);
  return repo.getAll();
}
  /*
  @override
  Future<List<WorkLog>> build() async {
    return [
      WorkLog(
        id: 1,
        date: DateTime(2026, 5, 21),
        content: 'ทำ Clean Architecture scaffold เสร็จ',
        tags: ['flutter', 'architecture'],
      ),
      WorkLog(
        id: 2,
        date: DateTime(2026, 5, 20),
        content: 'เรียน Riverpod AsyncNotifier',
        tags: ['riverpod', 'state'],
      ),
      WorkLog(
        id: 3,
        date: DateTime(2026, 5, 19),
        content: 'สร้าง WorkLog entity และ Repository',
        tags: ['domain', 'entity'],
      ),
    ];
  }

  Future<void> addLog(WorkLog log) async {
    final current = await future;
    state = AsyncData([log, ...current]);
  }

  Future<void> deleteLog(int id) async {
    final current = await future;
    state = AsyncData(current.where((log) => log.id != id).toList());
  }
  */
  Future<void> addLog(WorkLog log) async {
    final repo = ref.read(workLogRepositoryProvider);
    await repo.save(log);       // บันทึกลง SQLite จริงๆ
    ref.invalidateSelf();       // โหลด list ใหม่จาก DB (id ถูกต้อง)
  }

  Future<void> deleteLog(int id) async {
    final repo = ref.read(workLogRepositoryProvider);
    await repo.delete(id);      // ลบจาก SQLite
    ref.invalidateSelf();       // โหลด list ใหม่
  }
}
