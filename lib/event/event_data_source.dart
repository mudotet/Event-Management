import 'dart:ui';

import 'package:event_manager/event/event_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<EventModel> appointments) {
    this.appointments = appointments;
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index] as EventModel).startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index] as EventModel).endTime;
  }

  @override
  String getSubject(int index) {
    return (appointments![index] as EventModel).subject;
  }

  @override
  String? getNotes(int index) {
    return (appointments![index] as EventModel).notes;
  }

  @override
  bool isAllDay(int index) {
    return (appointments![index] as EventModel).isAllDay;
  }

  @override
  Color getColor(int index) {
    return (appointments![index] as EventModel).isAllDay
        ? const Color(0xFF42A5F5)
        : const Color(0xFF66BB6A);
  }
}
