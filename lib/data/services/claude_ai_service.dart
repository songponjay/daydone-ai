// lib/data/services/claude_ai_service.dart
import 'package:daydone_ai/domain/entities/work_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/services/ai_summary_service.dart';

class ClaudeAiService implements AiSummaryService {
  final Dio _dio;
  ClaudeAiService(this._dio);

  @override
  Future<String> summarize({
    required List<WorkLog> logs,
    required SummaryPeriod period,
  }) async {
    final response = await _dio.post(
      'https://api.anthropic.com/v1/messages',
      options: Options(headers: {
        'x-api-key': dotenv.env['CLAUDE_API_KEY']!,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      }),
      data: {
        'model': 'claude-sonnet-4-6',
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': _buildPrompt(logs, period)},
        ],
      },
    );
    return response.data['content'][0]['text'] as String;
  }

  String _buildPrompt(List<WorkLog> logs, SummaryPeriod period) {
    final periodTh = period == SummaryPeriod.weekly ? 'สัปดาห์' : 'เดือน';
    final logText = logs.map((l) => '- ${l.date}: ${l.content}').join('\n');
    return 'สรุปงานประจำ$periodTh จาก work log ต่อไปนี้เป็นภาษาไทย:\n'
        '- เน้น accomplishments และ impact\n'
        '- ระบุ blockers หรือปัญหาที่พบ\n'
        '- ความยาว 3-5 ย่อหน้า\n\n'
        'Work Logs:\n$logText';
  }
}