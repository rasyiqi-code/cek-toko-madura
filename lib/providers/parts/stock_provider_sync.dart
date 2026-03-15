part of '../stock_provider.dart';

extension StockProviderSync on StockProvider {
  Future<void> _syncFromFirebase() async {
    if (storeId == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('stores').doc(storeId!).get();
      final List<AppUser> loadedUsers = [];
      // Always add Admin
      loadedUsers.add(AppUser(id: storeId!, name: 'Admin', role: UserRole.pengecek));

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Items & Reports
          if (data['items'] != null) {
            _items = List<StockItem>.from(data['items'].map((x) => StockItem.fromJson(x)));
            prefs.setString('stock_list', jsonEncode(_items.map((e) => e.toJson()).toList()));
          }
          if (data['reports'] != null) {
            _reports = List<HandoverReport>.from(data['reports'].map((x) => HandoverReport.fromJson(x)));
            prefs.setString('reports_list', jsonEncode(_reports.map((e) => e.toJson()).toList()));
          }

          // APP CONFIG & PROGRESS
          if (data['syncUrl'] != null) {
            syncUrl = data['syncUrl'];
            prefs.setString('sync_url', syncUrl!);
          }
          if (data['spreadsheetUrl'] != null) {
            spreadsheetUrl = data['spreadsheetUrl'];
            prefs.setString('spreadsheet_url', spreadsheetUrl!);
          }
          if (data['activeKeeperId'] != null) {
            activeKeeperId = data['activeKeeperId'];
            prefs.setString('active_keeper', activeKeeperId!);
          }
          if (data['auditDraftResults'] != null) {
            _auditDraftResults = Map<String, int>.from(data['auditDraftResults']);
            prefs.setString('audit_draft_results', jsonEncode(_auditDraftResults));
          }
          if (data['auditDraftPrices'] != null) {
            _auditDraftPrices = Map<String, double>.from(data['auditDraftPrices'].map((k, v) => MapEntry(k, (v as num).toDouble())));
            prefs.setString('audit_draft_prices', jsonEncode(_auditDraftPrices));
          }
          if (data['auditDraftToKeeperId'] != null) {
            _auditDraftToKeeperId = data['auditDraftToKeeperId'];
            prefs.setString('audit_draft_to_keeper_id', _auditDraftToKeeperId!);
          }

          // Fallback: Pull users from store doc if staff collection query fails
          if (data['users'] != null) {
            for (var u in data['users']) {
              final user = AppUser.fromJson(u);
              if (user.id != storeId && !loadedUsers.any((lu) => lu.id == user.id)) {
                loadedUsers.add(user);
              }
            }
          }
        }
      }

      // Try to Fetch Staff from global collection
      try {
        final staffQuery = await FirebaseFirestore.instance
            .collection('staff')
            .where('storeId', isEqualTo: storeId)
            .get();
        
        for (var doc in staffQuery.docs) {
          final d = doc.data();
          final user = AppUser(
            id: doc.id,
            name: d['name'] ?? 'Akun',
            role: UserRole.values[d['role'] ?? 0],
          );
          if (!loadedUsers.any((u) => u.id == user.id)) {
            loadedUsers.add(user);
          }
        }
      } catch (staffError) {
        debugPrint('Staff collection query failed: $staffError');
      }
      
      _users = loadedUsers;
      prefs.setString('users_list', jsonEncode(_users.map((e) => e.toJson()).toList()));
      refresh();
    } catch (e) {
      debugPrint('Error syncing from Firebase: $e');
    }
  }

  void setSyncUrl(String? url) {
    if (url != null && url.isNotEmpty) {
      if (url.contains('/macros/library/') || url.contains('/edit')) {
        url = url.replaceAll('/macros/library/d/', '/macros/s/');
      }

      if (!url.endsWith('/exec')) {
        url = url.endsWith('/') ? '${url}exec' : '$url/exec';
      }
      if (!url.startsWith('http')) {
        url = 'https://script.google.com/macros/s/$url/exec';
      }
      
      if (url.contains('script.google.com') && !url.contains('/macros/s/')) {
         url = url.replaceFirst('/macros/', '/macros/s/');
      }
    }
    syncUrl = url;
    _saveData();
    refresh();
  }

  void setSpreadsheetUrl(String? url) {
    spreadsheetUrl = url;
    _saveData();
    refresh();
  }

  Future<bool> syncToGoogleSheets() async {
    if (syncUrl == null || syncUrl!.isEmpty) return false;
    
    isSyncing = true;
    refresh();

    try {
      final payload = jsonEncode({
        'spreadsheetUrl': spreadsheetUrl,
        'items': _items.map((i) => i.toJson()).toList(),
        'users': _users.map((u) => u.toJson()).toList(),
        'reports': _reports.map((r) => r.toJson()).toList(),
      });

      final response = await http.post(
        Uri.parse(syncUrl!),
        headers: {'Content-Type': 'text/plain'},
        body: payload,
      );

      isSyncing = false;
      refresh();
      return response.statusCode == 200 && (response.body.contains("Success") || response.statusCode == 302);
    } catch (e) {
      isSyncing = false;
      refresh();
      return false;
    }
  }

  Future<void> syncWithFirebase() async {
    if (storeId == null) return;

    isFirebaseSyncing = true;
    refresh();

    try {
      final docRef = FirebaseFirestore.instance.collection('stores').doc(storeId!);
      
      // Update with local data
      await docRef.update({
        'items': _items.map((e) => e.toJson()).toList(),
        'users': _users.map((e) => e.toJson()).toList(),
        'reports': _reports.map((e) => e.toJson()).toList(),
        'activeKeeperId': activeKeeperId,
        'syncUrl': syncUrl,
        'spreadsheetUrl': spreadsheetUrl,
        'auditDraftResults': _auditDraftResults,
        'auditDraftPrices': _auditDraftPrices,
        'auditDraftToKeeperId': _auditDraftToKeeperId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      lastFirebaseSync = DateTime.now();
      debugPrint('Firebase Sync Success for $storeName');
    } catch (e) {
      debugPrint('Firebase Sync Error: $e');
      if (e.toString().contains('not-found')) {
        try {
           final docRef = FirebaseFirestore.instance.collection('stores').doc(storeId!);
           await docRef.set({
            'storeName': storeName,
            'items': _items.map((e) => e.toJson()).toList(),
            'users': _users.map((e) => e.toJson()).toList(),
            'reports': _reports.map((e) => e.toJson()).toList(),
            'activeKeeperId': activeKeeperId,
            'syncUrl': syncUrl,
            'spreadsheetUrl': spreadsheetUrl,
            'auditDraftResults': _auditDraftResults,
            'auditDraftPrices': _auditDraftPrices,
            'auditDraftToKeeperId': _auditDraftToKeeperId,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          lastFirebaseSync = DateTime.now();
        } catch (e2) {
          debugPrint('Firebase Set Error: $e2');
        }
      }
    } finally {
      isFirebaseSyncing = false;
      refresh();
    }
  }
}
