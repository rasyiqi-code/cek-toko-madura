import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/stock_item.dart';
import '../../models/app_user.dart';
import '../../providers/stock_provider.dart';

class AuditSummarySheet extends StatelessWidget {
  final AppUser toKeeper;
  final List<StockItem> auditData;
  final Map<String, int?> results;
  final double deficit;
  final double surplus;
  final List<String> logs;

  const AuditSummarySheet({
    super.key,
    required this.toKeeper,
    required this.auditData,
    required this.results,
    required this.deficit,
    required this.surplus,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final cur = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final net = surplus - deficit;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'RINGKASAN HASIL',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            _buildTotalCard(net, cur),
            const SizedBox(height: 24),
            Row(
              children: [
                _miniStat('BARANG KURANG', cur.format(deficit), Colors.red),
                const SizedBox(width: 12),
                _miniStat('BARANG LEBIH', cur.format(surplus), Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
            _buildActionButtons(context, net, deficit, surplus, cur),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double net, NumberFormat cur) {
    final color = net < 0 ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL SELISIH AKHIR',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${net > 0 ? "+" : ""}${cur.format(net)}',
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons(
    BuildContext context,
    double net,
    double def,
    double sur,
    NumberFormat cur,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _printPdf(context, net, def, sur, cur),
            icon: const Icon(
              Icons.picture_as_pdf_rounded,
              size: 20,
              color: Colors.white,
            ),
            label: const Text(
              ' CETAK PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Provider.of<StockProvider>(
                context,
                listen: false,
              ).commitAudit(auditData, results, toKeeper.id, def, sur, logs);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text(
              'SIMPAN & SELESAI',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _printPdf(
    BuildContext context,
    double net,
    double def,
    double sur,
    NumberFormat cur,
  ) async {
    final pdf = pw.Document();
    final now = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
    final provider = Provider.of<StockProvider>(context, listen: false);
    final fromName = provider.users
        .firstWhere((u) => u.id == provider.activeKeeperId,
            orElse: () => AppUser(id: '0', name: '-', role: UserRole.penjaga))
        .name;

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
                pw.Text('Penjaga Toko: $fromName',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Saksi/Penerima: ${toKeeper.name}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Dicek Pada: $now', style: const pw.TextStyle(fontSize: 10)),
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
                   _pdfStat('BARANG KURANG', cur.format(def), PdfColors.red),
                  _pdfStat('BARANG LEBIH', cur.format(sur), PdfColors.green),
                  _pdfStat(
                    'Selisih',
                    '${net >= 0 ? '+' : ''}${cur.format(net)}',
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
                ...auditData.map((item) {
                  final newVal = results[item.id] ?? item.currentStock;
                  final diff = item.currentStock - newVal;
                  if (diff == 0) return pw.TableRow(children: [pw.SizedBox(), pw.SizedBox(), pw.SizedBox()]);

                  final diffAbs = diff.abs();
                  final itemRupiah = diffAbs * item.modalPrice;
                  final label = diff > 0 ? 'Kurang $diff' : 'Lebih $diffAbs';

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text(item.name),
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
                }).where((row) => row.children.first is! pw.SizedBox),
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
                        cur.format(def + sur),
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
                    pw.Text('($fromName)', style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 40),
                    pw.Container(width: 100, height: 1, color: PdfColors.black),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Petugas Baru'),
                    pw.Text('(${toKeeper.name})', style: const pw.TextStyle(fontSize: 8)),
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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _pdfStat(String label, String val, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 4),
        pw.Text(
          val,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
