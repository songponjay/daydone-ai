import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/ai_summary_service.dart';
import '../providers/ai_summary_provider.dart';
import '../providers/work_log_notifier.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProvider = ref.watch(selectedAiProviderProvider);
    final selectedPeriod = ref.watch(_selectedPeriodProvider);
    final isLoading = ref.watch(summaryLoadingProvider);
    final result = ref.watch(summaryResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI สรุปงาน')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown เลือก provider
            DropdownButtonFormField<AiProviderType>(
              initialValue: selectedProvider,
              decoration: const InputDecoration(labelText: 'AI Provider'),
              items: const [
                DropdownMenuItem(value: AiProviderType.gemini, child: Text('Gemini (ฟรี)')),
                DropdownMenuItem(value: AiProviderType.claude, child: Text('Claude')),
              ],
              onChanged: (v) => ref.read(selectedAiProviderProvider.notifier).state = v!,
            ),
            const SizedBox(height: 12),
            // Dropdown เลือก period
            DropdownButtonFormField<SummaryPeriod>(
              initialValue: selectedPeriod,
              decoration: const InputDecoration(labelText: 'ช่วงเวลา'),
              items: const [
                DropdownMenuItem(value: SummaryPeriod.weekly, child: Text('รายสัปดาห์')),
                DropdownMenuItem(value: SummaryPeriod.monthly, child: Text('รายเดือน')),
              ],
              onChanged: (v) => ref.read(_selectedPeriodProvider.notifier).state = v!,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isLoading ? null : () => _summarize(ref),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('สรุปงาน'),
            ),
            const SizedBox(height: 16),
            if (result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(result),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _summarize(WidgetRef ref) async {
    ref.read(summaryLoadingProvider.notifier).state = true;
    ref.read(summaryResultProvider.notifier).state = null;
    try {
      final logs = ref.read(workLogNotifierProvider).valueOrNull ?? [];
      final service = ref.read(aiSummaryServiceProvider);
      final period = ref.read(_selectedPeriodProvider);
      final result = await service.summarize(logs: logs, period: period);
      ref.read(summaryResultProvider.notifier).state = result;
    } catch (e) {
      ref.read(summaryResultProvider.notifier).state = 'เกิดข้อผิดพลาด: ${e.toString()}';
    } finally {
      ref.read(summaryLoadingProvider.notifier).state = false;
    }
  }
}

final _selectedPeriodProvider = StateProvider<SummaryPeriod>(
  (_) => SummaryPeriod.weekly,
);