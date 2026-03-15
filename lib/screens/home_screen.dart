import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'stock_management_screen.dart';
import 'audit_session_screen.dart';
import '../providers/stock_provider.dart';
import '../providers/trial_provider.dart';
import '../models/app_user.dart';
import 'staff_management_screen.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final trial = Provider.of<TrialProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _showTrialInfo(context, trial),
          icon: Icon(
            trial.isLicensed
                ? Icons.verified_rounded
                : Icons.help_outline_rounded,
            color: trial.isLicensed ? Colors.greenAccent : Colors.white54,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context, provider),
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white24,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  _buildHeader(provider),
                  const SizedBox(height: 40),
                  if (provider.currentUser?.role == UserRole.pengecek) ...[
                    _buildMenuButton(
                          context,
                          title: 'CEK STOK',
                          subtitle: 'Audit stok & ganti shift',
                          icon: Icons.inventory_rounded,
                          color: const Color(0xFFE53935),
                          onTap: () {
                            final draftToKeeperId =
                                provider.auditDraftToKeeperId;

                            if (provider.auditDraftResults.isNotEmpty &&
                                draftToKeeperId != null) {
                              final matchingKeepers = provider.keepers.where(
                                (k) => k.id == draftToKeeperId,
                              );
                              final toKeeper = matchingKeepers.isNotEmpty
                                  ? matchingKeepers.first
                                  : (provider.keepers.isNotEmpty
                                        ? provider.keepers.first
                                        : null);

                              if (toKeeper != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AuditSessionPage(toKeeper: toKeeper),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                );
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DashboardScreen(),
                                ),
                              );
                            }
                          },
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                          context,
                          title: 'REKAP LAPORAN',
                          subtitle: 'Lihat hasil cek sebelumnya',
                          icon: Icons.history_edu_rounded,
                          color: const Color(0xFF1E88E5),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),
                  ],
                  _buildMenuButton(
                    context,
                    title: 'DATA BARANG',
                    subtitle: 'Kelola daftar & harga stok',
                    icon: Icons.grid_view_rounded,
                    color: const Color(0xFF43A047),
                    onTap: () {
                      if (provider.currentUser?.role != UserRole.pengecek) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Hanya Pengecek yang bisa kelola data barang.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StockManagementScreen(),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                  if (provider.currentUser?.id == provider.storeId) ...[
                    const SizedBox(height: 20),
                    _buildMenuButton(
                          context,
                          title: 'KELOLA AKUN',
                          subtitle: 'Tambah & atur akun baru',
                          icon: Icons.people_alt_rounded,
                          color: Colors.amber,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StaffManagementScreen(),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                  const SizedBox(height: 40),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE53935).withValues(alpha: 0.03),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(StockProvider provider) {
    return Column(
      children: [
        Container(
          width: 110, // Increased size
          height: 110, // Increased size
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Removed red background color
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5), // More visible border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.contain),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 28),
        Text(
          'CEK TOKO MADURA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            provider.storeName?.toUpperCase() ?? 'TOKO MADURA',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (provider.isFirebaseSyncing)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              )
            else
              Icon(
                Icons.cloud_done_rounded,
                size: 16,
                color: provider.lastFirebaseSync != null
                    ? Colors.green
                    : Colors.grey,
              ),
            const SizedBox(width: 8),
            Text(
              provider.isFirebaseSyncing ? 'SYNCING...' : 'CLOUD SYNC',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (provider.lastFirebaseSync != null) ...[
              const SizedBox(width: 12),
              Text(
                'LAST: ${DateFormat('HH:mm').format(provider.lastFirebaseSync!)}',
                style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              ),
            ],
          ],
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 12),
        if (provider.currentUser != null)
          Text(
            'Halo, ${provider.currentUser!.id == provider.storeId ? "Juragan" : provider.currentUser!.name} (${provider.currentUser!.id == provider.storeId ? "Owner" : (provider.currentUser!.role == UserRole.pengecek ? "Pengecek" : "Penjaga")})',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return InkWell(
      onTap: () => launchUrl(Uri.parse('https://crediblemark.com')),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'v1.0.0 • crediblemark.com',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white.withValues(alpha: 0.1),
          ),
        ).animate().fadeIn(delay: 800.ms),
      ),
    );
  }

  void _showTrialInfo(BuildContext context, TrialProvider trial) {
    if (!trial.isLicensed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masa Percobaan: sisa ${trial.remainingDays} hari lagi',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF262626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _handleLogout(BuildContext context, StockProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD32F2F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        title: const Text('Keluar Akun?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Anda akan keluar dari sesi ini.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () {
              provider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('KELUAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
