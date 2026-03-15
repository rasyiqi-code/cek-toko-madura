import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../../screens/audit_session_screen.dart';
import '../../screens/staff_management_screen.dart';

class KeeperPickerSheet extends StatelessWidget {
  const KeeperPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
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
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Close sheet
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffManagementScreen()));
                  },
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
                        'Daftarkan akun baru untuk serah terima.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
                              provider.setAuditDraftToKeeper(k.id);
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AuditSessionPage(toKeeper: k),
                                ),
                              );
                            },
                            onLongPress: () {
                              provider.deleteUser(k.id);
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
                              color: Colors.white70,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
