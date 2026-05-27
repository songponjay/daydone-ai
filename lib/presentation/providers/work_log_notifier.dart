import 'package:daydone_ai/data/datasources/work_log_local_datasource.dart';
import 'package:daydone_ai/data/datasources/work_log_remote_datasource.dart';
import 'package:daydone_ai/data/repositories/work_log_repository_impl.dart';
import 'package:daydone_ai/domain/repositories/work_log_repository.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/work_log.dart';

part 'work_log_notifier.g.dart';

// ใช้แบบนี้แทน — ไม่ต้อง build_runner
final workLogLocalDatasourceProvider = Provider<WorkLogLocalDatasource>((ref) {
  return WorkLogLocalDatasource();
});

final workLogRemoteDatasourceProvider = Provider<WorkLogRemoteDatasource>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com')); // ← กำหนด base URL ของ API
  return WorkLogRemoteDatasource(dio);
});

final workLogRepositoryProvider = Provider<WorkLogRepository>((ref) {
  final local = ref.watch(workLogLocalDatasourceProvider);
  final remote = ref.watch(workLogRemoteDatasourceProvider); // ← รับ remote datasource ด้วย
  return WorkLogRepositoryImpl(local, remote); // ← ส่งทั้ง local และ remote ไปที่ repository
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

  Future<void> saveLog(WorkLog log) async {
  // set loading ระหว่างบันทึก
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // repository.save() ใช้ ConflictAlgorithm.replace
      // → ถ้ามี id เดิม = UPDATE, ถ้า id null = INSERT
      await ref.read(workLogRepositoryProvider).save(log);

      // โหลด list ใหม่หลังบันทึก
      return ref.read(workLogRepositoryProvider).getAll();
    });
  }

  Future<void> deleteLog(int id) async {
    final repo = ref.read(workLogRepositoryProvider);
    await repo.delete(id);      // ลบจาก SQLite
    ref.invalidateSelf();       // โหลด list ใหม่
  }
}
