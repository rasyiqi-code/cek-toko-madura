import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../models/handover_report.dart';

class ReportDetailScreen extends StatelessWidget {
  final HandoverReport report;

  const ReportDetailScreen({super.key, required this.report});

  void _share() {
    final net = report.surplus - report.deficit;
    final cur = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    String message = "📊 *LAPORAN PENGECEKAN TOKO*\n";
    message += "📅 ${report.date}\n";
    message += "🚨 *PENANGGUNG JAWAB: ${report.fromKeeper}*\n";
    message += "👁️ Saksi/Penerima: ${report.toKeeper}\n\n";
    
    if (report.details.isNotEmpty) {
      message += "*RINCIAN SELISIH:*\n";
      for (var d in report.details) {
        message += "• $d\n";
      }
      message += "\n";
    }
    
    message += "*TOTAL SELISIH: ${cur.format(net)}*";
    
    SharePlus.instance.share(ShareParams(text: message));
  }

  @override
  Widget build(BuildContext context) {
    final cur = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final net = report.surplus - report.deficit;
    final isNegative = net < 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isNegative ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                      Colors.black,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text('TOTAL SELISIH', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text(
                        cur.format(net),
                        style: GoogleFonts.plusJakartaSans(
                          color: isNegative ? Colors.red : (net > 0 ? Colors.green : Colors.grey),
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(onPressed: _share, icon: const Icon(Icons.share_rounded, color: Colors.white)),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaData(context),
                  const SizedBox(height: 40),
                  Text('DETAIL BARANG', style: GoogleFonts.plusJakartaSans(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  if (report.details.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('Semua barang sesuai stok', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ...report.details.asMap().entries.map((entry) {
                      return _buildDetailItem(entry.value, entry.key);
                    }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaData(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _metaRow(Icons.calendar_today_rounded, 'Waktu Cek', report.date),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10, height: 1)),
          _metaRow(Icons.security_rounded, 'Penanggung Jawab', report.fromKeeper, isPrimary: true),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12)),
            child: _metaRow(Icons.person_outline_rounded, 'Saksi/Penerima', report.toKeeper, isSmall: true),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _metaRow(IconData icon, String label, String value, {bool isPrimary = false, bool isSmall = false}) {
    return Row(
      children: [
        Icon(icon, color: isPrimary ? Colors.red : Colors.grey, size: isSmall ? 14 : 18),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty)
                Text(label, style: TextStyle(color: Colors.grey, fontSize: isSmall ? 10 : 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              Text(value, style: GoogleFonts.plusJakartaSans(
                color: isPrimary ? Colors.white : Colors.grey, 
                fontSize: isSmall ? 13 : (isPrimary ? 16 : 14), 
                fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w600
              )),
            ],
          ),
        ),
        if (isPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('PENANGGUNG JAWAB', style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.w900)),
          ),
      ],
    );
  }

  Widget _buildDetailItem(String text, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
        ],
      ),
    ).animate(delay: (300 + (index * 100)).ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
}
