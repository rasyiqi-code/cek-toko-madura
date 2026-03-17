import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../models/app_user.dart';
import '../providers/stock_provider.dart';
import '../widgets/audit/audit_widgets.dart';
import '../widgets/audit/audit_summary_sheet.dart';
import '../widgets/audit/audit_console_drawer.dart';
import '../widgets/audit/audit_history_sheet.dart';

class AuditSessionPage extends StatefulWidget {
  final AppUser toKeeper;
  const AuditSessionPage({super.key, required this.toKeeper});

  @override
  State<AuditSessionPage> createState() => _AuditSessionPageState();
}

class _AuditSessionPageState extends State<AuditSessionPage> {
  late List<StockItem> auditData;
  Map<String, int?> results = {};
  String? selectedCategory;
  final CardSwiperController controller = CardSwiperController();
  int currentCardIndex = 0;
  bool _showConsole = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StockProvider>(context, listen: false);
    results = Map<String, int?>.from(provider.auditDraftResults);
    auditData = provider.items.map((e) {
      final savedPrice = provider.auditDraftPrices[e.id];
      return StockItem(
        id: e.id,
        category: e.category,
        name: e.name,
        modalPrice: savedPrice ?? e.modalPrice,
        currentStock: e.currentStock,
      );
    }).toList();
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

