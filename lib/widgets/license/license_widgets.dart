import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class LicenseBackground extends StatelessWidget {
  const LicenseBackground({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class LicenseHeader extends StatelessWidget {
  final bool isExpired;
  const LicenseHeader({super.key, required this.isExpired});

  @override
  Widget build(BuildContext context) {
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
}

class TrialBadge extends StatelessWidget {
  final int remainingDays;
  final bool isExpired;

  const TrialBadge({super.key, required this.remainingDays, required this.isExpired});

  @override
  Widget build(BuildContext context) {
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
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }
}

class BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const BenefitItem({super.key, required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
