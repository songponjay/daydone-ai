import 'dart:async';
import 'package:daydone_ai/domain/entities/app_user.dart';
import 'package:daydone_ai/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  
  // StreamController คือ "ท่อ" ที่เราจะส่ง event login/logout เข้าไป
  // broadcast = หลาย listener ฟังได้พร้อมกัน
  final _controller = StreamController<AppUser?>.broadcast();
  
  // เก็บ user ปัจจุบันไว้ใน memory
  AppUser? _currentUser;

  @override
  Future<AppUser?> getCurrentUser() async {
    // คืนค่า user ที่ login อยู่ (null = ยังไม่ได้ login)
    return _currentUser;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    // จำลอง network delay 1 วิ (ของจริงก็ใช้เวลาแบบนี้)
    await Future.delayed(const Duration(seconds: 1));

    // ตรวจ credentials — hardcode ไว้สำหรับ demo
    if (email == 'demo@test.com' && password == '1234') {
      _currentUser = const AppUser(
        id: '1',
        name: 'Demo User',
        email: 'demo@test.com',
      );
      // แจ้ง Stream ว่ามี user login แล้ว
      _controller.add(_currentUser);
      return _currentUser!;
    }

    // credentials ผิด →던 exception ให้ AuthNotifier จัดการต่อ
    throw Exception('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    // แจ้ง Stream ว่า logout แล้ว (ส่ง null)
    _controller.add(null);
  }

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;
}