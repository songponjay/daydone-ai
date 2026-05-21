import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/work_log.dart';

part 'work_log_notifier.g.dart';

@riverpod
class WorkLogNotifier extends _$WorkLogNotifier {
  @override
  Future<List<WorkLog>> build() async {
    return [
      WorkLog(
        id: '1',
        date: DateTime(2026, 5, 21),
        content: 'ทำ Clean Architecture scaffold เสร็จ',
        tags: ['flutter', 'architecture'],
      ),
      WorkLog(
        id: '2',
        date: DateTime(2026, 5, 20),
        content: 'เรียน Riverpod AsyncNotifier',
        tags: ['riverpod', 'state'],
      ),
      WorkLog(
        id: '3',
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

  Future<void> deleteLog(String id) async {
    final current = await future;
    state = AsyncData(current.where((log) => log.id != id).toList());
  }
}
