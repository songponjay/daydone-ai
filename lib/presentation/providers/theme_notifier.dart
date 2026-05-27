import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider สำหรับ SharedPreferences instance
// ต้องสร้างก่อน app start (จะ override ใน main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // จะถูก override ใน main.dart
});

// ThemeModeNotifier — จำ theme ให้ + เซฟลง SharedPreferences
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    // อ่านค่าที่เซฟไว้ ถ้าไม่มีให้ใช้ system default
    final saved = prefs.getString(_key) ?? 'system';
    return ThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  void toggle() {
    // สลับ dark ↔ light
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    // เซฟลง SharedPreferences ทันที
    ref.read(sharedPreferencesProvider).setString(_key, state.name);
  }
}

final themeModeNotifierProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);