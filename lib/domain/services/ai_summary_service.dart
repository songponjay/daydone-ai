// domain/services/ai_summary_service.dart
import 'package:daydone_ai/domain/entities/work_log.dart';

enum SummaryPeriod { weekly, monthly }

abstract class AiSummaryService {
  Future<String> summarize({
    required List<WorkLog> logs,
    required SummaryPeriod period,
  });
}