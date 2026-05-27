import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daydone_ai/domain/models/export_column.dart';

// State: Set ของ column ที่ user เลือก (Set = ไม่มีซ้ำ)
class ExportNotifier extends Notifier<Set<ExportColumn>> {
  @override
  Set<ExportColumn> build() => {}; // เริ่มต้นไม่มี column ถูกเลือก

  // toggle: ถ้าเลือกอยู่แล้ว → เอาออก, ถ้ายังไม่เลือก → เพิ่มเข้า
  void toggle(ExportColumn column) {
    final current = Set<ExportColumn>.from(state);
    if (current.contains(column)) {
      current.remove(column);
    } else {
      current.add(column);
    }
    state = current;
  }

  // เลือกทั้งหมดทีเดียว
  void selectAll() {
    state = Set<ExportColumn>.from(kAvailableColumns);
  }

  // ล้างทั้งหมด
  void clearAll() {
    state = {};
  }
}

// Provider ที่ UI จะเรียกใช้
final exportProvider =
    NotifierProvider<ExportNotifier, Set<ExportColumn>>(ExportNotifier.new);