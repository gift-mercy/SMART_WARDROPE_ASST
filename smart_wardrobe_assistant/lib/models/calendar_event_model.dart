import 'package:device_calendar/device_calendar.dart';
import 'package:intl/intl.dart';

/// The calendar data passed to the recommendation flow.
/// Device events stay in memory; explicitly-created manual events are stored
/// locally in the existing SQLite database.
enum EventCategory { formal, casual, athletic, professional, unknown }

class CalendarEventModel {
  const CalendarEventModel({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.location,
    this.description,
    this.isManual = false,
    required this.category,
  });

  factory CalendarEventModel.fromDeviceEvent(Event event) {
    final title = (event.title?.trim().isNotEmpty ?? false)
        ? event.title!.trim()
        : 'Untitled Event';
    return CalendarEventModel(
      id: event.eventId ?? '${event.calendarId}-${event.start?.toIso8601String()}',
      title: title,
      startTime: event.start ?? DateTime.now(),
      endTime: event.end,
      location: event.location?.trim().isEmpty ?? true ? null : event.location!.trim(),
      description: event.description?.trim().isEmpty ?? true ? null : event.description!.trim(),
      category: categorize(title),
    );
  }

  factory CalendarEventModel.fromManualMap(Map<String, dynamic> map) {
    final title = map['title'] as String;
    return CalendarEventModel(
      id: 'manual-${map['event_id']}',
      title: title,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] == null ? null : DateTime.parse(map['end_time'] as String),
      description: map['description'] as String?,
      category: categorize(title),
      isManual: true,
    );
  }

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? description;
  final bool isManual;
  final EventCategory category;

  static EventCategory categorize(String title) {
    final text = title.toLowerCase();
    if (_containsAny(text, const [
      'interview', 'business meeting', 'client meeting', 'presentation',
      'conference', 'formal', 'board meeting', 'corporate',
    ])) {
      return EventCategory.formal;
    }
    if (_containsAny(text, const [
      'gym', 'football', 'basketball', 'workout', 'fitness', 'training',
      'run', 'jog', 'yoga', 'sport',
    ])) {
      return EventCategory.athletic;
    }
    if (_containsAny(text, const [
      'movie', 'hangout', 'casual dinner', 'coffee', 'lunch', 'party',
      'birthday', 'brunch', 'dinner',
    ])) {
      return EventCategory.casual;
    }
    if (_containsAny(text, const ['work', 'office', 'project', 'shift'])) {
      return EventCategory.professional;
    }
    return EventCategory.unknown;
  }

  static bool _containsAny(String text, List<String> keywords) =>
      keywords.any(text.contains);

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year && startTime.month == now.month && startTime.day == now.day;
  }
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  int get hoursUntilStart => startTime.difference(DateTime.now()).inHours;
  String get formattedDate => DateFormat('EEEE, d MMMM yyyy').format(startTime);
  String get formattedStartTime => DateFormat.jm().format(startTime);
  String get timeRange => endTime == null
      ? formattedStartTime
      : '$formattedStartTime - ${DateFormat.jm().format(endTime!)}';
  String get categoryName => switch (category) {
        EventCategory.formal => 'Formal',
        EventCategory.casual => 'Casual',
        EventCategory.athletic => 'Athletic',
        EventCategory.professional => 'Professional',
        EventCategory.unknown => 'General',
      };
  int get categoryColor => switch (category) {
        EventCategory.formal => 0xFF4F46E5,
        EventCategory.casual => 0xFF14B8A6,
        EventCategory.athletic => 0xFFEF4444,
        EventCategory.professional => 0xFF6366F1,
        EventCategory.unknown => 0xFF64748B,
      };
}
