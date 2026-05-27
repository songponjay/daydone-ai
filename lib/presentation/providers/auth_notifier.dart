import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daydone_ai/domain/entities/app_user.dart';
import 'package:daydone_ai/domain/repositories/auth_repository.dart';
import 'package:daydone_ai/data/repositories/mock_auth_repository.dart';

// Provider ของ Repository — ตรงนี้แหละที่วันนึง swap Mock → Firebase
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(); // ← แค่เปลี่ยนบรรทัดนี้ก็พอ!
});

// Provider ของ Notifier
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AppUser?>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<AppUser?> {
  StreamSubscription<AppUser?>? _subscription;

  @override
  Future<AppUser?> build() async {
    final repo = ref.read(authRepositoryProvider);

    // cleanup Stream เมื่อ provider ถูก dispose (ป้องกัน memory leak)
    ref.onDispose(() => _subscription?.cancel());

    // ฟัง authStateChanges — อัปเดต state ทันทีเมื่อ login/logout
    _subscription = repo.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });

    // ตรวจว่าตอนนี้ login อยู่ไหม (กรณีออกแอพแล้วเข้าใหม่)
    return repo.getCurrentUser();
  }

  // เรียกจาก LoginScreen
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading(); // แสดง loading ขณะรอ
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          ),
    );
  }

  // เรียกจาก AppBar logout button
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}