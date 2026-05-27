import 'package:daydone_ai/presentation/providers/auth_notifier.dart';
import 'package:daydone_ai/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'presentation/screens/home_screen.dart';

void main() async {
  // init sqflite สำหรับ Windows/Linux/macOS
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await dotenv.load(fileName: '.env'); // โหลด .env ก่อน runApp

  runApp(const ProviderScope(child: MyApp()));
}

// ── Router Provider (ใช้ Ref ธรรมดา ไม่ใช่ WidgetRef) ──
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,         // แจ้ง router เมื่อ auth เปลี่ยน
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
    ],
  );
});

// ── Notifier สำหรับ GoRouter ──
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;   // Ref (provider) ใช้นอก build ได้ ต่างจาก WidgetRef

  _RouterNotifier(this._ref) {
    // listen authNotifierProvider → notify GoRouter ให้ re-evaluate redirect
    _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    if (authState.isLoading) return null;

    final isLoggedIn = authState.valueOrNull != null;
    final isOnLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (isLoggedIn && isOnLogin) return '/home';
    return null;
  }
}
// ── MyApp ──
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider); // ดึง router จาก provider

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'DayDone AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
/*
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final router = GoRouter(
      initialLocation: '/home',
      redirect: (context, state) {
        final authState = ref.read(authNotifierProvider);

        if (authState.isLoading) {
          return null; // รอให้ auth state โหลดเสร็จก่อนตัดสินใจ redirect
        }
        final isLoggedIn = authState.valueOrNull != null;
        final isOnLogin = state.matchedLocation == '/login';
        if (!isLoggedIn && isOnLogin) {
          return '/login';
        }
        if (isLoggedIn && isOnLogin) {
          return '/home';
        }
        return null;
      },
      refreshListenable: _AuthStateListenable(ref),
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DayDone AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}*/