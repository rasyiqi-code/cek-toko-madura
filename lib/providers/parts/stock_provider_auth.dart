part of '../stock_provider.dart';

extension StockProviderAuth on StockProvider {
  // --- Auth Methods ---

  Future<void> registerAdmin(String email, String password, String sName) async {
    try {
      clearLocalData(); // Start fresh
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      storeId = cred.user!.uid;
      storeName = sName;
      _currentUser = AppUser(id: storeId!, name: 'Admin', role: UserRole.pengecek);
      
      _users = []; // Ensure empty users list for new store
      
      // Save initial store data
      await FirebaseFirestore.instance.collection('stores').doc(storeId).set({
        'storeName': storeName,
        'ownerEmail': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      _saveData();
      refresh();
    } catch (e) {
      debugPrint('Register Error: $e');
      rethrow;
    }
  }

  Future<void> loginAccount(String email, String password) async {
    try {
      clearLocalData(); // Start fresh
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      
      // Try to find if user is admin or staff
      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(uid).get();
      
      if (storeDoc.exists) {
        // Logged in as Admin
        storeId = uid;
        storeName = storeDoc.data()?['storeName'] ?? 'Toko Saya';
        _currentUser = AppUser(id: uid, name: 'Admin', role: UserRole.pengecek);
      } else {
        final staffDoc = await FirebaseFirestore.instance.collection('staff').doc(uid).get();
        if (staffDoc.exists) {
          storeId = staffDoc.data()?['storeId'];
          storeName = staffDoc.data()?['storeName'];
          _currentUser = AppUser(id: uid, name: staffDoc.data()?['name'] ?? 'Staff', role: UserRole.values[staffDoc.data()?['role'] ?? 0]);
        } else {
          throw Exception('Data toko tidak ditemukan untuk akun ini.');
        }
      }
      
      await _syncFromFirebase(); // Pull store data
      _saveData();
      refresh();
    } catch (e) {
      debugPrint('Login Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    clearLocalData();
    _currentUser = null;
    refresh();
  }

  Future<bool> addStaffAccount(String email, String password, String name, UserRole role) async {
    try {
      if (storeId == null) return false;
      
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: 'StaffCreation',
        options: Firebase.app().options,
      );
      
      try {
        final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        final cred = await tempAuth.createUserWithEmailAndPassword(email: email, password: password);
        final uid = cred.user!.uid;
        
        await FirebaseFirestore.instance.collection('staff').doc(uid).set({
          'storeId': storeId,
          'storeName': storeName,
          'name': name,
          'role': role.index,
          'email': email,
        });
        
        _users.add(AppUser(id: uid, name: name, role: role));
        _saveData();
        refresh();
        
        await tempApp.delete();
        return true;
      } catch (e) {
        await tempApp.delete();
        rethrow;
      }
    } catch (e) {
      debugPrint('Add Staff Error: $e');
      return false;
    }
  }

  Future<void> deleteUser(String id) async {
    if (_users.length <= 1) return;
    
    try {
      await FirebaseFirestore.instance.collection('staff').doc(id).delete();
      
      _users.removeWhere((u) => u.id == id);
      if (activeKeeperId == id) {
        activeKeeperId = _users.isNotEmpty ? _users.first.id : null;
      }
      _saveData();
      refresh();
    } catch (e) {
      debugPrint('Delete User Error: $e');
    }
  }
}
