import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/app_user.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  UserRole _selectedRole = UserRole.penjaga;
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    // Safety Guard: Only Owner can access
    if (provider.currentUser?.id != provider.storeId) {
      return const Scaffold(
        body: Center(
          child: Text('Akses Ditolak. Hanya Admin yang boleh akses.'),
        ),
      );
    }

    final users = provider.users
        .where((u) => u.id != provider.storeId)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('KELOLA AKUN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('TAMBAH AKUN BARU'),
            const SizedBox(height: 16),
            _buildField(_name, 'Nama Lengkap', Icons.person_rounded),
            const SizedBox(height: 12),
            _buildField(_email, 'Email Akun', Icons.email_rounded),
            const SizedBox(height: 12),
            _buildField(
              _password,
              'Password Akun',
              Icons.lock_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            _buildRoleSelector(),
            const SizedBox(height: 24),
            _buildAddButton(provider),
            const SizedBox(height: 40),
            _buildSectionTitle('DAFTAR AKUN AKTIF'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, i) {
                  final u = users[i];
                  return _staffItem(u, provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.2),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(child: _roleButton('PENJAGA', UserRole.penjaga)),
        const SizedBox(width: 12),
        Expanded(child: _roleButton('PENGECEK', UserRole.pengecek)),
      ],
    );
  }

  Widget _roleButton(String label, UserRole role) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.red
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(StockProvider provider) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isLoading ? null : () => _handleAddStaff(provider),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'DAFTARKAN AKUN',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
      ),
    );
  }

  Future<void> _handleAddStaff(StockProvider provider) async {
    if (_email.text.isEmpty || _password.text.isEmpty || _name.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    final success = await provider.addStaffAccount(
      _email.text,
      _password.text,
      _name.text,
      _selectedRole,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _email.clear();
        _password.clear();
        _name.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil ditambahkan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan akun')),
        );
      }
    }
  }

  Widget _staffItem(AppUser u, StockProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.2),
          child: Icon(
            u.role == UserRole.pengecek
                ? Icons.admin_panel_settings_rounded
                : Icons.person_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(
          u.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          u.role == UserRole.pengecek ? 'Pengecek' : 'Penjaga',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white24,
            size: 20,
          ),
          onPressed: () => provider.deleteUser(u.id),
        ),
      ),
    );
  }
}
