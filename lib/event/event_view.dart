// screens/event_view.dart (Bản cập nhật sử dụng SfCalendar)

import 'package:flutter/material.dart';
import './event_model.dart';
import './event_service.dart';
import './event_data_source.dart';
import './event_detail_view.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Import SfCalendar

// Loại bỏ class CalendarWidget mô phỏng
// Chúng ta sẽ sử dụng SfCalendar trực tiếp trong EventView

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final EventService _service = EventService();
  List<EventModel> _events = [];
  bool _isLoading = true;

  // Controller để điều khiển lịch (ví dụ: thay đổi chế độ xem)
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _calendarController.view = CalendarView.month; // Đặt chế độ xem mặc định
  }

  // Hàm xử lý sự kiện khi nhấn (tap) vào một sự kiện hoặc một ô trống
  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      // Logic Sửa sự kiện: Nhấn vào một sự kiện có sẵn
      final EventModel event = details.appointments!.first as EventModel;
      _navigateToDetail(event);
    } else if (details.targetElement == CalendarElement.calendarCell) {
      // Logic Thêm sự kiện: Nhấn vào ô trống (mô phỏng LongPress)
      _onCalendarLongPress(details.date!);
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    final events = await _service.loadEvents();
    events.sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  void _navigateToDetail(EventModel event) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailView(originalEvent: event),
      ),
    );

    if (result == true) {
      _loadEvents(); // Tải lại danh sách sau khi Lưu/Xóa
    }
  }

  // Hàm xử lý khi nhấn giữ (LongPress) vào ô trống trên lịch
  void _onCalendarLongPress(DateTime date) {
    // Tạo sự kiện mới với thời gian được chọn
    final newEvent = EventModelExtension.newEvent(selectedDate: date);
    _navigateToDetail(newEvent); // Điều hướng đến màn hình Thêm mới
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = EventDataSource(_events);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Sự Kiện'),
        actions: [
          // Nút quay về ngày hiện tại
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              _calendarController.displayDate = DateTime.now();
            },
          ),
          // Nút làm mới
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SfCalendar(
              view: CalendarView.month, // Chế độ xem mặc định
              controller: _calendarController,
              dataSource: dataSource, // Cung cấp dữ liệu sự kiện
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showAgenda: true, // Hiển thị danh sách sự kiện dưới lịch tháng
              ),
              // Xử lý sự kiện nhấn (thêm/sửa)
              onTap: _onCalendarTapped,
              // Trong SfCalendar, thường dùng onTap để xử lý cả việc thêm (khi nhấn vào cell)
              // và sửa (khi nhấn vào appointment).
            ),
      // FloatingActionButton vẫn dùng cho việc thêm sự kiện nhanh vào ngày hiện tại
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCalendarLongPress(DateTime.now()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
