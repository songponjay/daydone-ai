import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/work_log.dart';
import '../../domain/services/ai_summary_service.dart';

class GeminiAiService implements AiSummaryService {
  final Dio _dio;
  GeminiAiService(this._dio);

  @override
  Future<String> summarize({
    required List<WorkLog> logs,
    required SummaryPeriod period,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    final response = await _dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/gemma-4-31b-it:generateContent?key=$apiKey',
      data: {
        'contents': [
          {'parts': [{'text': _buildPrompt(logs, period)}]},
        ],
      },
    );
    return response.data['candidates'][0]['content']['parts'][0]['text'] as String;
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