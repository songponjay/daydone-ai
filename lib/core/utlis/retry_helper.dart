// โครงให้ดู
Future<T> withRetry<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
}) async {
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();       // ลองทำ
    } catch (e) {
      if (attempt == maxAttempts) rethrow;  // ครบรอบแล้ว던ออกไป
      await Future.delayed(Duration(seconds: attempt)); // ← รอนานขึ้นทุกรอบ ใช้ attempt ยังไง?
    }
  }
  throw Exception('unreachable');
}