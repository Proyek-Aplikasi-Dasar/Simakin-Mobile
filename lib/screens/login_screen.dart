import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// LoginScreen — Halaman login yang terhubung ke API BE (Laravel Sanctum).
///
/// Fitur:
/// - Animated gradient background
/// - Shake animation saat login gagal
/// - Integrasi penuh ke AuthProvider (token tersimpan EncryptedSharedPreferences)
/// - "Lupa password" placeholder untuk koordinasi offline
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Entry fade + slide animation
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Shake animation untuk error
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  // Animated gradient background
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: 0.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.linear));

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    _shakeController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    context.read<AuthProvider>().clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    // Jika gagal → shake form + tampilkan error dari provider
    // Jika sukses → GoRouter redirect ke /home via refreshListenable
    if (!success && mounted) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isLoading = authProvider.isLoading;
    final String? errorMessage = authProvider.errorMessage;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          final t = _bgController.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                      const Color(0xFF0D47A1), const Color(0xFF1565C0), t)!,
                  Color.lerp(
                      const Color(0xFF1A56DB), const Color(0xFF0288D1), t)!,
                  Color.lerp(
                      const Color(0xFF1565C0), const Color(0xFF1A237E), t)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            _buildDecorativeCircles(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogoSection(),
                          const SizedBox(height: 36),
                          AnimatedBuilder(
                            animation: _shakeAnim,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(_shakeAnim.value, 0),
                              child: child,
                            ),
                            child: _buildFormCard(isLoading, errorMessage),
                          ),
                          const SizedBox(height: 24),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Decorative Background Circles ────────────────────────────────────────
  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -40,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: -90,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Logo + App Name ────────────────────────────────────────────────────
  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 46,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SimakIn',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistem Informasi PKL • SMKN 1 Magelang',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.white.withValues(alpha: 0.75),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ─── Form Card ──────────────────────────────────────────────────────────
  Widget _buildFormCard(bool isLoading, String? errorMessage) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Card Header ──────────────────────────────────────────────
              const Text(
                'Masuk ke Akun',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gunakan email & password yang terdaftar di SMKN 1 Magelang',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // ── Error Banner ─────────────────────────────────────────────
              if (errorMessage != null) ...[
                _buildErrorBanner(errorMessage),
                const SizedBox(height: 16),
              ],

              // ── Email Field ──────────────────────────────────────────────
              TextFormField(
                key: const Key('login_email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                onChanged: (_) => context.read<AuthProvider>().clearError(),
                decoration: _inputDecoration(
                  label: 'Email',
                  hint: 'siswa@smkn1magelang.sch.id',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Password Field ───────────────────────────────────────────
              TextFormField(
                key: const Key('login_password_field'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                onFieldSubmitted: (_) => isLoading ? null : _handleLogin(),
                onChanged: (_) => context.read<AuthProvider>().clearError(),
                decoration: _inputDecoration(
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // ── Remember Me & Lupa Password ──────────────────────────────
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: isLoading
                          ? null
                          : (v) =>
                              setState(() => _rememberMe = v ?? false),
                      activeColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Ingat saya',
                      style: TextStyle(
                          fontSize: 12.5, color: Colors.grey.shade600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Hubungi koordinator PKL untuk reset password.'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                    child: const Text(
                      'Lupa password?',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // ── Login Button ─────────────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  key: const Key('login_button'),
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF1565C0).withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            key: ValueKey('label'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFD32F2F), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFD32F2F),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Footer ─────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'SimakIn v1.0 • SMKN 1 Magelang',
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Masalah login? Hubungi Tim IT Sekolah',
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}