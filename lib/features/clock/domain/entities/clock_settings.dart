import 'package:flutter/foundation.dart';

enum TimeFormat { h12, h24 }

@immutable
class ClockSettings {
  const ClockSettings({
    this.timeFormat = TimeFormat.h24,
  });

  final TimeFormat timeFormat;

  ClockSettings copyWith({
    TimeFormat? timeFormat,
  }) {
    return ClockSettings(
      timeFormat: timeFormat ?? this.timeFormat,
    );
  }
}
