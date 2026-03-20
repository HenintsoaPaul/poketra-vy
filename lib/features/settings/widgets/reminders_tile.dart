import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poketra_vy/core/services/notification_service.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';

class RemindersTile extends ConsumerStatefulWidget {
  const RemindersTile({super.key});

  @override
  ConsumerState<RemindersTile> createState() => RemindersTileState();
}

class RemindersTileState extends ConsumerState<RemindersTile> {
  bool _isReminderActive = true;

  @override
  Widget build(BuildContext context) {
    final hiveService = ref.watch(hiveServiceProvider);
    final notificationTime = hiveService.getNotificationTime();
    final hour = notificationTime['hour']!;
    final minute = notificationTime['minute']!;

    final time = TimeOfDay(hour: hour, minute: minute);
    final formattedTime = DateFormat.jm().format(
      DateTime(2022, 1, 1, hour, minute),
    );

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        'Daily Reminder',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        'Current time: $formattedTime',
        style: const TextStyle(color: Colors.black54),
      ),
      trailing: Switch(
        value: _isReminderActive,
        // activeColor: Theme.of(context).primaryColor,
        // trackColor: Colors.black12,
        onChanged: (val) {
          setState(() {
            _isReminderActive = val;
          });
        },
      ),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: false),
              child: Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).primaryColor,
                    surface: Colors.white,
                  ),
                ),
                child: child!,
              ),
            );
          },
        );

        if (picked != null &&
            (picked.hour != hour || picked.minute != minute)) {
          await hiveService.setNotificationTime(picked.hour, picked.minute);
          await NotificationService().rescheduleDailyNotification(hiveService);

          setState(() {});

          if (mounted) {
            final formattedPicked = picked.format(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reminder rescheduled for $formattedPicked'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          }
        }
      },
    );
  }
}
