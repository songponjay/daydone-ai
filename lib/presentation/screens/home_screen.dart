import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/work_log.dart';
import '../providers/work_log_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(workLogNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('DayDone AI')),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('โหลดไม่ได้: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(workLogNotifierProvider),
                child: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
        data: (logs) => logs.isEmpty
            ? const Center(child: Text('ยังไม่มี log — กด + เพื่อเพิ่ม'))
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text(log.content),
                      subtitle: Text(
                        '${log.date.day}/${log.date.month}/${log.date.year}  •  ${log.tags.join(', ')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(workLogNotifierProvider.notifier)
                            .deleteLog(log.id),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMockLog(ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addMockLog(WidgetRef ref) {
    final log = WorkLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      content: 'log ใหม่ ${DateTime.now().hour}:${DateTime.now().minute}',
      tags: ['new'],
    );
    ref.read(workLogNotifierProvider.notifier).addLog(log);
  }
}
