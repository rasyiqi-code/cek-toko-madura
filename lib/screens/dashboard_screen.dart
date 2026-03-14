import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../providers/stock_provider.dart';
import '../providers/trial_provider.dart';
import 'audit_session_screen.dart';
import 'report_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final trial = Provider.of<TrialProvider>(context);
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final keepers = provider.keepers;
    final activeKeeper = keepers.firstWhere(
      (k) => k.id == provider.activeKeeperId,
      orElse: () => keepers.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
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
          },
          icon: Icon(
            trial.isLicensed
                ? Icons.verified_rounded
                : Icons.help_outline_rounded,
            color: trial.isLicensed ? Colors.greenAccent : Colors.white54,
            size: 20,
          ),
        ),
        title: Text(
          'Halo Juragan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSyncSettings(context, provider),
            icon: Icon(
              provider.isSyncing
                  ? Icons.sync_rounded
                  : Icons.cloud_done_rounded,
              color: provider.syncUrl == null ? Colors.white24 : Colors.red,
              size: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white70),
            onPressed: () => _showHistory(context, provider, currency),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
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
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'CEK TOKO MADURA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              const Text(
                'Audit stok sebelum ganti shift penjaga.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),

              // Dashboard content
              if (provider.items.isEmpty) ...[
                _buildEmptyState(
                  context,
                  'Belum Ada Barang',
                  'Tambahkan barang toko terlebih dahulu untuk mulai audit.',
                  Icons.inventory_2_rounded,
                  'TAMBAH BARANG',
                  () => _showProductList(context, provider),
                ),
              ] else ...[
                // Setup Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildKeeperBox(
                        'Penjaga Lama (Yang Menyerahkan)',
                        activeKeeper.name,
                        Icons.person_outline_rounded,
                        Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Container(
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
                      ),
                      const SizedBox(height: 16),
                      _buildKeeperBox(
                        'Penjaga Baru (Yang Menerima)',
                        'Pilih Penjaga...',
                        Icons.person_add_alt_1_rounded,
                        Colors.red,
                        isAction: true,
                        onTap: () => _showKeeperPicker(context, provider),
                      ),
                    ],
                  ),
                ).animate().slideY(
                  begin: 0.1,
                  end: 0,
                  delay: 400.ms,
                  duration: 600.ms,
                ),
              ],

              const SizedBox(height: 48),

              if (provider.items.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showProductList(context, provider),
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: const Text('Kelola Daftar Barang'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    String btnText,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 64),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onTap,
              child: Text(
                btnText,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeeperBox(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAction
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isAction ? Colors.red : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isAction && value.contains('Pilih')
                          ? Colors.grey
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isAction)
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showKeeperPicker(BuildContext context, StockProvider initialProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Consumer<StockProvider>(
        builder: (context, provider, _) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            left: 32,
            right: 32,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Row(
                children: [
                  const Text(
                    'SIAPA PENERIMA SHIFT?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showKeeperForm(context, provider),
                    icon: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: provider.keepers.length <= 1
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Daftarkan rekan kerja baru untuk serah terima.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.keepers.length,
                        itemBuilder: (context, i) {
                          final k = provider.keepers[i];
                          if (k.id == provider.activeKeeperId) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AuditSessionPage(toKeeper: k),
                                  ),
                                );
                              },
                              onLongPress: () {
                                // Optional: Add delete confirmation
                                provider.deleteKeeper(k.id);
                              },
                              leading: const Icon(
                                Icons.person_outline_rounded,
                                color: Colors.red,
                              ),
                              title: Text(
                                k.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey,
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

  void _showKeeperForm(BuildContext context, StockProvider provider) {
    final name = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (bctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
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
                    Icons.person_add_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAFTAR PENJAGA BARU',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Tambahkan rekan kerja Anda.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            _field(name, 'Nama Lengkap Penjaga', Icons.person_rounded),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (name.text.isNotEmpty) {
                    provider.addKeeper(name.text.toUpperCase());
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'SIMPAN PENJAGA',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showProductList(BuildContext context, StockProvider initialProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Consumer<StockProvider>(
        builder: (context, provider, _) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
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
                Row(
                  children: [
                    const Text(
                      'KELOLA BARANG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showProductForm(context, provider),
                      icon: const Icon(
                        Icons.add_circle_rounded,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.items.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada barang',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: ctrl,
                          itemCount: provider.items.length,
                          itemBuilder: (context, i) {
                            final item = provider.items[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161616),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF222222),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.name[0],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  item.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Text(
                                  '${item.currentStock}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                onLongPress: () => _showProductForm(
                                  context,
                                  provider,
                                  item: item,
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
      ),
    );
  }

  void _showProductForm(
    BuildContext context,
    StockProvider provider, {
    StockItem? item,
  }) {
    final name = TextEditingController(text: item?.name);
    final cat = TextEditingController(text: item?.category);
    final modal = TextEditingController(
      text: item?.modalPrice.toStringAsFixed(0),
    );
    final stock = TextEditingController(text: item?.currentStock.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (bctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bctx).viewInsets.bottom,
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
                    child: Icon(
                      item == null
                          ? Icons.add_business_rounded
                          : Icons.edit_note_rounded,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item == null ? 'TAMBAH BARANG' : 'EDIT DETAIL BARANG',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        item == null
                            ? 'Lengkapi data stok baru.'
                            : 'Perbarui informasi produk pilihan.',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _formSection('INFORMASI UMUM'),
              _field(
                name,
                'Nama Barang (Contoh: Gudang Garam 12)',
                Icons.inventory_2_rounded,
              ),
              const SizedBox(height: 16),
              _autocompleteField(
                cat,
                'Kategori atau Rak (Contoh: ROKOK)',
                Icons.grid_view_rounded,
                provider.items.map((e) => e.category).toSet().toList(),
              ),

              const SizedBox(height: 24),
              _formSection('DETAIL STOK & HARGA'),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      modal,
                      'Harga Modal',
                      Icons.payments_rounded,
                      isNum: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      stock,
                      'Sisa Stok',
                      Icons.numbers_rounded,
                      isNum: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
              Row(
                children: [
                  if (item != null) ...[
                    IconButton(
                      onPressed: () {
                        provider.deleteProduct(item.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (name.text.isEmpty || cat.text.isEmpty) return;
                        final newItem = StockItem(
                          id:
                              item?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name.text.toUpperCase(),
                          category: cat.text.toUpperCase(),
                          modalPrice: double.tryParse(modal.text) ?? 0,
                          currentStock: int.tryParse(stock.text) ?? 0,
                        );
                        if (item == null) {
                          provider.addProduct(newItem);
                        } else {
                          provider.editProduct(newItem);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        item == null ? 'SIMPAN BARANG' : 'PERBARUI DATA',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }

  Widget _formSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _autocompleteField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    List<String> options,
  ) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.contains(textEditingValue.text.toUpperCase());
        });
      },
      onSelected: (String selection) {
        ctrl.text = selection;
      },
      fieldViewBuilder: (context, fieldCtrl, focusNode, onFieldSubmitted) {
        // Sync the controller
        if (ctrl.text.isNotEmpty && fieldCtrl.text.isEmpty) {
          fieldCtrl.text = ctrl.text;
        }
        fieldCtrl.addListener(() {
          ctrl.text = fieldCtrl.text.toUpperCase();
        });

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: fieldCtrl,
            focusNode: focusNode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(icon, size: 20, color: Colors.white38),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              border: InputBorder.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width - 48,
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    title: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isNum = false,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? const Color(0xFF161616)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.white38 : Colors.white10,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _showHistory(
    BuildContext context,
    StockProvider initialProvider,
    NumberFormat cur,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Consumer<StockProvider>(
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
                    fontSize: 18,
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
                            style: TextStyle(color: Colors.grey),
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
                                color: const Color(0xFF161616),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ReportDetailScreen(report: r),
                                  ),
                                ),
                                leading: const Icon(
                                  Icons.assignment_turned_in_rounded,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  r.date,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  '${r.fromKeeper} ➔ ${r.toKeeper}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${net > 0 ? "+" : ""}${cur.format(net)}',
                                      style: TextStyle(
                                        color: net < 0
                                            ? Colors.red
                                            : (net > 0
                                                  ? Colors.green
                                                  : Colors.grey),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const Text(
                                      'LIHAT DETAIL',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.red,
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
      ),
    );
  }

  void _showSyncSettings(BuildContext context, StockProvider provider) {
    final urlController = TextEditingController(text: provider.syncUrl);
    final sheetUrlController = TextEditingController(
      text: provider.spreadsheetUrl,
    );
    bool isEditing = provider.syncUrl == null || provider.syncUrl!.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (bctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bctx).viewInsets.bottom,
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
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (!isEditing)
                      TextButton.icon(
                        onPressed: () => setModalState(() => isEditing = true),
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
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text(
                  '1. SCRIPT BACKUP (Wajib)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _field(
                  urlController,
                  'Web App URL (Apps Script)',
                  Icons.link_rounded,
                  enabled: isEditing,
                ),

                const SizedBox(height: 24),
                const Text(
                  '2. LINK GOOGLE SHEET (Wajib)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _field(
                  sheetUrlController,
                  'Spreadsheet URL (Hasil Copy Link)',
                  Icons.table_chart_rounded,
                  enabled: isEditing,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan link Google Sheet tempat data akan disimpan.',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),

                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'LAYANAN CLOUD BACKUP (PRO)',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Fitur Gratis bagi user pro.\n• Admin akan memberikan Link Script & Link Sheet.\n• Setup dilakukan sepenuhnya oleh tim support.\n• Hubungi Admin untuk minta link script.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Row(
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
                                  content: Text(
                                    'Keduanya (Script & Sheet) Wajib diisi!',
                                  ),
                                ),
                              );
                              return;
                            }
                            provider.setSyncUrl(urlController.text);
                            provider.setSpreadsheetUrl(sheetUrlController.text);
                            Navigator.pop(context); // Auto-close
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pengaturan disimpan'),
                              ),
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
                                        content: Text(
                                          'Simpan URL Script & Sheet dulu!',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  provider.setSyncUrl(urlController.text);
                                  provider.setSpreadsheetUrl(
                                    sheetUrlController.text,
                                  );
                                  final success = await provider
                                      .syncToGoogleSheets();
                                  if (context.mounted) {
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
                                    if (success) {
                                      Navigator.pop(
                                        context,
                                      ); // Optional auto-close on success
                                    }
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
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
