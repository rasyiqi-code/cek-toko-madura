import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../../screens/report_detail_screen.dart';

class HistorySheet extends StatelessWidget {
  final NumberFormat currency;
  const HistorySheet({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'HASIL CEK SEBELUMNYA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.reports.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada riwayat',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        controller: ctrl,
                        itemCount: provider.reports.length,
                        itemBuilder: (context, i) {
                          final r = provider.reports[i];
                          final net = r.surplus - r.deficit;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReportDetailScreen(report: r),
                                ),
                              ),
                              leading: const Icon(
                                Icons.assignment_turned_in_rounded,
                                color: Colors.white,
                              ),
                              title: Text(
                                r.date,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${r.fromKeeper} ➔ ${r.toKeeper}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${net > 0 ? "+" : ""}${currency.format(net)}',
                                    style: TextStyle(
                                      color: net < 0 ? Colors.red : (net > 0 ? Colors.green : Colors.white70),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    'LIHAT DETAIL',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
