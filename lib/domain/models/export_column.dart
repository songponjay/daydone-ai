// import entity WorkLog ที่อยู่อีกไฟล์ — ถ้าไม่ import Dart ไม่รู้จัก WorkLog
import 'package:daydone_ai/domain/entities/work_log.dart';

// ✅ Column รู้วิธีดึงค่าของตัวเอง
class ExportColumn {
  final String label;                        // ชื่อที่แสดงใน header ของ Excel
  final String Function(WorkLog) getValue;   // function: รับ WorkLog คืน String

  const ExportColumn({
    required this.label,
    required this.getValue,
  });
}

// columns ทั้งหมดที่ export ได้ — user จะเลือกจาก list นี้
final List<ExportColumn> kAvailableColumns = [
  ExportColumn(label: 'Date',    getValue: (l) => l.date.toString()),
  ExportColumn(label: 'Content', getValue: (l) => l.content),
  ExportColumn(label: 'Tags',    getValue: (l) => l.tags.join(', ')),
];