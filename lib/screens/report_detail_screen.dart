import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/handover_report.dart';

class ReportDetailScreen extends StatelessWidget {
  final HandoverReport report;
  final bool isPengecek;

  const ReportDetailScreen({super.key, required this.report, this.isPengecek = true});

  String _formatNominal(num amount) {
    if (!isPengecek) return 'Rp ***';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  void _share() {
    final net = report.surplus - report.deficit;
    
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
    
    message += "*TOTAL SELISIH: ${_formatNominal(net)}*";
    
    SharePlus.instance.share(ShareParams(text: message));
  }

  Future<void> _printPdf() async {
    final pdf = pw.Document();
    final cur = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final net = report.surplus - report.deficit;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Laporan CEK TOKO',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Penjaga Toko: ${report.fromKeeper}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Saksi/Penerima: ${report.toKeeper}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Dicek Pada: ${report.date}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                   _pdfStat('BARANG KURANG', _formatNominal(report.deficit), PdfColors.red),
                  _pdfStat('BARANG LEBIH', _formatNominal(report.surplus), PdfColors.green),
                  _pdfStat(
                    'Selisih',
                    '${net >= 0 ? '+' : ''}${_formatNominal(net)}',
                    net >= 0 ? PdfColors.green : PdfColors.red,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 40),
            pw.Text(
              'detail pengecekan',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Barang',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Selisih (Qty)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Rupiah',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (report.auditedItems != null)
                  ...report.auditedItems!.map((it) {
                    final oldS = (it['oldStock'] ?? 0) as int;
                    final newS = (it['newStock'] ?? 0) as int;
                    final diff = oldS - newS;
                    if (diff == 0) return pw.TableRow(children: [pw.SizedBox(), pw.SizedBox(), pw.SizedBox()]);
                    
                    final diffAbs = diff.abs();
                    final price = (it['modal'] ?? 0.0) as double;
                    final itemRupiah = diffAbs * price;
                    final label = diff > 0 ? 'Kurang $diff' : 'Lebih $diffAbs';
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(it['name'] ?? '-'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(label),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(cur.format(itemRupiah)),
                        ),
                      ],
                    );
                  }).where((row) => row.children.first is! pw.SizedBox)
                else
                   ...report.details.map((d) => pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(12), child: pw.Text(d)),
                    pw.Padding(padding: const pw.EdgeInsets.all(12), child: pw.Text('-')),
                    pw.Padding(padding: const pw.EdgeInsets.all(12), child: pw.Text('-')),
                   ])),

                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.SizedBox(),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        _formatNominal(report.deficit + report.surplus),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 50),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text('Petugas Lama'),
                    pw.Text('(${report.fromKeeper})', style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 40),
                    pw.Container(width: 100, height: 1, color: PdfColors.black),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Petugas Baru'),
                    pw.Text('(${report.toKeeper})', style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 40),
                    pw.Container(width: 100, height: 1, color: PdfColors.black),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _pdfStat(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      Text('TOTAL SELISIH', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text(
                        _formatNominal(net),
                        style: GoogleFonts.plusJakartaSans(
                          color: isNegative ? Colors.red : (net > 0 ? Colors.green : Colors.white70),
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
              IconButton(onPressed: _printPdf, icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white)),
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
                  Text('DETAIL BARANG', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  if (report.details.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('Semua barang sesuai stok', style: TextStyle(color: Colors.white70, fontSize: 14))),
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
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
        Icon(icon, color: Colors.white, size: isSmall ? 14 : 18),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty)
                Text(label, style: TextStyle(color: Colors.white70, fontSize: isSmall ? 12 : 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              Text(value, style: GoogleFonts.plusJakartaSans(
                color: Colors.white, 
                fontSize: isSmall ? 14 : (isPrimary ? 18 : 16), 
                fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w600
              )),
            ],
          ),
        ),
        if (isPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('PENANGGUNG JAWAB', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w900)),
          ),
      ],
    );
  }

  Widget _buildDetailItem(String text, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
        ],
      ),
    ).animate(delay: (300 + (index * 100)).ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
}
