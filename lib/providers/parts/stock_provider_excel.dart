part of '../stock_provider.dart';

extension StockProviderExcel on StockProvider {
  void addProduct(StockItem item) {
    _items.add(item);
    _saveData();
    refresh();
  }

  void editProduct(StockItem item) {
    final index = _items.indexWhere((it) => it.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _saveData();
      refresh();
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((it) => it.id == id);
    _saveData();
    refresh();
  }

  Future<bool> importDemoData() async {
    try {
      for (var row in rawDemoData) {
        final category = row['category'] as String;
        final name = row['name'] as String;
        final price = row['price'] as double;

        final existingIdx = _items.indexWhere((it) => it.name == name);
        if (existingIdx != -1) {
          _items[existingIdx] = StockItem(
            id: _items[existingIdx].id,
            category: _items[existingIdx].category,
            name: _items[existingIdx].name,
            modalPrice: _items[existingIdx].modalPrice,
            currentStock: _items[existingIdx].currentStock,
            isDemo: true,
          );
        } else {
          _items.add(StockItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + _items.length.toString(),
            name: name,
            category: category,
            modalPrice: price,
            currentStock: 10,
            isDemo: true,
          ));
        }
      }

      _saveData();
      refresh();
      return true;
    } catch (e) {
      debugPrint('Error importing demo data: $e');
      return false;
    }
  }

  void resetDemoData() {
    _items.removeWhere((it) => it.isDemo);
    _saveData();
    refresh();
  }

  Future<void> exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    
    sheet.appendRow([
      TextCellValue('Kategori'),
      TextCellValue('Nama Barang'),
      TextCellValue('Harga Modal'),
      TextCellValue('Stok Sekarang')
    ]);

    for (var item in _items) {
      sheet.appendRow([
        TextCellValue(item.category),
        TextCellValue(item.name),
        DoubleCellValue(item.modalPrice),
        IntCellValue(item.currentStock)
      ]);
    }

    final fileName = 'DATA_STOK_${storeName?.replaceAll(' ', '_').toUpperCase() ?? 'TOKO'}.xlsx';
    final bytes = excel.save(fileName: fileName);
    if (bytes == null) return;

    if (kIsWeb) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, name: fileName)], 
      text: 'Ekspor Stok Barang $storeName'
    ));
  }

  Future<void> generateExcelTemplate() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    
    sheet.appendRow([
      TextCellValue('Kategori'),
      TextCellValue('Nama Barang'),
      TextCellValue('Harga Modal'),
      TextCellValue('Stok Sekarang')
    ]);

    sheet.appendRow([
      TextCellValue('MINUMAN'),
      TextCellValue('CONTOH AQUA'),
      DoubleCellValue(4000),
      IntCellValue(10)
    ]);

    final fileName = 'TEMPLATE_IMPORT_STOK.xlsx';
    final bytes = excel.save(fileName: fileName);
    if (bytes == null) return;

    if (kIsWeb) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, name: fileName)], 
      text: 'Template Import Stok Barang'
    ));
  }

  Future<String?> importFromExcel({bool clearExisting = false}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final bytes = result.files.first.bytes;
    
    if (bytes == null) {
      if (result.files.first.path != null) {
        final file = File(result.files.first.path!);
        return _processImport(await file.readAsBytes());
      }
      return 'Gagal membaca file';
    }
    
    return _processImport(bytes, clearExisting: clearExisting);
  }

  Future<String?> _processImport(Uint8List bytes, {bool clearExisting = false}) async {
    final excel = Excel.decodeBytes(bytes);

    if (clearExisting) {
      _items.clear();
    }

    int count = 0;
    for (var table in excel.tables.keys) {
      final rows = excel.tables[table]!.rows;
      if (rows.isEmpty) continue;

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 3) continue;

        final category = row[0]?.value?.toString().trim().toUpperCase() ?? '';
        final name = row[1]?.value?.toString().trim().toUpperCase() ?? '';
        final price = double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0.0;
        final stock = int.tryParse(row[3]?.value?.toString() ?? '0') ?? 0;

        if (name.isEmpty) continue;

        final existingIdx = _items.indexWhere((it) => it.name.toLowerCase() == name.toLowerCase());
        if (existingIdx != -1) {
          final existing = _items[existingIdx];
          _items[existingIdx] = StockItem(
            id: existing.id,
            name: name,
            category: category.isEmpty ? existing.category : category,
            modalPrice: price,
            currentStock: stock,
            isDemo: existing.isDemo,
          );
        } else {
          _items.add(StockItem(
            id: 'PROD_${DateTime.now().millisecondsSinceEpoch}_${count}_${name.hashCode.abs()}',
            name: name,
            category: category.isEmpty ? 'LAIN-LAIN' : category,
            modalPrice: price,
            currentStock: stock,
          ));
        }
        count++;
      }
    }

    if (count > 0) {
      _saveData();
      refresh();
      return 'Berhasil mengimpor $count barang';
    }
    return 'Tidak ada data valid yang ditemukan';
  }
}
