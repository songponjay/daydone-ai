// lib/presentation/screens/work_log_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/work_log.dart';
import '../providers/work_log_notifier.dart';

class WorkLogFormScreen extends ConsumerStatefulWidget {
  // ถ้า workLog == null → Add mode, ถ้ามีค่า → Edit mode
  final WorkLog? workLog;

  const WorkLogFormScreen({super.key, this.workLog});

  @override
  ConsumerState<WorkLogFormScreen> createState() => _WorkLogFormScreenState();
}

class _WorkLogFormScreenState extends ConsumerState<WorkLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    // ถ้า Edit mode → prefill ข้อมูลเดิมลงฟอร์ม
    _contentController = TextEditingController(
      text: widget.workLog?.content ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.workLog?.tags.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    // ต้อง dispose controller เสมอ ไม่งั้น memory leak
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // validate form ก่อนบันทึก
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final log = WorkLog(
      // Edit mode → ใช้ id เดิม, Add mode → null (DB จะ auto-increment)
      id: widget.workLog?.id,
      date: DateTime.now(),
      content: _contentController.text.trim(),
      tags: tags,
    );

    await ref.read(workLogNotifierProvider.notifier).saveLog(log);

    if (mounted) Navigator.of(context).pop(); // กลับหน้าก่อน
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.workLog != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'แก้ไข Work Log' : 'เพิ่ม Work Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ช่อง Content
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'สิ่งที่ทำวันนี้',
                  hintText: 'เช่น ประชุม sprint planning, fix bug login',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'กรุณาใส่รายละเอียด' : null,
              ),
              const SizedBox(height: 16),

              // ช่อง Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (คั่นด้วยจุลภาค)',
                  hintText: 'เช่น meeting, bugfix, design',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // ปุ่ม Save
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(isEditMode ? 'บันทึกการแก้ไข' : 'บันทึก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}