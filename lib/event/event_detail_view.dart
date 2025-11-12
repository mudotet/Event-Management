// screens/event_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './event_model.dart';
import './event_service.dart';

class EventDetailView extends StatefulWidget {
  final EventModel originalEvent;

  // Constructor yêu cầu một đối tượng EventModel để làm việc
  const EventDetailView({super.key, required this.originalEvent});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final EventService _service = EventService();
  late EventModel _currentEvent; // Sự kiện đang được chỉnh sửa

  // Controllers cho TextField
  late TextEditingController _subjectController; // Dùng cho subject
  late TextEditingController _notesController;

  // Kiểm tra nếu là sự kiện mới (ID null hoặc trống)
  bool get isNewEvent => _currentEvent.id == null || _currentEvent.id!.isEmpty;

  @override
  void initState() {
    super.initState();
    // Tạo bản sao (copy) của sự kiện gốc để chỉnh sửa
    _currentEvent = widget.originalEvent.copyWith();
    _subjectController = TextEditingController(text: _currentEvent.subject);
    _notesController = TextEditingController(text: _currentEvent.notes);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày/giờ
  Future<void> _pickDateTime(bool isStartTime) async {
    final initialDate = isStartTime
        ? _currentEvent.startTime
        : _currentEvent.endTime;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return;

    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStartTime) {
        _currentEvent.startTime = newDateTime;
        // Đảm bảo EndTime không nhỏ hơn StartTime
        if (_currentEvent.endTime.isBefore(_currentEvent.startTime)) {
          _currentEvent.endTime = _currentEvent.startTime.add(
            const Duration(hours: 1),
          );
        }
      } else {
        _currentEvent.endTime = newDateTime;
        // Đảm bảo EndTime không nhỏ hơn StartTime
        if (_currentEvent.endTime.isBefore(_currentEvent.startTime)) {
          _currentEvent.startTime = _currentEvent.endTime.subtract(
            const Duration(hours: 1),
          );
        }
      }
    });
  }

  // --- Logic Thêm/Sửa/Lưu/Xóa ---

  Future<void> _saveEvent() async {
    _currentEvent.subject = _subjectController.text; // Cập nhật subject
    // Nếu notes trống, lưu là null (phù hợp với EventModel)
    _currentEvent.notes = _notesController.text.isEmpty
        ? null
        : _notesController.text;

    if (_currentEvent.subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chủ đề không được để trống.')),
      );
      return;
    }

    // Đảm bảo EndTime >= StartTime
    if (_currentEvent.endTime.isBefore(_currentEvent.startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian kết thúc phải sau thời gian bắt đầu.'),
        ),
      );
      return;
    }

    await _service.saveEvent(_currentEvent);
    Navigator.of(context).pop(true); // Pop và gửi tín hiệu 'đã thay đổi'
  }

  Future<void> _deleteEvent() async {
    if (_currentEvent.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sự kiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteEvent(_currentEvent.id!);
      Navigator.of(context).pop(true); // Pop và gửi tín hiệu 'đã thay đổi'
    }
  }

  // --- Giao diện ---

  Widget _buildDateTimeRow(String label, DateTime dateTime, bool isStartTime) {
    return ListTile(
      title: Text(label),
      subtitle: Text(DateFormat('EEEE, dd/MM/yyyy HH:mm').format(dateTime)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _pickDateTime(isStartTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNewEvent ? 'Thêm Sự Kiện Mới' : 'Chỉnh Sửa Sự Kiện'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Subject (Chủ đề) Sự kiện
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Chủ đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Sự kiện cả ngày
            SwitchListTile(
              title: const Text('Cả ngày'),
              value: _currentEvent.isAllDay,
              onChanged: (bool value) {
                setState(() {
                  _currentEvent.isAllDay = value;
                });
              },
            ),

            // 3. Thời gian (chỉ hiển thị nếu KHÔNG phải sự kiện cả ngày)
            if (!_currentEvent.isAllDay) ...[
              _buildDateTimeRow('Bắt đầu', _currentEvent.startTime, true),
              _buildDateTimeRow('Kết thúc', _currentEvent.endTime, false),
            ],
            const SizedBox(height: 16),

            // 4. Ghi chú
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ghi chú chi tiết',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // 5. Nút Lưu Sự Kiện
            ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('LƯU SỰ KIỆN', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),

            // 6. Nút Xóa Sự Kiện (Chỉ hiển thị khi chỉnh sửa)
            if (!isNewEvent)
              TextButton(
                onPressed: _deleteEvent,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('XÓA SỰ KIỆN'),
              ),
          ],
        ),
      ),
    );
  }
}
