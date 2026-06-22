import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scalesync_pro_ecosystem/services/auth_service.dart';
import 'package:scalesync_pro_ecosystem/utils/theme.dart';
import 'package:scalesync_pro_ecosystem/features/ScaleSyncSocial/views/social_feed_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SocialLoginView — Monospace Geometric Shell
// Two distinct action paths:
//   1. SIGN_IN_WITH_ECOSYSTEM_ACCOUNT  → Firebase auth (shared ScaleSync project)
//   2. BROWSE_COMMUNITY_AS_GUEST       → Bypasses auth gate, opens SocialFeedView
// ─────────────────────────────────────────────────────────────────────────────
class SocialLoginView extends StatefulWidget {
  const SocialLoginView({super.key});

  @override
  State<SocialLoginView> createState() => _SocialLoginViewState();
}

class _SocialLoginViewState extends State<SocialLoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGuestLoading = false;
  String? _errorMessage;

  // Scan-line blink animation for the terminal cursor
  late AnimationController _cursorController;
  late Animation<double> _cursorOpacity;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _cursorOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cursorController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  // ── ACTION 1: SIGN_IN_WITH_ECOSYSTEM_ACCOUNT ─────────────────────────────
  Future<void> _signInWithEcosystemAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final auth = context.read<AuthService>();
      await auth.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SocialFeedView()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _parseError(e.toString());
      });
    }
  }

  // ── ACTION 2: BROWSE_COMMUNITY_AS_GUEST ───────────────────────────────────
  Future<void> _browseAsGuest() async {
    setState(() => _isGuestLoading = true);
    await Future.delayed(const Duration(milliseconds: 350)); // tactile pause
    if (!mounted) return;
    setState(() => _isGuestLoading = false);
    // Bypass the auth gate entirely — push SocialFeedView in view-only mode
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 480),
        pageBuilder: (_, animation, __) => const SocialFeedView(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  String _parseError(String raw) {
    if (raw.contains('user-not-found')) return 'ERR: USER_NOT_FOUND';
    if (raw.contains('wrong-password')) return 'ERR: INVALID_CREDENTIALS';
    if (raw.contains('invalid-email')) return 'ERR: MALFORMED_EMAIL';
    if (raw.contains('too-many-requests')) return 'ERR: RATE_LIMITED — try later';
    if (raw.contains('network-request-failed')) return 'ERR: NETWORK_TIMEOUT';
    return 'ERR: AUTH_FAILURE — check credentials';
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return Scaffold(
      backgroundColor: const Color(0xFF080A07),
      body: Stack(
        children: [
          // ── Background: dark radial orbs ──────────────────────────────
          Positioned(
            top: -200,
            left: -200,
            child: _buildOrb(500, const Color(0x1200D2FF)),
          ),
          Positioned(
            bottom: -200,
            right: -200,
            child: _buildOrb(600, const Color(0x1200E676)),
          ),

          // ── Subtle grid overlay ───────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // ── Decorative corner monospace labels ────────────────────────
          const Positioned(
            top: 24,
            left: 24,
            child: _CornerLabel('SYS::SCALESYNC_SOCIAL_v4.1'),
          ),
          const Positioned(
            top: 24,
            right: 24,
            child: _CornerLabel('PORT:8083 // SOCIAL'),
          ),
          const Positioned(
            bottom: 20,
            left: 24,
            child: _CornerLabel('© 2026 SCALESYNC_INC'),
          ),
          Positioned(
            bottom: 20,
            right: 24,
            child: AnimatedBuilder(
              animation: _cursorOpacity,
              builder: (_, __) => Opacity(
                opacity: _cursorOpacity.value,
                child: const _CornerLabel('█ READY'),
              ),
            ),
          ),

          // ── Main card ─────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 40,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: EdgeInsets.all(isMobile ? 28 : 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0F0B).withOpacity(0.88),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1E2619),
                            width: 1,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 36),
                              _buildDividerLabel('CREDENTIAL_BLOCK'),
                              const SizedBox(height: 16),
                              _buildEmailField(),
                              const SizedBox(height: 14),
                              _buildPasswordField(),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
                                _buildErrorBanner(_errorMessage!),
                              ],
                              const SizedBox(height: 28),

                              // ── ACTION PATH 1 ─────────────────────────
                              _buildPrimaryAction(),
                              const SizedBox(height: 20),

                              // ── Separator ─────────────────────────────
                              _buildOrSeparator(),
                              const SizedBox(height: 20),

                              // ── ACTION PATH 2 ─────────────────────────
                              _buildGuestAction(),
                              const SizedBox(height: 28),

                              // ── Footer links ──────────────────────────
                              _buildFooterLinks(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand row
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFA5E644).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: const Color(0xFFA5E644).withOpacity(0.4)),
              ),
              child: const Icon(Icons.drag_indicator,
                  size: 18, color: Color(0xFFA5E644)),
            ),
            const SizedBox(width: 10),
            const Text(
              'SCALESYNC_SOCIAL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Color(0xFFA5E644),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Module badge
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D16),
            borderRadius: BorderRadius.circular(4),
            border:
                Border.all(color: const Color(0xFF2E3229), width: 1),
          ),
          child: const Text(
            'MODULE::AUTH_GATEWAY',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.8,
              color: Color(0xFF5A6A52),
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Title
        const Text(
          'COMMUNITY\nACCESS PORTAL',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Authenticate with your ScaleSync ecosystem account or enter the herpetarium feed as a read-only guest.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF5A6A52),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.6,
            color: Color(0xFF3A4A34),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: const Color(0xFF1A1D16)),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMAIL_ADDRESS',
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.4,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A6A52),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'monospace',
          ),
          decoration: _monoInputDecoration('user@scalesync.com'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email required';
            if (!v.contains('@')) return 'Invalid format';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MASTER_KEY',
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.4,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A6A52),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'monospace',
          ),
          decoration: _monoInputDecoration('••••••••••••').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: const Color(0xFF5A6A52),
                size: 18,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password required';
            if (v.length < 6) return 'Min 6 characters';
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _monoInputDecoration(String hint) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Color(0xFF1E2619)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF3A4A34),
        fontSize: 14,
        fontFamily: 'monospace',
      ),
      filled: true,
      fillColor: const Color(0xFF0B0D09),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: border,
      enabledBorder: border,
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide:
            BorderSide(color: Color(0xFFA5E644), width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppTheme.dangerColor),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppTheme.dangerColor, width: 1.5),
      ),
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.dangerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.dangerColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.dangerColor, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: AppTheme.dangerColor,
                fontSize: 11,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ACTION PATH 1 — SIGN_IN_WITH_ECOSYSTEM_ACCOUNT
  Widget _buildPrimaryAction() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithEcosystemAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA5E644),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : const Text(
                'SIGN_IN_WITH_ECOSYSTEM_ACCOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                  fontFamily: 'monospace',
                ),
              ),
      ),
    );
  }

  Widget _buildOrSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: const Color(0xFF1A1D16)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF111309),
            borderRadius: BorderRadius.circular(4),
            border:
                Border.all(color: const Color(0xFF1E2619), width: 1),
          ),
          child: const Text(
            'OR',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: Color(0xFF3A4A34),
              fontFamily: 'monospace',
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: const Color(0xFF1A1D16)),
        ),
      ],
    );
  }

  /// ACTION PATH 2 — BROWSE_COMMUNITY_AS_GUEST
  Widget _buildGuestAction() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: _isGuestLoading ? null : _browseAsGuest,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF8A9A80),
          side: const BorderSide(color: Color(0xFF2E3229), width: 1),
          backgroundColor: const Color(0xFF0D0F0B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isGuestLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF8A9A80)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.public, size: 14, color: Color(0xFF5A6A52)),
                  SizedBox(width: 8),
                  Text(
                    'BROWSE_COMMUNITY_AS_GUEST',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                      color: Color(0xFF8A9A80),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        // Subtle descriptor for guest path
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0D09),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1A1D16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: Color(0xFF3A4A34)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GUEST access: view-only feed. Posting, messaging, and profile features require an authenticated ecosystem account.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3A4A34),
                    height: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'NO_ACCOUNT? ',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF3A4A34),
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Registration is handled by the shared Pro ecosystem screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Visit ScaleSync Pro to create an ecosystem account.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'REGISTER_ECOSYSTEM_ACCOUNT →',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA5E644),
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Corner label widget
// ─────────────────────────────────────────────────────────────────────────────
class _CornerLabel extends StatelessWidget {
  final String label;
  const _CornerLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 9,
        color: Color(0xFF2A3226),
        letterSpacing: 1.2,
        fontFamily: 'monospace',
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtle dot-grid background painter
// ─────────────────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1D16).withOpacity(0.5)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Dot intersections
    final dotPaint = Paint()
      ..color = const Color(0xFF2A3226).withOpacity(0.7)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
