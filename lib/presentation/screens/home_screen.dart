import 'package:daydone_ai/presentation/providers/auth_notifier.dart';
import 'package:daydone_ai/presentation/providers/theme_notifier.dart';
import 'package:daydone_ai/presentation/screens/export_screen.dart';
import 'package:daydone_ai/presentation/screens/summary_screen.dart';
import 'package:daydone_ai/presentation/screens/work_log_form_screen.dart';
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
      appBar: AppBar(title: const Text('DayDone AI'),
        actions: [
          //ปุ่ม toggle theme (dark/light)
          IconButton(
            icon: Icon(ref.watch(themeModeNotifierProvider) == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            ), // เปลี่ยน icon ตาม theme ปัจจุบัน

            tooltip: 'เปลี่ยนธีม',
            onPressed: () => ref.read(themeModeNotifierProvider.notifier).toggle(),
          ),

          IconButton(
            icon: const Icon(Icons.summarize),
            tooltip: 'AI สรุปงาน',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SummaryScreen()),
            ),
          ),
          // ✅ เพิ่มปุ่ม Export ต่อท้าย
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Excel',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExportScreen()),
            ),
          ),
          // ปุ่ม Logout มุมขวาบน
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              // GoRouter จะ redirect ไป /login อัตโนมัติ
              // ไม่ต้อง context.go('/login') เอง!
            },
          ),
        ],
      ),
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
                            .deleteLog(log.id!),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WorkLogFormScreen(workLog: log),// Edit mode
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        //onPressed: () => _addMockLog(ref),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorkLogFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addMockLog(WidgetRef ref) {
    final log = WorkLog(
      id:null, // ID จะถูกกำหนดโดยฐานข้อมูลเมื่อบันทึก log ใหม่
      //id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      content: 'log ใหม่ ${DateTime.now().hour}:${DateTime.now().minute}',
      tags: ['new'],
    );
    ref.read(workLogNotifierProvider.notifier).addLog(log);
  }
}
