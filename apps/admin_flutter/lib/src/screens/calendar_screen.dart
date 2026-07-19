import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../api_client.dart';

final interviewsProvider = FutureProvider.autoDispose((ref) async {
  final res = await ref.read(dioProvider).get('/interviews');
  return res.data['data'] as List;
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(interviewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Interview Calendar')),
      body: asyncData.when(
        data: (interviews) {
          List<dynamic> _getEventsForDay(DateTime day) {
            final dayStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
            return interviews.where((i) => i['date'] == dayStr).toList();
          }

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                calendarStyle: const CalendarStyle(
                  markersMaxCount: 3,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _selectedDay == null 
                  ? const Center(child: Text('Select a day to view interviews'))
                  : ListView(
                      children: _getEventsForDay(_selectedDay!).map((evt) {
                        final c = evt['candidate'];
                        return ListTile(
                          leading: const Icon(Icons.videocam),
                          title: Text('${evt['time']} - ${c['firstName']} ${c['lastName']}'),
                          subtitle: Text('Interviewer: ${evt['interviewer']} | Location: ${evt['location'] ?? 'N/A'}'),
                          onTap: () => context.go('/candidates/${evt['applicationId']}'),
                        );
                      }).toList(),
                  ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
