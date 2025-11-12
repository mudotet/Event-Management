// services/event_service.dart

import 'package:localstore/localstore.dart';
import './event_model.dart';

class EventService {
  // Singleton Pattern
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  // Khởi tạo LocalStore
  final _db = Localstore.instance;
  final String _collectionName = 'events';

  // Load tất cả sự kiện từ LocalStore
  Future<List<EventModel>> loadEvents() async {
    try {
      final items = await _db.collection(_collectionName).get();

      if (items == null) {
        return [];
      }

      // Chuyển đổi Map<String, dynamic> sang List<EventModel>
      return items.entries.map((entry) {
        return EventModel.fromMap(entry.value);
      }).toList();
    } catch (e) {
      print('Lỗi khi tải sự kiện: $e');
      return [];
    }
  }

  // Thêm mới hoặc Cập nhật Sự kiện
  Future<void> saveEvent(EventModel event) async {
    // 1. Kiểm tra và tạo ID nếu là sự kiện mới (Không dùng UUID)
    if (event.id == null || event.id!.isEmpty) {
      // Tạo ID bằng timestamp (millisecondsSinceEpoch)
      event.id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // 2. Lưu sự kiện vào LocalStore
    // Dùng event.id! vì đã đảm bảo nó có giá trị ở bước 1
    await _db.collection(_collectionName).doc(event.id!).set(event.toMap());

    print('Đã lưu/cập nhật sự kiện ID: ${event.id}, Subject: ${event.subject}');
  }

  // Xóa Sự kiện từ LocalStore
  Future<void> deleteEvent(String id) async {
    try {
      await _db.collection(_collectionName).doc(id).delete();
      print('Đã xóa sự kiện ID: $id');
    } catch (e) {
      print('Lỗi khi xóa sự kiện $id: $e');
    }
  }
}

// Phương thức tiện ích để tạo EventModel mới
extension EventModelExtension on EventModel {
  static EventModel newEvent({required DateTime selectedDate}) {
    // id sẽ là null, và sẽ được EventService gán khi lưu
    return EventModel(
      startTime: selectedDate,
      endTime: selectedDate.add(const Duration(hours: 1)),
      subject: 'Sự kiện mới',
    );
  }
}
