import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import '../models/app_user.dart';
import '../widgets/dashboard/dashboard_widgets.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'SEMUA';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    
    // Safety Guard: Only Pengecek can access
    if (provider.currentUser?.role != UserRole.pengecek) {
      return const Scaffold(
        body: Center(child: Text('Akses Ditolak. Hanya Pengecek yang boleh akses.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'CARI BARANG...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13, fontWeight: FontWeight.bold),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
              suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white30),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<StockProvider>(
            builder: (context, provider, _) {
              if (provider.currentUser?.role != UserRole.pengecek) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showExcelOptions(context, provider),
                    icon: const Icon(Icons.import_export_rounded, color: Colors.blue, size: 28),
                  ),
                  IconButton(
                    onPressed: () => _showProductForm(context, provider),
                    icon: const Icon(Icons.add_circle_rounded, color: Colors.red, size: 28),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<StockProvider>(
        builder: (context, provider, _) {
          final categories = ['SEMUA', ...provider.items.map((e) => e.category).toSet()];
          
          final filteredItems = provider.items.where((item) {
            final name = item.name.toLowerCase();
            final cat = item.category.toLowerCase();
            final matchesSearch = name.contains(_searchQuery) || cat.contains(_searchQuery);
            final matchesCategory = _selectedCategory == 'SEMUA' || item.category == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();

          if (provider.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_rounded, size: 64, color: Colors.white10),
                  SizedBox(height: 16),
                  Text('Belum ada barang di daftar', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (filteredItems.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text('Barang tidak ditemukan', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: categories.length,
                  itemBuilder: (context, i) => _catItem(categories[i]),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, i) {
                    final item = filteredItems[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              item.name.isNotEmpty ? item.name[0] : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.red,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          item.category,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item.currentStock}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onTap: () => _showProductForm(context, provider, item: item),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _catItem(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? Colors.red : Colors.white10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showExcelOptions(BuildContext context, StockProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (bctx) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              Text('EXCEL DATA', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Kelola stok massal via file Excel', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 32),
              _excelOption(
                icon: Icons.download_rounded,
                color: Colors.blue,
                title: 'Download Template',
                subtitle: 'Unduh format file untuk diisi',
                onTap: () {
                  Navigator.pop(context);
                  provider.generateExcelTemplate();
                },
              ),
              const SizedBox(height: 16),
              _excelOption(
                icon: Icons.upload_file_rounded,
                color: Colors.green,
                title: 'Import Data',
                subtitle: 'Upload file Excel yang sudah diisi',
                onTap: () async {
                  Navigator.pop(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final res = await provider.importFromExcel();
                  if (res != null) {
                    scaffoldMessenger.showSnackBar(SnackBar(content: Text(res), backgroundColor: Colors.green));
                  }
                },
              ),
              const SizedBox(height: 16),
              _excelOption(
                icon: Icons.ios_share_rounded,
                color: Colors.orange,
                title: 'Export Data',
                subtitle: 'Download semua barang saat ini',
                onTap: () {
                  Navigator.pop(context);
                  provider.exportToExcel();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _excelOption({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, StockProvider provider, {StockItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (bctx) => ProductFormSheet(provider: provider, item: item),
    );
  }
}

class ProductFormSheet extends StatefulWidget {
  final StockProvider provider;
  final StockItem? item;

  const ProductFormSheet({super.key, required this.provider, this.item});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  late TextEditingController name;
  late TextEditingController cat;
  late TextEditingController modal;
  late TextEditingController stock;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.item?.name);
    cat = TextEditingController(text: widget.item?.category);
    modal = TextEditingController(text: widget.item?.modalPrice.toStringAsFixed(0));
    stock = TextEditingController(text: widget.item?.currentStock.toString());
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Icon(
                    widget.item == null ? Icons.add_circle_outline_rounded : Icons.edit_note_rounded,
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
                        widget.item == null ? 'TAMBAH BARANG' : 'EDIT DETAIL BARANG',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        widget.item == null ? 'Lengkapi data stok baru.' : 'Perbarui informasi produk pilihan.',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const DashboardFormSection(title: 'INFORMASI UMUM'),
            DashboardField(controller: name, hint: 'Nama Barang', icon: Icons.inventory_2_rounded),
            const SizedBox(height: 16),
            DashboardAutocompleteField(
              controller: cat,
              hint: 'Kategori atau Rak',
              icon: Icons.grid_view_rounded,
              options: widget.provider.items.map((e) => e.category).toSet().toList(),
            ),
            const SizedBox(height: 24),
            const DashboardFormSection(title: 'DETAIL STOK & HARGA'),
            Row(
              children: [
                Expanded(child: DashboardField(controller: modal, hint: 'Harga Modal', icon: Icons.payments_rounded, isNum: true)),
                const SizedBox(width: 12),
                Expanded(child: DashboardField(controller: stock, hint: 'Sisa Stok', icon: Icons.numbers_rounded, isNum: true)),
              ],
            ),
            const SizedBox(height: 40),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.item != null) ...[
          IconButton(
            onPressed: () {
              widget.provider.deleteProduct(widget.item!.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () {
              if (name.text.isEmpty || cat.text.isEmpty) return;
              final newItem = StockItem(
                id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: name.text.toUpperCase(),
                category: cat.text.toUpperCase(),
                modalPrice: double.tryParse(modal.text) ?? 0,
                currentStock: int.tryParse(stock.text) ?? 0,
              );
              if (widget.item == null) {
                widget.provider.addProduct(newItem);
              } else {
                widget.provider.editProduct(newItem);
              }
              Navigator.pop(context);
            },
            child: Text(
              widget.item == null ? 'SIMPAN BARANG' : 'PERBARUI DATA',
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
