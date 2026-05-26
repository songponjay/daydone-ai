import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/claude_ai_service.dart';
import '../../data/services/gemini_ai_service.dart';
import '../../domain/services/ai_summary_service.dart';

enum AiProviderType { claude, gemini }

final selectedAiProviderProvider = StateProvider<AiProviderType>(
  (_) => AiProviderType.gemini, // default ใช้ Gemini
);

final _dioProvider = Provider<Dio>((_) => Dio());

final aiSummaryServiceProvider = Provider<AiSummaryService>((ref) {
  final type = ref.watch(selectedAiProviderProvider);
  final dio = ref.read(_dioProvider);
  return switch (type) {
    AiProviderType.claude => ClaudeAiService(dio),
    AiProviderType.gemini => GeminiAiService(dio),
  };
});

final summaryResultProvider = StateProvider<String?>((ref) => null);

final summaryLoadingProvider = StateProvider<bool>((ref) => false);