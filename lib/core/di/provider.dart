import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch/features/clock/data/datasources/time_data_source.dart';
import 'package:watch/features/clock/data/repositories/time_repository_impl.dart';
import 'package:watch/features/clock/domain/repositories/time_repository.dart';
import 'package:watch/features/clock/domain/usecases/get_time_stream.dart';
import 'package:watch/features/settings/data/datasources/settings_data_source.dart';
import 'package:watch/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:watch/features/settings/domain/repositories/settings_repository.dart';
import 'package:watch/features/settings/domain/usecases/get_settings.dart';
import 'package:watch/features/settings/domain/usecases/save_settings.dart';
import 'package:watch/features/settings/presentation/notifiers/settings_notifier.dart';
import 'package:watch/features/clock/domain/entities/clock_settings.dart';
import 'package:watch/features/world_clock/data/datasources/world_clock_local_data_source.dart';
import 'package:watch/features/world_clock/data/repositories/world_clock_repository_impl.dart';
import 'package:watch/features/world_clock/domain/repositories/world_clock_repository.dart';
import 'package:watch/features/world_clock/domain/usecases/add_world_city.dart';
import 'package:watch/features/world_clock/domain/usecases/delete_world_city.dart';
import 'package:watch/features/world_clock/domain/usecases/get_world_cities.dart';

// --- Core ---
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// --- Clock Feature ---
// Data Sources
final timeDataSourceProvider = Provider<TimeDataSource>((ref) {
  return TimeDataSourceImpl();
});

// Repositories
final timeRepositoryProvider = Provider<TimeRepository>((ref) {
  final dataSource = ref.watch(timeDataSourceProvider);
  return TimeRepositoryImpl(dataSource);
});

// Use Cases
final getTimeStreamProvider = Provider<GetTimeStream>((ref) {
  final repository = ref.watch(timeRepositoryProvider);
  return GetTimeStream(repository);
});

// --- Presentation ---

// Time Stream Provider for the UI
/*
final timeStreamProvider = StreamProvider<DateTime>((ref) {
  final getTimeStream = ref.watch(getTimeStreamProvider);
  return getTimeStream();
});
*/

// --- Settings Feature ---

// Data Sources
final settingsDataSourceProvider = Provider<SettingsDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData!.value;
  return SettingsDataSourceImpl(sharedPreferences);
});

// Repositories
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
});

// Use Cases
final getSettingsProvider = Provider<GetSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettings(repository);
});

final saveSettingsProvider = Provider<SaveSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SaveSettings(repository);
});

// Notifier Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, ClockSettings>((ref) {
  final getSettings = ref.watch(getSettingsProvider);
  final saveSettings = ref.watch(saveSettingsProvider);
  return SettingsNotifier(getSettings, saveSettings);
});

// --- World Clock Feature ---

// Data Sources
final worldClockLocalDataSourceProvider = Provider<WorldClockLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData!.value;
  return WorldClockLocalDataSourceImpl(sharedPreferences);
});

// Repositories
final worldClockRepositoryProvider = Provider<WorldClockRepository>((ref) {
  final dataSource = ref.watch(worldClockLocalDataSourceProvider);
  return WorldClockRepositoryImpl(dataSource);
});

// Use Cases
final getWorldCitiesProvider = Provider<GetWorldCities>((ref) {
  final repository = ref.watch(worldClockRepositoryProvider);
  return GetWorldCities(repository);
});

final addWorldCityProvider = Provider<AddWorldCity>((ref) {
  final repository = ref.watch(worldClockRepositoryProvider);
  return AddWorldCity(repository);
});

final deleteWorldCityProvider = Provider<DeleteWorldCity>((ref) {
  final repository = ref.watch(worldClockRepositoryProvider);
  return DeleteWorldCity(repository);
});

// --- Presentation Layer Providers ---
enum ClockView { main, world }

final clockViewProvider = StateProvider<ClockView>((ref) => ClockView.main);
