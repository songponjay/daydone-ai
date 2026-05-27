import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:daydone_ai/domain/entities/work_log.dart';
import 'package:daydone_ai/domain/models/export_column.dart';

class ExcelExportService {
  Future<File> export({
    required List<WorkLog> logs,
    required List<ExportColumn> selectedColumns, // columns ที่ user เลือก
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Work Logs']; // ชื่อ sheet ใน Excel
    workbook.delete('Sheet1'); // ← ลบ Sheet1 ที่ถูกสร้างอัตโนมัติออก

    // 1. สร้าง Header row (บรรทัดแรก — ชื่อ column)
    for (var i = 0; i < selectedColumns.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = TextCellValue(selectedColumns[i].label)
          ..cellStyle = CellStyle(bold: true); // header ตัวหนา
    }

    // 2. สร้าง Data rows (บรรทัดที่ 2 เป็นต้นไป)
    for (var r = 0; r < logs.length; r++) {
      for (var c = 0; c < selectedColumns.length; c++) {
        final value = selectedColumns[c].getValue(logs[r]); // ดึงค่าจาก column
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
            .value = TextCellValue(value);
      }
    }

    // 3. encode() แปลงเป็น bytes — อาจ return null ถ้า sheet ว่าง
    final bytes = workbook.encode();
    if (bytes == null) throw Exception('Excel encode failed — sheet is empty');

    // 4. บันทึกลง temp folder (iOS share_plus ต้องการ temp ไม่ใช่ Documents)
    //final dir = await getTemporaryDirectory();
    // ✅ ใหม่
    final dir = await getDownloadsDirectory();
    if (dir == null) throw Exception('ไม่พบ Downloads folder');
    final file = File(
      '${dir.path}/work_logs_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(bytes);
    return file; // ส่ง File กลับไปให้ UI เอาไป share
  }
}