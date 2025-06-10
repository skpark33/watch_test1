import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch/core/di/provider.dart';
import 'package:watch/features/clock/domain/entities/clock_settings.dart';

class SettingsControls extends ConsumerWidget {
  const SettingsControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
        ],
      ),
    );
  }
}
