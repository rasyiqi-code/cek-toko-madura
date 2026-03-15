import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/trial_provider.dart';
import '../widgets/license/license_widgets.dart';

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
          const LicenseBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  LicenseHeader(isExpired: isExpired),
                  const SizedBox(height: 40),
                  TrialBadge(remainingDays: remainingDays, isExpired: isExpired),
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

  Widget _buildLicenseInput(TrialProvider trialProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Masukkan Kode Aktivasi...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF262626),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE53935), width: 2)),
                  errorText: _error,
                  prefixIcon: const Icon(Icons.vpn_key_rounded, color: Colors.white54, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56, width: 56,
              child: ElevatedButton(
                onPressed: trialProvider.isLoading ? null : () async {
                  setState(() => _error = null);
                  final key = _controller.text.trim();
                  if (key.isEmpty) { setState(() => _error = 'Kosong'); return; }
                  final success = await trialProvider.activateLicense(key);
                  if (!mounted) return;
                  if (!success) setState(() => _error = 'Invalid');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4, padding: EdgeInsets.zero, shadowColor: const Color(0xFFE53935).withValues(alpha: 0.4),
                ),
                child: trialProvider.isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
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
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        const BenefitItem(icon: Icons.cloud_done_rounded, title: 'Sinkronisasi Cloud', desc: 'Data Anda aman tersimpan di cloud selamanya.'),
        const BenefitItem(icon: Icons.analytics_rounded, title: 'Laporan Lengkap', desc: 'Akses seluruh modul laporan tanpa batasan.'),
        const BenefitItem(icon: Icons.update_rounded, title: 'Update Berkala', desc: 'Dapatkan fitur terbaru dan perbaikan sistem.'),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildSupportSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF262626), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(
        children: [
          Text('Belum memiliki lisensi?', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          _whatsAppButton(),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _whatsAppButton() {
     return InkWell(
      onTap: () async {
        final uri = Uri.parse('https://wa.me/6285183131249?text=Halo%20Admin,%20saya%20ingin%20membeli%20lisensi%20Cek%20Toko%20Madura');
        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 22),
            const SizedBox(width: 10),
            Text('Beli Lisensi Via WhatsApp', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF25D366), fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
