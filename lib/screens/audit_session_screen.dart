import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/stock_item.dart';
import '../models/keeper.dart';
import '../providers/stock_provider.dart';

class AuditSessionPage extends StatefulWidget {
  final Keeper toKeeper;
  const AuditSessionPage({super.key, required this.toKeeper});

  @override
  State<AuditSessionPage> createState() => _AuditSessionPageState();
}

class _AuditSessionPageState extends State<AuditSessionPage> {
  late List<StockItem> auditData;
  Map<String, int?> results = {};
  String? selectedCategory;
  final CardSwiperController controller = CardSwiperController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StockProvider>(context, listen: false);
    auditData = provider.items
        .map(
          (e) => StockItem(
            id: e.id,
            category: e.category,
            name: e.name,
            modalPrice: e.modalPrice,
            currentStock: e.currentStock,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = auditData.map((e) => e.category).toSet().toList();
    int checkedCount = auditData.where((e) => results.containsKey(e.id)).length;
    bool allDone = checkedCount >= auditData.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          selectedCategory ?? 'AREA AUDIT',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: selectedCategory == null,
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => selectedCategory = null),
              )
            : null,
      ),
      body: selectedCategory == null
          ? _buildCategoryList(categories, checkedCount, allDone)
          : _buildAuditView(),
    );
  }

  Widget _buildCategoryList(List<String> cats, int checkedCount, bool allDone) {
    if (cats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Barang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan barang di menu kelola barang.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'KEMBALI',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildProgressHeader(checkedCount),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: cats.length,
            itemBuilder: (context, i) {
              final catItems = auditData
                  .where((e) => e.category == cats[i])
                  .toList();
              final doneCount = catItems
                  .where((e) => results.containsKey(e.id))
                  .length;
              final isDone = doneCount == catItems.length;

              return InkWell(
                    onTap: () => setState(() => selectedCategory = cats[i]),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDone
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : _getCatIcon(cats[i]),
                            color: isDone ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            cats[i],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$doneCount / ${catItems.length} Item',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: Duration(milliseconds: i * 100))
                  .fadeIn()
                  .scale();
            },
          ),
        ),
        if (allDone) _buildFinishButton(),
      ],
    );
  }

  Widget _buildAuditView() {
    final filtered = auditData
        .where((e) => e.category == selectedCategory)
        .toList();
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: CardSwiper(
            controller: controller,
            cardsCount: filtered.length,
            numberOfCardsDisplayed: filtered.length > 1 ? 2 : 1,
            backCardOffset: const Offset(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            onSwipe: (p, c, d) {
              if (d == CardSwiperDirection.right &&
                  results[filtered[p].id] == null) {
                results[filtered[p].id] = filtered[p].currentStock;
              }
              return true;
            },
            onEnd: () {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  setState(() => selectedCategory = null);
                }
              });
            },
            cardBuilder: (context, i, _, _) => _buildAuditCard(filtered[i]),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionCircle(
                Icons.close_rounded,
                Colors.grey,
                () => controller.swipe(CardSwiperDirection.left),
              ),
              const SizedBox(width: 40),
              _actionCircle(
                Icons.check_rounded,
                Colors.red,
                () => controller.swipe(CardSwiperDirection.right),
              ),
            ],
          ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
        ),
      ],
    );
  }

  Widget _actionCircle(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  Widget _buildProgressHeader(int checked) {
    double percent = checked / auditData.length;
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROGRES AUDIT',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              color: Colors.red,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildFinishButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
          ),
          onPressed: () => _calculateFinalResult(),
          child: const Text(
            'SELESAI & LIHAT HASIL',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ),
    ).animate().shimmer(duration: const Duration(seconds: 2));
  }

  IconData _getCatIcon(String cat) {
    if (cat.contains('ROKOK')) {
      return Icons.smoking_rooms_rounded;
    }
    if (cat.contains('MINUMAN') || cat.contains('KULKAS')) {
      return Icons.local_drink_rounded;
    }
    if (cat.contains('SEMBAKO')) {
      return Icons.rice_bowl_rounded;
    }
    return Icons.grid_view_rounded;
  }

  Widget _buildAuditCard(StockItem item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.category,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              item.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                _stockBox('STOK LAMA', item.currentStock, false),
                const SizedBox(width: 16),
                _stockBox(
                  'STOK BARU',
                  results[item.id],
                  true,
                  onEdit: (v) => setState(() => results[item.id] = v),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'GESER KANAN JIKA COCOK',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _stockBox(
    String label,
    int? val,
    bool editable, {
    Function(int)? onEdit,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: editable ? () => _showInputDialog(onEdit!) : null,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: editable
                    ? (val == null ? Colors.transparent : Colors.white)
                    : const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: editable && val == null
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${val ?? "?"}',
                style: TextStyle(
                  color: editable && val != null ? Colors.black : Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInputDialog(Function(int) onSave) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Berapa Stok Baru?',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '0',
            hintStyle: TextStyle(color: Colors.white12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                onSave(int.parse(ctrl.text));
                Navigator.pop(context);
              }
            },
            child: const Text(
              'SIMPAN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
    final cur = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final net = sur - def;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => SingleChildScrollView(
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (net < 0 ? Colors.red : Colors.green).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: (net < 0 ? Colors.red : Colors.green).withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL SELISIH AKHIR',
                      style: TextStyle(
                        color: (net < 0 ? Colors.red : Colors.green),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${net > 0 ? "+" : ""}${cur.format(net)}',
                      style: TextStyle(
                        color: (net < 0 ? Colors.red : Colors.green),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _miniStat('BARANG KURANG', cur.format(def), Colors.red),
                  const SizedBox(width: 12),
                  _miniStat('BARANG LEBIH', cur.format(sur), Colors.green),
                ],
              ),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DETAIL SELISIH',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, i) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          logs[i].startsWith('-')
                              ? Icons.remove_circle_rounded
                              : Icons.add_circle_rounded,
                          color: logs[i].startsWith('-')
                              ? Colors.red
                              : Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            logs[i].substring(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _share(net, def, sur, logs),
                      icon: const Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'BAGIKAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
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
                        ).commitAudit(
                          auditData,
                          results,
                          widget.toKeeper.id,
                          def,
                          sur,
                          logs,
                        );
                        Navigator.popUntil(context, (r) => r.isFirst);
                      },
                      child: const Text(
                        'SIMPAN & SHIFT SELESAI',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _share(double net, double def, double sur, List<String> logs) {
    final cur = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final text =
        "📋 *LAPORAN SERAH TERIMA*\n"
        "📅 ${DateFormat('dd MMM yy, HH:mm').format(DateTime.now())}\n"
        "👤 Penerima: ${widget.toKeeper.name}\n"
        "------------------\n"
        "📊 *HASIL AKHIR:* ${net >= 0 ? '+' : ''}${cur.format(net)}\n"
        "------------------\n"
        "*DETAIL:*\n${logs.join('\n')}";
    SharePlus.instance.share(ShareParams(text: text));
  }
}
