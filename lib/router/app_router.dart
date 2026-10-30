import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/main_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/pengajuan_screen.dart';

/// AppRouter — Konfigurasi routing GoRouter dengan route guard berbasis auth.
///
/// Route guard memantau [AuthProvider] via refreshListenable sehingga
/// navigasi terjadi otomatis tanpa manual push.
class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,

    // ─── ROUTE GUARD ──────────────────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      if (!authProvider.isInitialized) return '/splash';

      final bool isLoggedIn = authProvider.isAuthenticated;
      final String currentPath = state.matchedLocation;

      final bool isOnSplash = currentPath == '/splash';
      final bool isOnLogin = currentPath == '/login';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && (isOnLogin || isOnSplash)) return '/home';

      return null;
    },

    // ─── ROUTES ───────────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/pengajuan',
        name: 'pengajuan',
        builder: (context, state) {
          // Support deep link / pre-fill dari halaman daftar perusahaan
          final perusahaan = state.uri.queryParameters['perusahaan'];
          final alamat = state.uri.queryParameters['alamat'];
          final bidang = state.uri.queryParameters['bidang'];
          final kontak = state.uri.queryParameters['kontak'];
          final telepon = state.uri.queryParameters['telepon'];
          return PengajuanScreen(
            initialPerusahaan: perusahaan,
            initialAlamat: alamat,
            initialBidangUsaha: bidang,
            initialKontak: kontak,
            initialTelepon: telepon,
          );
        },
      ),
      GoRoute(
        path: '/pengajuan/status',
        name: 'status-pengajuan',
        builder: (context, state) {
          // Dukung ?tab=0 (Daftar Perusahaan) atau ?tab=1 (Status Pengajuan)
          final tabParam = state.uri.queryParameters['tab'];
          final tabIndex = int.tryParse(tabParam ?? '') ?? 0;
          return StatusPengajuanScreen(initialTabIndex: tabIndex);
        },
      ),
    ],

    // ─── ERROR PAGE ────────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Kembali ke Home'),
            ),
          ],
        ),
      ),
    ),
  );
}