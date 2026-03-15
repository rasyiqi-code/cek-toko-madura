import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/stock_item.dart';
import '../../providers/stock_provider.dart';
import 'dashboard_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductListSheet extends StatelessWidget {
  const ProductListSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              controller: ctrl,
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
                          fontSize: 20,
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
                  provider.items.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada barang',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.items.length,
                          itemBuilder: (context, i) {
                            final item = provider.items[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.name.isNotEmpty ? item.name[0] : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  item.category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
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
                ],
              ),
            ),
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
                    widget.item == null ? Icons.add_business_rounded : Icons.edit_note_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
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
            const SizedBox(height: 48),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
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
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
