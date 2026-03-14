import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/stock_item.dart';
import '../models/keeper.dart';
import '../models/handover_report.dart';

class StockProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<StockItem> _items = [];
  List<Keeper> _keepers = [];
  List<HandoverReport> _reports = [];
  String? activeKeeperId;
  String? syncUrl;
  String? spreadsheetUrl;
  bool isSyncing = false;

  StockProvider(this.prefs) {
    _loadData();
  }

  List<StockItem> get items => _items;
  List<Keeper> get keepers => _keepers;
  List<HandoverReport> get reports => _reports;
  HandoverReport? get latestReport => _reports.isNotEmpty ? _reports.first : null;

  void _loadData() {
    final stockJson = prefs.getString('stock_list');
    if (stockJson != null) {
      _items = (jsonDecode(stockJson) as List).map((e) => StockItem.fromJson(e)).toList();
    } else {
      _items = []; // Start empty for truly new users
    }

    final keepersJson = prefs.getString('keepers_list');
    if (keepersJson != null) {
      _keepers = (jsonDecode(keepersJson) as List).map((e) => Keeper.fromJson(e)).toList();
    } else {
      _keepers = [
        Keeper(id: '1', name: 'Penjaga Toko'),
      ];
    }

    final reportsJson = prefs.getString('reports_list');
    if (reportsJson != null) {
      _reports = (jsonDecode(reportsJson) as List).map((e) => HandoverReport.fromJson(e)).toList();
    }

    activeKeeperId = prefs.getString('active_keeper');
    if (activeKeeperId == null || !_keepers.any((k) => k.id == activeKeeperId)) {
      activeKeeperId = _keepers.isNotEmpty ? _keepers.first.id : null;
    }
    syncUrl = prefs.getString('sync_url');
    spreadsheetUrl = prefs.getString('spreadsheet_url');
    
    // Clean syncUrl if it's in the wrong format (Library/Edit)
    if (syncUrl != null) {
      if (syncUrl!.contains('/library/') || syncUrl!.contains('/edit')) {
        syncUrl = syncUrl!.replaceAll('/library/d/', '/s/').replaceAll('/edit', '/exec');
      }
      if (syncUrl!.contains('script.google.com') && !syncUrl!.contains('/macros/s/')) {
        syncUrl = syncUrl!.replaceFirst('/macros/', '/macros/s/');
      }
    }

    notifyListeners();
  }

  void _saveData() {
    prefs.setString('stock_list', jsonEncode(_items.map((e) => e.toJson()).toList()));
    prefs.setString('keepers_list', jsonEncode(_keepers.map((e) => e.toJson()).toList()));
    prefs.setString('reports_list', jsonEncode(_reports.map((e) => e.toJson()).toList()));
    if (activeKeeperId != null) prefs.setString('active_keeper', activeKeeperId!);
    if (syncUrl != null) prefs.setString('sync_url', syncUrl!);
    if (spreadsheetUrl != null) prefs.setString('spreadsheet_url', spreadsheetUrl!);
  }

  void setSyncUrl(String? url) {
    if (url != null && url.isNotEmpty) {
      // If user pasted a Library/Edit link, try to salvage it or warn them
      if (url.contains('/macros/library/') || url.contains('/edit')) {
        // We can't easily guess the AKfy... ID from a library ID, but we can at least 
        // prevent the app from using a known-broken URL format.
        // For now, let's just ensure it at least tries to use the /s/ format if it starts with macros
        url = url.replaceAll('/macros/library/d/', '/macros/s/');
      }

      if (!url.endsWith('/exec')) {
        url = url.endsWith('/') ? '${url}exec' : '$url/exec';
      }
      if (!url.startsWith('http')) {
        url = 'https://script.google.com/macros/s/$url/exec';
      }
      
      // Final safety: if it's a script.google link but doesn't have /s/, it's likely wrong.
      if (url.contains('script.google.com') && !url.contains('/macros/s/')) {
         // Try to force it into standard format if we detect an ID-like string
         url = url.replaceFirst('/macros/', '/macros/s/');
      }
    }
    syncUrl = url;
    _saveData();
    notifyListeners();
  }

  void setSpreadsheetUrl(String? url) {
    spreadsheetUrl = url;
    _saveData();
    notifyListeners();
  }

  Future<bool> syncToGoogleSheets() async {
    if (syncUrl == null || syncUrl!.isEmpty) return false;
    
    isSyncing = true;
    notifyListeners();

    try {
      final payload = jsonEncode({
        'spreadsheetUrl': spreadsheetUrl,
        'items': _items.map((i) => i.toJson()).toList(),
        'keepers': _keepers.map((k) => k.toJson()).toList(),
        'reports': _reports.map((r) => r.toJson()).toList(),
      });

      // Use 'text/plain' to make it a "simple request" and avoid CORS preflight on Web
      final response = await http.post(
        Uri.parse(syncUrl!),
        headers: {'Content-Type': 'text/plain'},
        body: payload,
      );

      isSyncing = false;
      notifyListeners();
      return response.statusCode == 200 && (response.body.contains("Success") || response.statusCode == 302);
    } catch (e) {
      isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  void commitAudit(List<StockItem> audited, Map<String, int?> auditResults, String toId, double def, double sur, List<String> log) {
    final fromName = _keepers.firstWhere((k) => k.id == activeKeeperId).name;
    final toName = _keepers.firstWhere((k) => k.id == toId).name;

    List<Map<String, dynamic>> auditedItemsLog = [];

    for (var a in audited) {
      final idx = _items.indexWhere((it) => it.id == a.id);
      int newVal = auditResults[a.id] ?? a.currentStock;
      
      auditedItemsLog.add({
        'name': a.name,
        'category': a.category,
        'oldStock': a.currentStock,
        'newStock': newVal,
        'modal': a.modalPrice,
      });

      if (idx != -1) _items[idx].currentStock = newVal;
    }

    _reports.insert(
      0,
      HandoverReport(
        date: DateFormat('dd MMM, HH:mm').format(DateTime.now()),
        fromKeeper: fromName,
        toKeeper: toName,
        deficit: def,
        surplus: sur,
        details: log,
        auditedItems: auditedItemsLog,
      ),
    );

    activeKeeperId = toId; // Switch active keeper
    _saveData();
    notifyListeners();
  }

  void addKeeper(String name) {
    final newKeeper = Keeper(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name);
    _keepers.add(newKeeper);
    _saveData();
    notifyListeners();
  }

  void deleteKeeper(String id) {
    if (_keepers.length <= 1) return; // Must have at least one keeper
    _keepers.removeWhere((k) => k.id == id);
    if (activeKeeperId == id) {
      activeKeeperId = _keepers.first.id;
    }
    _saveData();
    notifyListeners();
  }

  void addProduct(StockItem item) {
    _items.add(item);
    _saveData();
    notifyListeners();
  }

  void editProduct(StockItem item) {
    final index = _items.indexWhere((it) => it.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _saveData();
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((it) => it.id == id);
    _saveData();
    notifyListeners();
  }
}
