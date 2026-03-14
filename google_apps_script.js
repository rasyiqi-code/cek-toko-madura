function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var spreadsheetUrl = data.spreadsheetUrl;
    var ss;
    
    if (spreadsheetUrl) {
      ss = SpreadsheetApp.openByUrl(spreadsheetUrl);
    } else {
      ss = SpreadsheetApp.getActiveSpreadsheet();
    }

    if (!ss) throw new Error("Spreadsheet not found.");

    var reports = data.reports || [];
    
    // 1. Handle Categorized Sheets based on Latest Report
    if (reports.length > 0) {
      var latestReport = reports[0];
      var auditedItems = latestReport.auditedItems || [];
      var reportDate = latestReport.date; // e.g. "14 Mar, 23:15"

      // Group items by category
      var categories = {};
      auditedItems.forEach(function(item) {
        if (!categories[item.category]) categories[item.category] = [];
        categories[item.category].push(item);
      });

      // Create/Update Category Sheets
      Object.keys(categories).forEach(function(catName) {
        var sheet = getOrCreateSheet(ss, catName);
        sheet.clear();
        
        // Header Setup (Matching screenshot 3)
        sheet.getRange("A1:A2").merge().setValue("NO");
        sheet.getRange("B1:B2").merge().setValue("NAMA BARANG");
        sheet.getRange("C1:E1").merge().setValue("JUMLAH BARANG");
        sheet.getRange("C2").setValue("LAMA");
        sheet.getRange("D2").setValue("KET");
        sheet.getRange("E2").setValue("BARU");
        sheet.getRange("F1:F2").merge().setValue("SELISIH");
        sheet.getRange("G1:G2").merge().setValue("MODAL");
        sheet.getRange("H1:H2").merge().setValue("HARGA");

        var headerRange = sheet.getRange(1, 1, 2, 8);
        headerRange.setBackground("#FFFF00").setFontWeight("bold").setHorizontalAlignment("center").setVerticalAlignment("middle").setBorder(true, true, true, true, true, true);

        // Data Rows
        var rowData = [];
        categories[catName].forEach(function(item, index) {
          var selisih = item.newStock - item.oldStock;
          var totalHarga = selisih * item.modal;
          
          rowData.push([
            index + 1,
            item.name,
            item.oldStock,
            "bks", // Default unit
            item.newStock,
            selisih,
            item.modal,
            totalHarga
          ]);
        });
        
        if (rowData.length > 0) {
          var dataRange = sheet.getRange(3, 1, rowData.length, 8);
          dataRange.setValues(rowData).setBorder(true, true, true, true, true, true);
          
          // Formatting
          for (var i = 0; i < rowData.length; i++) {
            var rowIdx = 3 + i;
            var selisihVal = rowData[i][5];
            if (selisihVal < 0) {
              sheet.getRange(rowIdx, 6).setFontColor("red");
              sheet.getRange(rowIdx, 8).setFontColor("red");
            }
          }
          sheet.getRange(3, 7, rowData.length, 2).setNumberFormat("#,##0");
        }
        sheet.autoResizeColumns(1, 8);
      });

      // 2. Create/Update Rekap Total Sheet (Matching screenshot 2)
      var rekapSheet = getOrCreateSheet(ss, "Rekap Total");
      rekapSheet.clear();
      rekapSheet.setColumnWidth(2, 200);
      rekapSheet.setColumnWidth(3, 150);
      
      rekapSheet.getRange("A1:C1").merge().setBackground("#FFFF00").setFontWeight("bold").setHorizontalAlignment("center").setValue("DAFTAR REKAPITULASI");
      rekapSheet.getRange("A2").setBackground("#FFFF00").setFontWeight("bold").setValue("NO");
      rekapSheet.getRange("B2").setBackground("#FFFF00").setFontWeight("bold").setValue("KATEGORI");
      rekapSheet.getRange("C2").setBackground("#FFFF00").setFontWeight("bold").setValue("HASIL TOTAL");
      rekapSheet.getRange("A2:C2").setBorder(true, true, true, true, true, true);
      
      var rekapData = [];
      var grandTotal = 0;
      Object.keys(categories).forEach(function(catName, index) {
        var catTotal = categories[catName].reduce(function(sum, item) {
          return sum + ((item.newStock - item.oldStock) * item.modal);
        }, 0);
        grandTotal += catTotal;
        rekapData.push([index + 1, catName, catTotal]);
      });
      
      if (rekapData.length > 0) {
        var rekapRange = rekapSheet.getRange(3, 1, rekapData.length, 3);
        rekapRange.setValues(rekapData).setBorder(true, true, true, true, true, true);
        rekapSheet.getRange(3, 3, rekapData.length, 1).setNumberFormat("\"Rp \"#,##0");
      }
      
      var totalRowIdx = 3 + rekapData.length;
      rekapSheet.getRange(totalRowIdx, 1, 1, 2).merge().setBackground("#FFFF00").setFontWeight("bold").setHorizontalAlignment("center").setValue("TOTAL");
      rekapSheet.getRange(totalRowIdx, 3).setBackground("#FFFF00").setFontWeight("bold").setValue(grandTotal).setNumberFormat("\"Rp \"#,##0").setBorder(true, true, true, true, true, true);
      rekapSheet.getRange(totalRowIdx, 1, 1, 2).setBorder(true, true, true, true, true, true);

      // Audit Info (Side box)
      rekapSheet.getRange("E2:G2").merge().setValue("TOTAL REKAPAN SEMUA KATEGORI BARANG").setFontWeight("bold").setHorizontalAlignment("center").setVerticalAlignment("middle").setBorder(true, true, true, true, null, null);
      rekapSheet.getRange("E6:G6").merge().setValue("Dicek Pada:").setFontWeight("bold").setHorizontalAlignment("center").setBorder(true, true, true, true, null, null);
      
      var now = new Date();
      rekapSheet.getRange("E8").setValue("Tanggal").setBorder(true, true, true, true, true, true);
      rekapSheet.getRange("E9").setValue("Bulan").setBorder(true, true, true, true, true, true);
      rekapSheet.getRange("E10").setValue("Tahun").setBorder(true, true, true, true, true, true);
      
      rekapSheet.getRange("F8:G8").merge().setValue(now.getDate()).setBorder(true, true, true, true, true, true);
      rekapSheet.getRange("F9:G9").merge().setValue(now.getMonth() + 1).setBorder(true, true, true, true, true, true);
      rekapSheet.getRange("F10:G10").merge().setValue(now.getFullYear()).setBorder(true, true, true, true, true, true);
    } else {
      // Fallback: Just sync general inventory if no reports found
      var itemSheet = getOrCreateSheet(ss, "Inventory");
      itemSheet.clear();
      itemSheet.appendRow(["ID", "Category", "Name", "Modal", "Stock"]);
      data.items.forEach(function(item) {
        itemSheet.appendRow([item.id, item.category, item.name, item.modalPrice, item.currentStock]);
      });
    }

    return ContentService.createTextOutput("Success").setMimeType(ContentService.MimeType.TEXT);
  } catch (err) {
    return ContentService.createTextOutput("Error: " + err.toString()).setMimeType(ContentService.MimeType.TEXT);
  }
}

function getOrCreateSheet(ss, name) {
  var sheet = ss.getSheetByName(name);
  if (!sheet) {
    sheet = ss.insertSheet(name);
  }
  return sheet;
}
