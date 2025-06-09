import 'package:watch/features/clock/domain/entities/clock_settings.dart';
import 'package:watch/features/settings/domain/repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository repository;

  GetSettings(this.repository);

  Future<ClockSettings> call() {
    return repository.getSettings();
  }
}
