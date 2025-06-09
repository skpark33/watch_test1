import 'package:watch/features/clock/domain/entities/clock_settings.dart';
import 'package:watch/features/settings/domain/repositories/settings_repository.dart';

class SaveSettings {
  final SettingsRepository repository;

  SaveSettings(this.repository);

  Future<void> call(ClockSettings settings) {
    return repository.saveSettings(settings);
  }
}
