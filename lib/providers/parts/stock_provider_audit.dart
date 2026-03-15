part of '../stock_provider.dart';

extension StockProviderAudit on StockProvider {
  void commitAudit(List<StockItem> audited, Map<String, int?> auditResults, String toId, double def, double sur, List<String> log) {
    final fromName = _users.firstWhere((u) => u.id == activeKeeperId).name;
    final toName = _users.firstWhere((u) => u.id == toId).name;

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

      if (idx != -1) {
        _items[idx].currentStock = newVal;
        _items[idx].modalPrice = a.modalPrice;
      }
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
    clearAuditDraft();
    _saveData();
    refresh();
  }

  void updateAuditDraft(String itemId, int? count, double? price) {
    if (count != null) _auditDraftResults[itemId] = count;
    if (price != null) _auditDraftPrices[itemId] = price;
    _saveData();
  }

  void setAuditDraftToKeeper(String? keeperId) {
    _auditDraftToKeeperId = keeperId;
    _saveData();
    refresh();
  }

  void clearAuditDraft() {
    _auditDraftResults.clear();
    _auditDraftPrices.clear();
    _auditDraftToKeeperId = null;
    _saveData();
    refresh();
  }
}
