import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock_item.dart';
import '../models/app_user.dart';
import '../models/handover_report.dart';
import '../data/demo_data.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'parts/stock_provider_auth.dart';
part 'parts/stock_provider_sync.dart';
part 'parts/stock_provider_excel.dart';
part 'parts/stock_provider_audit.dart';

class StockProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final _auth = FirebaseAuth.instance;
  List<StockItem> _items = [];
  List<AppUser> _users = [];
  List<HandoverReport> _reports = [];
  AppUser? _currentUser;
  String? storeName;
  String? storeId; // Admin UID
  String? activeKeeperId;
  bool isInitialized = false;
  String? syncUrl;
  String? spreadsheetUrl;
  bool isSyncing = false;
  bool isFirebaseSyncing = false;
  DateTime? lastFirebaseSync;
  Map<String, int?> _auditDraftResults = {};
  Map<String, double> _auditDraftPrices = {};
  String? _auditDraftToKeeperId;

  StockProvider(this.prefs) {
    _loadData();
  }

  List<StockItem> get items => _items;
  List<AppUser> get users => _users;
  List<AppUser> get keepers => _users.where((u) => u.role == UserRole.penjaga).toList();
  List<HandoverReport> get reports => _reports;
  HandoverReport? get latestReport => _reports.isNotEmpty ? _reports.first : null;
  AppUser? get currentUser => _currentUser;
  Map<String, int?> get auditDraftResults => _auditDraftResults;
  Map<String, double> get auditDraftPrices => _auditDraftPrices;
  String? get auditDraftToKeeperId => _auditDraftToKeeperId;

  void _loadData() {
    final stockJson = prefs.getString('stock_list');
    if (stockJson != null) {
      _items = (jsonDecode(stockJson) as List).map((e) => StockItem.fromJson(e)).toList();
    } else {
      _items = [];
    }

    final usersJson = prefs.getString('users_list');
    if (usersJson != null) {
      _users = (jsonDecode(usersJson) as List).map((e) => AppUser.fromJson(e)).toList();
    } else {
      _users = [
        AppUser(id: '1', name: 'Penjaga Toko', role: UserRole.penjaga),
        AppUser(id: '2', name: 'Admin Pengecek', role: UserRole.pengecek),
      ];
    }

    final curUserJson = prefs.getString('current_user');
    if (curUserJson != null) {
      _currentUser = AppUser.fromJson(jsonDecode(curUserJson));
    }

    storeName = prefs.getString('store_name') ?? 'Toko Saya';
    storeId = prefs.getString('store_id');

    final reportsJson = prefs.getString('reports_list');
    if (reportsJson != null) {
      _reports = (jsonDecode(reportsJson) as List).map((e) => HandoverReport.fromJson(e)).toList();
    }

    activeKeeperId = prefs.getString('active_keeper');
    if (activeKeeperId == null || !_users.any((u) => u.id == activeKeeperId)) {
      activeKeeperId = _users.isNotEmpty ? _users.first.id : null;
    }
    syncUrl = prefs.getString('sync_url');
    spreadsheetUrl = prefs.getString('spreadsheet_url');
    
    final draftResultsJson = prefs.getString('audit_draft_results');
    if (draftResultsJson != null) {
      _auditDraftResults = Map<String, int?>.from(jsonDecode(draftResultsJson));
    }
    final draftPricesJson = prefs.getString('audit_draft_prices');
    if (draftPricesJson != null) {
      _auditDraftPrices = Map<String, double>.from(jsonDecode(draftPricesJson));
    }
    _auditDraftToKeeperId = prefs.getString('audit_draft_to_keeper_id');
    
    if (syncUrl != null) {
      if (syncUrl!.contains('/library/') || syncUrl!.contains('/edit')) {
        syncUrl = syncUrl!.replaceAll('/library/d/', '/s/').replaceAll('/edit', '/exec');
      }
      if (syncUrl!.contains('script.google.com') && !syncUrl!.contains('/macros/s/')) {
        syncUrl = syncUrl!.replaceFirst('/macros/', '/macros/s/');
      }
    }

    notifyListeners();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final user = _auth.currentUser;
    if (user != null) {
      if (_currentUser == null || storeId == null) {
        final uid = user.uid;
        try {
          final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(uid).get();
          if (storeDoc.exists) {
            storeId = uid;
            storeName = storeDoc.data()?['storeName'] ?? 'Toko Saya';
            _currentUser = AppUser(id: uid, name: 'Admin', role: UserRole.pengecek);
          } else {
            final staffDoc = await FirebaseFirestore.instance.collection('staff').doc(uid).get();
            if (staffDoc.exists) {
              storeId = staffDoc.data()?['storeId'];
              storeName = staffDoc.data()?['storeName'];
              _currentUser = AppUser(
                id: uid,
                name: staffDoc.data()?['name'] ?? 'Staff',
                role: UserRole.values[staffDoc.data()?['role'] ?? 0],
              );
            }
          }
        } catch (e) {
          debugPrint('Initial Auth Check Error: $e');
          if (e.toString().contains('permission-denied') || e.toString().contains('invalid-credential')) {
            await logout();
          }
        }
        if (_currentUser != null) {
          _saveData();
        }
        await _syncFromFirebase();
      } else {
        await _syncFromFirebase();
      }
    }
    isInitialized = true;
    notifyListeners();
  }

  void clearLocalData() {
    _items = [];
    _users = [];
    _reports = [];
    storeName = null;
    storeId = null;
    activeKeeperId = null;
    _auditDraftResults = {};
    _auditDraftPrices = {};
    _auditDraftToKeeperId = null;
    
    prefs.remove('stock_list');
    prefs.remove('users_list');
    prefs.remove('current_user');
    prefs.remove('store_name');
    prefs.remove('store_id');
    prefs.remove('reports_list');
    prefs.remove('active_keeper');
    prefs.remove('audit_draft_results');
    prefs.remove('audit_draft_prices');
    prefs.remove('audit_draft_to_keeper_id');
  }

  void _saveData() {
    prefs.setString('stock_list', jsonEncode(_items.map((e) => e.toJson()).toList()));
    prefs.setString('users_list', jsonEncode(_users.map((e) => e.toJson()).toList()));
    if (_currentUser != null) prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
    prefs.setString('store_name', storeName ?? '');
    if (storeId != null) prefs.setString('store_id', storeId!);
    prefs.setString('reports_list', jsonEncode(_reports.map((e) => e.toJson()).toList()));
    if (activeKeeperId != null) prefs.setString('active_keeper', activeKeeperId!);
    if (syncUrl != null) prefs.setString('sync_url', syncUrl!);
    if (spreadsheetUrl != null) prefs.setString('spreadsheet_url', spreadsheetUrl!);
    prefs.setString('audit_draft_results', jsonEncode(_auditDraftResults));
    prefs.setString('audit_draft_prices', jsonEncode(_auditDraftPrices));
    if (_auditDraftToKeeperId != null) {
      prefs.setString('audit_draft_to_keeper_id', _auditDraftToKeeperId!);
    } else {
      prefs.remove('audit_draft_to_keeper_id');
    }
    syncWithFirebase();
  }

  void refresh() => notifyListeners();
}
