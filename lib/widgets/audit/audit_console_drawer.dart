import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AuditConsoleDrawer extends StatelessWidget {
  final bool showConsole;
  final VoidCallback onToggle;
  final VoidCallback onUndo;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const AuditConsoleDrawer({
    super.key,
    required this.showConsole,
    required this.onToggle,
    required this.onUndo,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: 400.ms,
      curve: Curves.easeOutBack,
      bottom: showConsole ? 0 : -80,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drawer Trigger Handle
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 70, // Smaller width
              height: 28, // Smaller height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border.all(color: Colors.black12, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Icon(
                showConsole
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                color: Colors.black87,
                size: 20, // Smaller icon
              )
              .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
              .moveY(
                begin: -1,
                end: 1,
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          // Console Body (Glassmorphism)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: const Border(
                    top: BorderSide(color: Colors.black12, width: 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 50,
                      offset: const Offset(0, -15),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildConsoleButton(
                      label: 'KEMBALI',
                      icon: Icons.undo_rounded,
                      color: Colors.transparent,
                      contentColor: Colors.black87,
                      onTap: onUndo,
                    ),
                    _buildConsoleButton(
                      label: 'LEWATI',
                      icon: Icons.skip_next_rounded,
                      color: Colors.transparent,
                      contentColor: Colors.amber,
                      onTap: onSkip,
                    ),
                    _buildConsoleButton(
                      label: 'LANJUT',
                      icon: Icons.arrow_forward_rounded,
                      color: Colors.transparent,
                      contentColor: Colors.green,
                      onTap: onNext,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleButton({
    required String label,
    required IconData icon,
    required Color color,
    Color contentColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: contentColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: contentColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
