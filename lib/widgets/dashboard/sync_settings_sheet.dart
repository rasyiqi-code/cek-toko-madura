import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import 'dashboard_widgets.dart';

class SyncSettingsSheet extends StatefulWidget {
  const SyncSettingsSheet({super.key});

  @override
  State<SyncSettingsSheet> createState() => _SyncSettingsSheetState();
}

class _SyncSettingsSheetState extends State<SyncSettingsSheet> {
  late TextEditingController urlController;
  late TextEditingController sheetUrlController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StockProvider>(context, listen: false);
    urlController = TextEditingController(text: provider.syncUrl);
    sheetUrlController = TextEditingController(text: provider.spreadsheetUrl);
    isEditing = provider.syncUrl == null || provider.syncUrl!.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GOOGLE SHEETS SYNC',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Cadangkan data Anda ke awan.',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                if (!isEditing)
                  TextButton.icon(
                    onPressed: () => setState(() => isEditing = true),
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Colors.blue,
                    ),
                    label: const Text(
                      'EDIT',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '1. SCRIPT BACKUP (Wajib)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DashboardField(
              controller: urlController,
              hint: 'Web App URL (Apps Script)',
              icon: Icons.link_rounded,
              enabled: isEditing,
            ),
            const SizedBox(height: 24),
            const Text(
              '2. LINK GOOGLE SHEET (Wajib)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DashboardField(
              controller: sheetUrlController,
              hint: 'Spreadsheet URL (Hasil Copy Link)',
              icon: Icons.table_chart_rounded,
              enabled: isEditing,
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan link Google Sheet tempat data akan disimpan.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 32),
            _buildProCard(),
            const SizedBox(height: 32),
            _buildImportDemoButton(provider),
            const SizedBox(height: 32),
            _buildActionButtons(provider),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Text(
                'LAYANAN CLOUD BACKUP (PRO)',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Fitur Gratis bagi user pro.\n• Admin akan memberikan Link Script & Link Sheet.\n• Setup dilakukan sepenuhnya oleh tim support.\n• Hubungi Admin untuk minta link script.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildImportDemoButton(StockProvider provider) {
    bool hasDemo = provider.items.any((it) => it.isDemo);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              foregroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              final success = await provider.importDemoData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: success ? Colors.green : Colors.red,
                    content: Text(
                      success
                          ? 'Demo data berhasil diimpor!'
                          : 'Gagal mengimpor demo data.',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.file_download_rounded, size: 20),
            label: const Text(
              'IMPOR DATA DEMO PRODUK',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        ),
        if (hasDemo) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                _showResetConfirm(provider);
              },
              icon: const Icon(Icons.delete_sweep_rounded, size: 18),
              label: const Text(
                'RESET DATA DEMO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showResetConfirm(StockProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFD32F2F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        title: const Text(
          'Hapus Data Demo?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Hanya data produk demo yang akan dihapus. Data asli Anda aman.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              provider.resetDemoData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data demo telah dihapus.')),
              );
            },
            child: const Text(
              'HAPUS',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(StockProvider provider) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                if (urlController.text.isEmpty ||
                    sheetUrlController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Keduanya (Script & Sheet) Wajib diisi!'),
                    ),
                  );
                  return;
                }
                provider.setSyncUrl(urlController.text);
                provider.setSpreadsheetUrl(sheetUrlController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengaturan disimpan')),
                );
              },
              child: const Text(
                'SIMPAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: provider.isSyncing
                  ? null
                  : () async {
                      if (urlController.text.isEmpty ||
                          sheetUrlController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simpan URL Script & Sheet dulu!'),
                          ),
                        );
                        return;
                      }
                      provider.setSyncUrl(urlController.text);
                      provider.setSpreadsheetUrl(sheetUrlController.text);
                      final success = await provider.syncToGoogleSheets();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                            content: Text(
                              success
                                  ? 'Berhasil dicadangkan!'
                                  : 'Gagal mencadangkan. Cek URL/Izin.',
                            ),
                          ),
                        );
                        if (success) Navigator.pop(context);
                      }
                    },
              child: provider.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'BACKUP SEKARANG',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
