import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:daydone_ai/domain/models/export_column.dart';
import 'package:daydone_ai/data/services/excel_export_service.dart';
import 'package:daydone_ai/presentation/providers/export_provider.dart';
import 'package:daydone_ai/presentation/providers/work_log_notifier.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ดึง columns ที่ user เลือกไว้
    final selectedColumns = ref.watch(exportProvider);


    return Scaffold(
      appBar: AppBar(title: const Text('Export Excel')),
      body: Column(
        children: [
          // --- Checkbox list เลือก column ---
          ...kAvailableColumns.map((col) => CheckboxListTile(
                title: Text(col.label),
                value: selectedColumns.contains(col), // ติ๊กอยู่ไหม
                onChanged: (_) =>
                    ref.read(exportProvider.notifier).toggle(col), // toggle
              )),

          const Divider(),

          // --- ปุ่ม Export ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              // ปุ่ม disable ถ้ายังไม่เลือก column หรือ logs ยังโหลดไม่เสร็จ
              onPressed: selectedColumns.isEmpty
                  ? null
                  : () => _export(context, ref, selectedColumns),
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    Set<ExportColumn> selectedColumns,
  ) async {
    final logs =
        ref.read(workLogNotifierProvider).valueOrNull ?? []; // ดึง logs

    if (logs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ไม่มีข้อมูลให้ export')));
      return;
    }

    /*try {
      // สร้างไฟล์ .xlsx
      final file = await ExcelExportService().export(
        logs: logs,
        selectedColumns: selectedColumns.toList(),
      );
      // เปิด share sheet ให้ user เลือกส่งไปไหน
      // ✅ ใหม่ v13
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Work Log Export',
        ),
      );
    }  catch (e) {
      // ✅ เช็คก่อนว่า widget ยังอยู่บนหน้าจออยู่ไหม
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export ผิดพลาด: $e')));
      }
    }*/
    try {
        final file = await ExcelExportService().export(
          logs: logs,
          selectedColumns: selectedColumns.toList(),
        );

        // Windows เปิด File Explorer แทน share sheet
        if (Platform.isWindows) {
          // ✅ ใหม่ — รวม /select, กับ path เป็น argument เดียว
          await Process.run('explorer.exe', [file.parent.path]);
          //-2await Process.run('explorer.exe', ['/select,${file.path}']);
          //await Process.run('explorer.exe', ['/select,', file.path]);
        } else {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              subject: 'Work Log Export',
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Export ผิดพลาด: $e')));
        }
      }
  }
}