import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

import '../models/calendar_event_model.dart';
import '../services/calendar_service.dart';

enum CalendarPermissionState { unknown, granted, denied, requesting }

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({CalendarService? service})
      : _service = service ?? CalendarService.instance;

  final CalendarService _service;
  final List<CalendarEventModel> _events = [];
  List<Calendar> _availableCalendars = const [];
  CalendarEventModel? _selectedEvent;
  CalendarPermissionState _permissionState = CalendarPermissionState.unknown;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  DateTime _loadedMonth = _firstDayOfMonth(DateTime.now());
  int? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  List<CalendarEventModel> get upcomingEvents => List.unmodifiable(_events);
  List<Calendar> get availableCalendars => List.unmodifiable(_availableCalendars);
  DateTime get selectedDate => _selectedDate;
  DateTime get loadedMonth => _loadedMonth;
  int get upcomingEventCount => _events.length;
  CalendarEventModel? get nextEvent {
    for (final event in _events) {
      if (event.isUpcoming) return event;
    }
    return null;
  }
  CalendarEventModel? get selectedEvent => _selectedEvent ?? nextEvent;
  CalendarPermissionState get permissionState => _permissionState;
  bool get hasPermission => _permissionState == CalendarPermissionState.granted;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CalendarEventModel> get selectedDateEvents => eventsForDay(_selectedDate);

  List<CalendarEventModel> eventsForDay(DateTime date) {
    final day = DateUtils.dateOnly(date);
    return _events.where((event) => DateUtils.isSameDay(event.startTime, day)).toList(growable: false);
  }

  bool hasEventsOn(DateTime day) => eventsForDay(day).isNotEmpty;

  Future<void> setUserId(int? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    if (hasPermission) await loadMonth(_loadedMonth);
  }

  Future<void> initialize() async {
    if (_permissionState == CalendarPermissionState.unknown) {
      await checkPermission();
    }
    if (hasPermission) await loadMonth(_loadedMonth);
  }

  Future<void> checkPermission() async {
    try {
      _permissionState = await _service.hasCalendarPermission()
          ? CalendarPermissionState.granted
          : CalendarPermissionState.denied;
      _errorMessage = null;
    } catch (_) {
      _permissionState = CalendarPermissionState.unknown;
      _errorMessage = 'Unable to check calendar permission.';
    }
    notifyListeners();
  }

  Future<bool> requestCalendarPermission() async {
    if (_permissionState == CalendarPermissionState.requesting) return false;
    _permissionState = CalendarPermissionState.requesting;
    _errorMessage = null;
    notifyListeners();
    try {
      final granted = await _service.requestCalendarPermission();
      debugPrint('Calendar permission request completed: granted=$granted');
      _permissionState = granted
          ? CalendarPermissionState.granted
          : CalendarPermissionState.denied;
      notifyListeners();
      if (granted) await loadMonth(_loadedMonth);
      return granted;
    } catch (_) {
      _permissionState = CalendarPermissionState.denied;
      _errorMessage = 'Unable to request calendar access.';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMonth(DateTime month) async {
    _loadedMonth = _firstDayOfMonth(month);
    if (!hasPermission || _isLoading) {
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final start = _loadedMonth;
    final end = DateTime(start.year, start.month + 1);
    debugPrint('Loading calendar events for ${start.year}-${start.month}.');
    try {
      _availableCalendars = await _service.getAvailableCalendars();
      debugPrint('Device calendars found: ${_availableCalendars.length}.');
      final deviceEvents = await _service.getDeviceEvents(
        startDate: start,
        endDate: end,
        calendars: _availableCalendars,
      );
      final manualEvents = _userId == null
          ? const <CalendarEventModel>[]
          : await _service.getManualEvents(
              userId: _userId!, startDate: start, endDate: end);
      _events
        ..clear()
        ..addAll([...deviceEvents, ...manualEvents]..sort((a, b) => a.startTime.compareTo(b.startTime)));
      debugPrint('Calendar events loaded: ${_events.length}.');
      if (_selectedEvent != null && !_events.any((event) => event.id == _selectedEvent!.id)) {
        _selectedEvent = null;
      }
    } on CalendarAccessException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load calendar events. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEvents() => loadMonth(_loadedMonth);

  Future<void> selectDate(DateTime date) async {
    _selectedDate = DateUtils.dateOnly(date);
    notifyListeners();
  }

  void selectEvent(CalendarEventModel? event) {
    _selectedEvent = event;
    notifyListeners();
  }

  Future<bool> addManualEvent({
    required String title,
    String? description,
    required DateTime startTime,
  }) async {
    if (_userId == null) {
      _errorMessage = 'Please sign in to save a calendar event.';
      notifyListeners();
      return false;
    }
    try {
      final event = await _service.addManualEvent(
        userId: _userId!,
        title: title,
        description: description,
        startTime: startTime,
      );
      if (event.startTime.year == _loadedMonth.year && event.startTime.month == _loadedMonth.month) {
        _events.add(event);
        _events.sort((a, b) => a.startTime.compareTo(b.startTime));
      }
      _selectedEvent = event;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Unable to save this event. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> openSettings() => _service.openCalendarSettings();

  static DateTime _firstDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month);
}
