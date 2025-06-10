import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:watch/core/di/provider.dart';
import 'package:watch/features/clock/presentation/notifiers/time_notifier.dart';
import 'package:watch/features/clock/presentation/widgets/flip_digit.dart';
import 'package:watch/features/clock/domain/entities/clock_settings.dart';
import 'package:watch/features/settings/presentation/widgets/settings_controls.dart';

class ClockPage extends ConsumerWidget {
  const ClockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTime = ref.watch(timeNotifierProvider);
    final timeStream = ref.read(timeNotifierProvider.notifier).stream;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date and Day display
            asyncTime.when(
              data: (time) => Text(
                DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(time),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              loading: () => const SizedBox(height: 30),
              error: (err, stack) => const Text('Error'),
            ),
            const SizedBox(height: 20),
            // Flip Clock
            asyncTime.when(
              data: (time) => _buildClockDisplay(context, time, timeStream, settings.timeFormat),
              loading: () => _buildClockDisplay(
                  context, DateTime.now(), const Stream.empty(), settings.timeFormat),
              error: (err, stack) => const Text('Error displaying clock'),
            ),
            const SizedBox(height: 40),
            // Settings Controls
            const SettingsControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildClockDisplay(
      BuildContext context, DateTime time, Stream<DateTime> stream, TimeFormat timeFormat) {
    int hour = time.hour;
    String amPm = '';

    if (timeFormat == TimeFormat.h12) {
      amPm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12; // 12 AM and 12 PM
    }

    final minute = time.minute;
    final second = time.second;

    final brightness = Theme.of(context).brightness;
    final textColor = brightness == Brightness.dark ? Colors.white : Colors.black87;

    final textStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        );

    final digitWidth = 100.0;
    final digitHeight = 150.0;
    final digitBackgroundColor = Theme.of(context).colorScheme.surface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (timeFormat == TimeFormat.h12) ...[
          Text(amPm, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(width: 16),
        ],
        // Hour
        FlipDigit(
          initialValue: hour ~/ 10,
          stream: stream.map((t) {
            int h = t.hour;
            if (timeFormat == TimeFormat.h12) {
              h = h % 12;
              if (h == 0) h = 12;
            }
            return h ~/ 10;
          }).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        const SizedBox(width: 8),
        FlipDigit(
          initialValue: hour % 10,
          stream: stream.map((t) {
            int h = t.hour;
            if (timeFormat == TimeFormat.h12) {
              h = h % 12;
              if (h == 0) h = 12;
            }
            return h % 10;
          }).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        _buildSeparator(context),
        // Minute
        FlipDigit(
          initialValue: minute ~/ 10,
          stream: stream.map((t) => t.minute ~/ 10).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        const SizedBox(width: 8),
        FlipDigit(
          initialValue: minute % 10,
          stream: stream.map((t) => t.minute % 10).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        _buildSeparator(context),
        // Second
        FlipDigit(
          initialValue: second ~/ 10,
          stream: stream.map((t) => t.second ~/ 10).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        const SizedBox(width: 8),
        FlipDigit(
          initialValue: second % 10,
          stream: stream.map((t) => t.second % 10).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final separatorColor = brightness == Brightness.dark ? Colors.white54 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        ':',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: separatorColor,
            ),
      ),
    );
  }
}
