import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/trial_provider.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final trialProvider = context.watch<TrialProvider>();
    final isExpired = !trialProvider.isTrialActive;
    final remainingDays = trialProvider.remainingDays;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(isExpired),
                  const SizedBox(height: 40),
                  _buildTrialBadge(remainingDays, isExpired),
                  const SizedBox(height: 32),
                  _buildLicenseInput(trialProvider),
                  const SizedBox(height: 40),
                  _buildBenefitsSection(),
                  const SizedBox(height: 40),
                  _buildSupportSection(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121212), Color(0xFF1A1A1A)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE53935).withValues(alpha: 0.05),
              ),
            ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.8, 0.8)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE53935).withValues(alpha: 0.03),
              ),
            ).animate().fadeIn(duration: 1200.ms, delay: 200.ms).scale(begin: const Offset(0.7, 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isExpired) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE53935).withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.lock_person_rounded,
            size: 60,
            color: Color(0xFFE53935),
          ),
        )
        .animate()
        .scale(duration: 600.ms, curve: Curves.bounceOut)
        .shimmer(delay: 1.seconds, duration: 2.seconds),
        const SizedBox(height: 24),
        Text(
          isExpired ? 'Masa Percobaan Berakhir' : 'Lisensi Diperlukan',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            isExpired
                ? 'Masa gratis 14 hari Anda telah habis. Masukkan kode lisensi untuk melanjutkan semua fitur premium.'
                : 'Aplikasi ini memerlukan lisensi aktif. Masukkan kode lisensi Anda di bawah ini untuk aktivasi selamanya.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildTrialBadge(int remainingDays, bool isExpired) {
    if (isExpired) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(
            'Sisa Masa Percobaan: $remainingDays Hari',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.orange,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildLicenseInput(TrialProvider trialProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan Kode Aktivasi...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF262626),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE53935),
                      width: 2,
                    ),
                  ),
                  errorText: _error,
                  prefixIcon: const Icon(
                    Icons.vpn_key_rounded,
                    color: Colors.white54,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              width: 56,
              child: ElevatedButton(
                onPressed: trialProvider.isLoading
                    ? null
                    : () async {
                        if (mounted) {
                          setState(() => _error = null);
                        }
                        final key = _controller.text.trim();
                        if (key.isEmpty) {
                          if (mounted) {
                            setState(() => _error = 'Kosong');
                          }
                          return;
                        }

                        final success = await trialProvider.activateLicense(key);
                        if (!mounted) {
                          return;
                        }

                        if (!success && mounted) {
                          setState(() => _error = 'Invalid');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  padding: EdgeInsets.zero,
                  shadowColor: const Color(0xFFE53935).withValues(alpha: 0.4),
                ),
                child: trialProvider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 28),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mengapa Perlu Aktivasi?',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        _buildBenefitItem(
          Icons.cloud_done_rounded,
          'Sinkronisasi Cloud',
          'Data Anda aman tersimpan di cloud selamanya.',
        ),
        _buildBenefitItem(
          Icons.analytics_rounded,
          'Laporan Lengkap',
          'Akses seluruh modul laporan tanpa batasan.',
        ),
        _buildBenefitItem(
          Icons.update_rounded,
          'Update Berkala',
          'Dapatkan fitur terbaru dan perbaikan sistem.',
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildBenefitItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFE53935), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            'Belum memiliki lisensi?',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final uri = Uri.parse(
                  'https://wa.me/6285183131249?text=Halo%20Admin,%20saya%20ingin%20membeli%20lisensi%20Cek%20Toko%20Madura',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Beli Lisensi Via WhatsApp',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF25D366),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

