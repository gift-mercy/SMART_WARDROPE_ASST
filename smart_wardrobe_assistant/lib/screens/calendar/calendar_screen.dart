import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../widgets/calendar_event_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final calendar = context.read<CalendarProvider>();
      await calendar.setUserId(context.read<AuthProvider>().currentUser?.userId);
      await calendar.initialize();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Calendar'),
          actions: [
            Consumer<CalendarProvider>(
              builder: (context, calendar, child) => calendar.hasPermission
                  ? IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh events',
                      onPressed: calendar.isLoading ? null : calendar.refreshEvents,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        body: Consumer<CalendarProvider>(
          builder: (context, calendar, _) {
            if (!calendar.hasPermission) return _permissionView(calendar);
            return _calendarView(calendar);
          },
        ),
      );

  Widget _permissionView(CalendarProvider calendar) {
    final isRequesting = calendar.permissionState == CalendarPermissionState.requesting;
    final denied = calendar.permissionState == CalendarPermissionState.denied;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .1), shape: BoxShape.circle),
                child: const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text(denied ? 'Calendar Access Denied' : 'Connect Your Calendar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                denied
                    ? 'No calendar access was granted. You can enable it from your device settings, or add an event manually below.'
                    : 'Allow access to your device calendar to view events and receive outfit recommendations based on your schedule.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isRequesting ? null : calendar.requestCalendarPermission,
                  icon: isRequesting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_open_outlined),
                  label: Text(isRequesting ? 'Requesting Access...' : denied ? 'Allow Calendar Access' : 'Allow Calendar Access'),
                ),
              ),
              if (denied) ...[
                const SizedBox(height: 10),
                TextButton.icon(onPressed: calendar.openSettings, icon: const Icon(Icons.settings_outlined), label: const Text('Open Settings')),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddEventSheet(calendar),
                icon: const Icon(Icons.add),
                label: const Text('Add Event Manually'),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _calendarView(CalendarProvider calendar) => RefreshIndicator(
        onRefresh: calendar.refreshEvents,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2035),
                  focusedDay: calendar.loadedMonth,
                  selectedDayPredicate: (day) => isSameDay(day, calendar.selectedDate),
                  eventLoader: calendar.eventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    markerDecoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                    markersMaxCount: 3,
                  ),
                  headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
                  onDaySelected: (selected, _) => calendar.selectDate(selected),
                  onPageChanged: calendar.loadMonth,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _selectedDayHeader(calendar),
            const SizedBox(height: 10),
            if (calendar.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (calendar.errorMessage != null)
              _errorCard(calendar)
            else if (calendar.selectedDateEvents.isEmpty)
              _emptyDayCard(calendar)
            else
              ...calendar.selectedDateEvents.map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CalendarEventCard(
                      event: event,
                      onTap: () => calendar.selectEvent(event),
                    ),
                  )),
            if (calendar.availableCalendars.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('${calendar.availableCalendars.length} device calendar${calendar.availableCalendars.length == 1 ? '' : 's'} connected', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ],
        ),
      );

  Widget _selectedDayHeader(CalendarProvider calendar) => Row(
        children: [
          Expanded(child: Text(DateFormat('EEEE, d MMMM').format(calendar.selectedDate), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          TextButton.icon(onPressed: () => _showAddEventSheet(calendar), icon: const Icon(Icons.add, size: 18), label: const Text('Add Event')),
        ],
      );

  Widget _emptyDayCard(CalendarProvider calendar) => Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Icon(Icons.event_available_outlined, color: AppColors.textSecondary, size: 38),
            const SizedBox(height: 8),
            const Text('No events for this day', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Add one manually to use it for outfit recommendations.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          ]),
        ),
      );

  Widget _errorCard(CalendarProvider calendar) => Card(
        color: AppColors.error.withValues(alpha: .06),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(calendar.errorMessage!, textAlign: TextAlign.center),
            TextButton(onPressed: calendar.refreshEvents, child: const Text('Try Again')),
          ]),
        ),
      );

  Future<void> _showAddEventSheet(CalendarProvider calendar) async {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController();
    final description = TextEditingController();
    DateTime eventDate = calendar.selectedDate;
    TimeOfDay selectedTime = TimeOfDay.now();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(DateFormat('EEEE, d MMMM yyyy').format(eventDate), style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Choose date'),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: eventDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (date != null) setSheetState(() => eventDate = date);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Event title'), validator: (value) => value == null || value.trim().isEmpty ? 'Enter an event title.' : null),
              const SizedBox(height: 12),
              TextFormField(controller: description, decoration: const InputDecoration(labelText: 'Description (optional)'), maxLines: 2),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text('Time: ${selectedTime.format(context)}'),
                onPressed: () async {
                  final time = await showTimePicker(context: context, initialTime: selectedTime);
                  if (time != null) setSheetState(() => selectedTime = time);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final dateTime = DateTime(eventDate.year, eventDate.month, eventDate.day, selectedTime.hour, selectedTime.minute);
                    final saved = await calendar.addManualEvent(title: title.text.trim(), description: description.text.trim().isEmpty ? null : description.text.trim(), startTime: dateTime);
                    if (sheetContext.mounted && saved) Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Save Event'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
    title.dispose();
    description.dispose();
  }
}
