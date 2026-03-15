import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/stock_item.dart';

class ActionCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionCircle({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

class AuditProgressHeader extends StatelessWidget {
  final int checked;
  final int total;

  const AuditProgressHeader({
    super.key,
    required this.checked,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double percent = total > 0 ? checked / total : 0;
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
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
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
}

class AuditCard extends StatelessWidget {
  final StockItem item;
  final int? newStock;
  final VoidCallback onEdit;
  final VoidCallback onPriceEdit;
  final String hint;

  const AuditCard({
    super.key,
    required this.item,
    required this.newStock,
    required this.onEdit,
    required this.onPriceEdit,
    this.hint = 'GESER KIRI LANJUT • KANAN BALIK • ATAS LEWATI',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F), // Bright red backgroun d
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              item.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _AuditBox(
              label: 'HARGA MODAL (RP)',
              val: item.modalPrice.toStringAsFixed(0),
              editable: true,
              onTap: onPriceEdit,
              isHighlight: true,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Expanded(
                  child: _AuditBox(
                    label: 'STOK LAMA',
                    val: item.currentStock.toString(),
                    editable: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AuditBox(
                    label: 'STOK BARU',
                    val: newStock?.toString() ?? "?",
                    editable: true,
                    onTap: onEdit,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            hint,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AuditBox extends StatelessWidget {
  final String label;
  final String val;
  final bool editable;
  final VoidCallback? onTap;
  final bool isHighlight;

  const _AuditBox({
    required this.label,
    required this.val,
    required this.editable,
    this.onTap,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPlaceHolder = val == "?";
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white, // Max contrast
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12), // More breathing room
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: 300.ms,
            height: 60, // Uniform height for all fields
            width: isHighlight ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: editable
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isPlaceHolder
                          ? [
                              Colors.white.withValues(alpha: 0.03),
                              Colors.white.withValues(alpha: 0.08),
                            ]
                          : [Colors.white, Colors.grey.shade200],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF0D0D0D), Color(0xFF0D0D0D)],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: editable && isPlaceHolder
                    ? Colors.red.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
              boxShadow: editable && !isPlaceHolder
                  ? [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isPlaceHolder
                ? FittedBox(
                    child:
                        Text(
                              val,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white24,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                            .animate(
                              onPlay: (ctrl) => ctrl.repeat(reverse: true),
                            )
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(0.85, 0.85),
                              duration: 800.ms,
                              curve: Curves.easeInOut,
                            ),
                  )
                : FittedBox(
                    child: Text(
                      val,
                      style: GoogleFonts.plusJakartaSans(
                        color: editable ? Colors.black : Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class AuditCategoryCard extends StatelessWidget {
  final String category;
  final int index;
  final int totalItems;
  final int doneCount;
  final VoidCallback onTap;

  const AuditCategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.totalItems,
    required this.doneCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = doneCount == totalItems;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDone
                ? Colors.green.withAlpha(200)
                : Colors.white.withAlpha(50),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : _getCatIcon(category),
                color: isDone ? Colors.green : Colors.white,
                size: 32,
              ),
              const SizedBox(height: 16),
              Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$doneCount / $totalItems Item',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 100)).fadeIn().scale();
  }

  IconData _getCatIcon(String cat) {
    if (cat.contains('ROKOK')) return Icons.smoking_rooms_rounded;
    if (cat.contains('MINUMAN') || cat.contains('KULKAS')) {
      return Icons.local_drink_rounded;
    }
    if (cat.contains('SEMBAKO')) return Icons.rice_bowl_rounded;
    return Icons.grid_view_rounded;
  }
}

class AuditSwipeOverlay extends StatelessWidget {
  final int xPercent;
  final int yPercent;

  const AuditSwipeOverlay({
    super.key,
    required this.xPercent,
    required this.yPercent,
  });

  @override
  Widget build(BuildContext context) {
    String? label;
    Color labelColor = Colors.white;
    double opacity = 0;

    final double absX = xPercent.abs().toDouble();
    final double absY = yPercent.abs().toDouble();

    if (absX > absY && absX > 0) {
      if (xPercent < 0) {
        label = 'LANJUT';
        labelColor = Colors.green;
      } else {
        label = 'KEMBALI';
        labelColor = Colors.white70;
      }
      opacity = (absX * 2.0).clamp(0.0, 1.0);
    } else if (absY > absX && absY > 0) {
      if (yPercent < 0) {
        label = 'LEWATI';
        labelColor = Colors.amber;
      }
      opacity = (absY * 2.0).clamp(0.0, 1.0);
    }

    if (opacity <= 0) return const SizedBox.shrink();

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: opacity * 10, sigmaY: opacity * 10),
          child: Container(
            decoration: BoxDecoration(
              color: labelColor.withValues(alpha: (opacity * 0.4).clamp(0.0, 1.0)),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Center(
              child: Text(
                label ?? '',
                style: GoogleFonts.plusJakartaSans(
                  color: labelColor,
                  fontSize: 44, // Slightly larger
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 200.ms,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
