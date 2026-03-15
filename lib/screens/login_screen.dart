import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _storeName = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _storeName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 48),
              Text(
                'AUTHENTICATION',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRegistering ? 'BUAT TOKO BARU' : 'MASUK KE TOKO',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 40),
              if (_isRegistering) ...[
                _buildField(_storeName, 'NAMA TOKO', Icons.store_rounded),
                const SizedBox(height: 16),
              ],
              _buildField(_email, 'EMAIL', Icons.email_rounded),
              const SizedBox(height: 16),
              _buildField(_password, 'PASSWORD', Icons.lock_rounded, isPassword: true),
              const SizedBox(height: 32),
              _buildSubmitButton(provider),
              const SizedBox(height: 24),
              _buildToggleMode(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(StockProvider provider) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : () => _handleAuth(provider),
        child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                _isRegistering ? 'DAFTAR TOKO' : 'MASUK',
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
      ),
    );
  }

  Widget _buildToggleMode() {
    return TextButton(
      onPressed: () => setState(() => _isRegistering = !_isRegistering),
      child: Text(
        _isRegistering ? 'Sudah punya toko? Masuk di sini' : 'Belum punya toko? Daftar Toko & Admin',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15),
      ),
    );
  }

  Future<void> _handleAuth(StockProvider provider) async {
    if (_email.text.isEmpty || _password.text.isEmpty) return;
    if (_isRegistering && _storeName.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await provider.registerAdmin(_email.text, _password.text, _storeName.text);
      } else {
        await provider.loginAccount(_email.text, _password.text);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String message = 'Autentikasi Gagal';
        if (e.toString().contains('invalid-credential')) {
          message = 'Email atau Password salah.';
        } else if (e.toString().contains('user-not-found')) {
          message = 'Akun tidak ditemukan.';
        } else if (e.toString().contains('wrong-password')) {
          message = 'Password salah.';
        } else if (e.toString().contains('email-already-in-use')) {
          message = 'Email sudah terdaftar.';
        } else {
          message = e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : e.toString();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
