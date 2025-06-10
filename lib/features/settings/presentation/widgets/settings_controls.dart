import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch/core/di/provider.dart';
import 'package:watch/features/clock/domain/entities/clock_settings.dart';
import 'package:watch/features/settings/presentation/widgets/alarm_settings_dialog.dart';

class SettingsControls extends ConsumerWidget {
  final bool isAlarmRinging;
  final VoidCallback onDismissAlarm;
  final List<String>? alarmTimes;
  final Function(DateTime) onAddAlarm;
  final Function(int) onDeleteAlarm;

  const SettingsControls({
    super.key,
    this.isAlarmRinging = false,
    required this.onDismissAlarm,
    this.alarmTimes,
    required this.onAddAlarm,
    required this.onDeleteAlarm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isAlarmRinging)
            IconButton(
              icon: const Icon(Icons.alarm_off),
              onPressed: onDismissAlarm,
              tooltip: 'Dismiss Alarm',
              color: Theme.of(context).colorScheme.error,
              iconSize: 45, // 50% larger than the previous 30
            )
          else ...[
            // Theme Toggle
            IconButton(
              icon: Icon(
                settings.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                final newMode =
                    settings.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                settingsNotifier.updateThemeMode(newMode);
              },
              tooltip: 'Toggle Theme',
            ),
            const SizedBox(width: 20),

            // Font Toggle
            IconButton(
              icon: const Icon(Icons.font_download),
              onPressed: () {
                ref.read(fontProvider.notifier).toggleFont();
              },
              tooltip: 'Toggle Font',
            ),
            const SizedBox(width: 20),

            // Time Format Toggle
            InkWell(
              onTap: () {
                final newFormat =
                    settings.timeFormat == TimeFormat.h24 ? TimeFormat.h12 : TimeFormat.h24;
                settingsNotifier.updateTimeFormat(newFormat);
              },
              child: Text(
                settings.timeFormat == TimeFormat.h24 ? '24 H' : '12 H',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(
                  alarmTimes != null && alarmTimes!.isNotEmpty ? Icons.alarm : Icons.alarm_add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlarmSettingsDialog(
                      alarmTimes: alarmTimes ?? [],
                      onAddAlarm: onAddAlarm,
                      onDeleteAlarm: onDeleteAlarm,
                    );
                  },
                );
              },
              tooltip: alarmTimes != null && alarmTimes!.isNotEmpty ? '알람이 설정되었습니다.' : '설정된 알람 없음',
            ),
          ]
        ],
      ),
    );
  }
}
