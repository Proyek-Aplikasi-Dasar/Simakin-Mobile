import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/pengajuan_provider.dart';
import 'providers/presensi_provider.dart';
import 'router/app_router.dart';

void main() async {
  // Wajib dipanggil sebelum menggunakan plugin (FlutterSecureStorage, dll)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PengajuanProvider()),
        ChangeNotifierProvider(create: (_) => PresensiProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appRouter = AppRouter(authProvider).router;

    return MaterialApp.router(
      title: 'SimakIn — SMKN 1 Magelang',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A56DB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Terapkan Poppins sebagai font global
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}