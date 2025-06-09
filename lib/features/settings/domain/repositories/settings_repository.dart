import 'package:watch/features/clock/domain/entities/clock_settings.dart';

abstract class SettingsRepository {
  Future<ClockSettings> getSettings();
  Future<void> saveSettings(ClockSettings settings);
}
