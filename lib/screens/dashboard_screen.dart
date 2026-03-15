import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/dashboard/dashboard_widgets.dart';
import '../widgets/dashboard/keeper_management_sheets.dart';
import 'stock_management_screen.dart';
import 'staff_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final keepers = provider.keepers;
    final activeKeeper = keepers.isNotEmpty
        ? keepers.firstWhere(
            (k) => k.id == provider.activeKeeperId,
            orElse: () => keepers.first,
          )
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PILIH PENERIMA',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildAppIcon(),
              const SizedBox(height: 24),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 48),
              _buildMainContent(context, provider, activeKeeper),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.contain),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTitle() {
    return Text(
      'CEK TOKO MADURA',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
        color: Colors.white,
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSubtitle() {
    return const Text(
      'Audit stok sebelum ganti shift penjaga.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white70, fontSize: 16),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildMainContent(
    BuildContext context,
    StockProvider provider,
    dynamic activeKeeper,
  ) {
    if (provider.items.isEmpty) {
      return DashboardEmptyState(
        title: 'Belum Ada Barang',
        sub: 'Tambahkan barang toko terlebih dahulu untuk mulai audit.',
        icon: Icons.inventory_2_rounded,
        btnText: 'TAMBAH BARANG',
        onTap: () => _showProductList(context),
      );
    }

    if (activeKeeper == null) {
      return DashboardEmptyState(
        title: 'Belum Ada Akun',
        sub: 'Tambahkan akun (Penjaga Toko) terlebih dahulu di KELOLA AKUN.',
        icon: Icons.people_alt_rounded,
        btnText: 'TAMBAH AKUN',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          KeeperBox(
            label: 'Penjaga Lama (Yang Menyerahkan)',
            value: activeKeeper.name,
            icon: Icons.person_outline_rounded,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          _buildArrowIcon(),
          const SizedBox(height: 16),
          KeeperBox(
            label: 'Penjaga Baru (Yang Menerima)',
            value: 'Pilih Penjaga...',
            icon: Icons.person_add_alt_1_rounded,
            color: Colors.red,
            isAction: true,
            onTap: () => _showKeeperPicker(context),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0, delay: 400.ms, duration: 600.ms);
  }

  Widget _buildArrowIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_downward_rounded,
        color: Colors.red,
        size: 24,
      ),
    );
  }

  void _showKeeperPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => const KeeperPickerSheet(),
    );
  }

  void _showProductList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StockManagementScreen()),
    );
  }
}