    final categories = auditData.map((e) => e.category).toSet().toList();
    int checkedCount = auditData.where((e) => results.containsKey(e.id)).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          selectedCategory ?? 'AREA AUDIT',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
        ),
        centerTitle: selectedCategory == null,
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                onPressed: () => setState(() {
                  selectedCategory = null;
                  currentCardIndex = 0;
                }),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.blue),
            onPressed: () => _showSessionHistory(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: selectedCategory == null
          ? _buildCategoryList(categories, checkedCount)
          : _buildAuditView(provider),
    );
  }

  Widget _buildCategoryList(List<String> cats, int checkedCount) {
    if (cats.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        AuditProgressHeader(checked: checkedCount, total: auditData.length),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.95,
            ),
            itemCount: cats.length,
            itemBuilder: (context, i) {
              final cat = cats[i];
              final catItems = auditData.where((e) => e.category == cat).toList();
              final doneCount = catItems.where((e) => results.containsKey(e.id)).length;

              return AuditCategoryCard(
                category: cat,
                index: i,
                totalItems: catItems.length,
                doneCount: doneCount,
                onTap: () => setState(() {
                  selectedCategory = cat;
                  currentCardIndex = 0;
                }),
              );
            },
          ),
        ),
        if (checkedCount >= auditData.length) _buildFinishButton(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.white24, size: 64),
          const SizedBox(height: 24),
          const Text('Belum Ada Barang', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Tambahkan barang di menu kelola barang.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 32),
          _backButton(),
        ],
      ),
    );
  }

  Widget _backButton() {
     return SizedBox(
      width: 200, height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: () => Navigator.pop(context),
        child: const Text('KEMBALI', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }


  Widget _buildAuditView(StockProvider provider) {
    final filtered = auditData.where((e) => e.category == selectedCategory).toList();

    return Stack(
      children: [
        AnimatedPositioned(
          duration: 400.ms,
          curve: Curves.easeOutBack,
          top: 0,
          left: 0,
          right: 0,
          bottom: _showConsole ? 100 : 48,
          child: CardSwiper(
            controller: controller,
            cardsCount: filtered.length,
            numberOfCardsDisplayed: filtered.length > 1 ? 2 : 1,
            backCardOffset: const Offset(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            allowedSwipeDirection: const AllowedSwipeDirection.only(
              left: true,
              right: true,
              up: true,
            ),
            onSwipe: (p, c, d) {
              final itemId = filtered[p].id;
              if (d == CardSwiperDirection.left) {
                // Validasi sebelum lanjut ke kartu berikutnya
                if (results[itemId] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tentukan stok dulu, Juragan'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return false; // Blokir swipe jika belum diisi
                }
                
                provider.updateAuditDraft(itemId, results[itemId]!, null);
                if (mounted) setState(() => currentCardIndex = c ?? 0);
                return true;
              } else if (d == CardSwiperDirection.right) {
                if (mounted) setState(() => currentCardIndex = c ?? 0);
                return true;
              } else if (d == CardSwiperDirection.top) {
                if (mounted) setState(() => currentCardIndex = c ?? 0);
                return true;
              }
              return false;
            },
            onUndo: (p, c, d) {
              if (mounted) setState(() => currentCardIndex = c);
              return true;
            },
            onEnd: () {
              if (mounted) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) setState(() => selectedCategory = null);
                });
              }
            },
            cardBuilder: (context, i, xPercent, yPercent) {
              final item = filtered[i];
              final stock = results[item.id];
              
              return Stack(
                children: [
                   AuditCard(
                    item: item,
                    newStock: stock,
                    hint: 'GESER KIRI NEXT • KANAN BALIK • ATAS SKIP',
                    onEdit: () => _showInputDialog((v) {
                      setState(() => results[item.id] = v);
                      provider.updateAuditDraft(item.id, v, null);
                    }),
                    onPriceEdit: () => _showPriceInputDialog(item.modalPrice, (v) {
                      setState(() => item.modalPrice = v);
                      provider.updateAuditDraft(item.id, null, v);
                    }),
                  ),
                  AuditSwipeOverlay(xPercent: xPercent, yPercent: yPercent),
                ],
              );
            },
          ),
        ),
        _buildActionButtons(filtered, provider),
      ],
    );
  }

  void _showSessionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuditHistorySheet(
        auditData: auditData,
        results: results,
      ),
    );
  }

  void _showPriceInputDialog(double initial, Function(double) onSave) {
    final ctrl = TextEditingController(text: initial.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Input Harga Modal Baru', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
          decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.white12), prefixText: 'Rp '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                onSave(double.tryParse(ctrl.text) ?? 0);
                Navigator.pop(context);
              }
            },
            child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(List<StockItem> filtered, StockProvider provider) {
    return AuditConsoleDrawer(
      showConsole: _showConsole,
      onToggle: () => setState(() => _showConsole = !_showConsole),
      onUndo: () => controller.undo(),
      onSkip: () => controller.swipe(CardSwiperDirection.top),
      onNext: () {
        if (currentCardIndex < filtered.length) {
          final item = filtered[currentCardIndex];
          if (results[item.id] == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tentukan stok dulu, Juragan'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          controller.swipe(CardSwiperDirection.left);
        }
      },
    );
  }


  Widget _buildFinishButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity, height: 64,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
          ),
          onPressed: () => _calculateFinalResult(),
          child: const Text('SELESAI & LIHAT HASIL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    ).animate().shimmer(duration: const Duration(seconds: 2));
  }

  void _showInputDialog(Function(int) onSave) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Berapa Stok Baru?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        content: TextField(
          controller: ctrl, keyboardType: TextInputType.number, autofocus: true, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
          decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.white12)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { 
              if (ctrl.text.isNotEmpty) { 
                final v = int.tryParse(ctrl.text);
                if (v != null) {
                  onSave(v); 
                  Navigator.pop(context); 
                }
              } 
            },
            child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _calculateFinalResult() {
    double def = 0, sur = 0;
    List<String> logs = [];
    for (var a in auditData) {
      int newVal = results[a.id] ?? a.currentStock;
      int diff = a.currentStock - newVal;
      if (diff > 0) {
        def += (diff * a.modalPrice);
        logs.add('- ${a.name}: Kurang $diff');
      } else if (diff < 0) {
        sur += (diff.abs() * a.modalPrice);
        logs.add('+ ${a.name}: Lebih ${diff.abs()}');
      }
    }
    _showSummary(def, sur, logs);
  }

  void _showSummary(double def, double sur, List<String> logs) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => AuditSummarySheet(
        toKeeper: widget.toKeeper, auditData: auditData, results: results, deficit: def, surplus: sur, logs: logs,
      ),
    );
  }
}
