import 'package:dio/dio.dart';
import '../models/work_log_model.dart';

class WorkLogRemoteDatasource {
  final Dio _dio;
  WorkLogRemoteDatasource(this._dio); // ← รับ Dio เข้ามา (เหมือน local รับ DB)

  Future<List<WorkLogModel>> getAll() async {
    final response = await _dio.get('/work-logs');
    
    // response.data คือ List<dynamic> จาก JSON
    // ต้องแปลงแต่ละ item เป็น WorkLogModel
    // คำใบ้: WorkLogModel มี fromMap() อยู่แล้ว ใช้ได้เลย ✅
    
    return (response.data as List)
        .map((item) => WorkLogModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(WorkLogModel model) async {
    await _dio.post('/work-logs', data: model.toMap());
  }
}