import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/calendar_event_model.dart';

/// The single integration point for device calendars and locally-created
/// calendar items. Device events are read only and are never persisted.
class CalendarService {
  CalendarService._();
  static final CalendarService instance = CalendarService._();

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  Future<bool> hasCalendarPermission() async {
    final result = await _plugin.hasPermissions();
    return result.isSuccess && result.data == true;
  }

  Future<bool> requestCalendarPermission() async {
    final result = await _plugin.requestPermissions();
    return result.isSuccess && result.data == true;
  }

  Future<void> openCalendarSettings() async {
    await permissions.openAppSettings();
  }

  Future<List<Calendar>> getAvailableCalendars() async {
    if (!await hasCalendarPermission()) {
      throw const CalendarAccessException('Calendar access has not been granted.');
    }
    final result = await _plugin.retrieveCalendars();
    if (!result.isSuccess || result.data == null) {
      throw const CalendarAccessException('The device calendars could not be read.');
    }
    return result.data!.where((calendar) => calendar.id != null).toList(growable: false);
  }

  Future<List<CalendarEventModel>> getDeviceEvents({
    required DateTime startDate,
    required DateTime endDate,
    List<Calendar>? calendars,
  }) async {
    final sources = calendars ?? await getAvailableCalendars();
    final events = <CalendarEventModel>[];
    for (final calendar in sources) {
      final calendarId = calendar.id;
      if (calendarId == null) continue;
      final result = await _plugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(startDate: startDate, endDate: endDate),
      );
      if (!result.isSuccess) {
        throw const CalendarAccessException('One or more calendar events could not be read.');
      }
      events.addAll((result.data ?? const <Event>[])
          .where((event) => event.start != null)
          .map(CalendarEventModel.fromDeviceEvent));
    }
    final seen = <String>{};
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events.where((event) => seen.add(event.id)).toList(growable: false);
  }

  Future<List<CalendarEventModel>> getManualEvents({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      TableNames.manualCalendarEvents,
      where: 'user_id = ? AND start_time >= ? AND start_time < ?',
      whereArgs: [userId, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'start_time ASC',
    );
    return rows.map(CalendarEventModel.fromManualMap).toList(growable: false);
  }

  Future<CalendarEventModel> addManualEvent({
    required int userId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert(TableNames.manualCalendarEvents, {
      'user_id': userId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.abort);
    return CalendarEventModel.fromManualMap({
      'event_id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    });
  }
}

class CalendarAccessException implements Exception {
  const CalendarAccessException(this.message);
  final String message;

  @override
  String toString() => message;
}
