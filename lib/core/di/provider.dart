import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch/features/clock/data/datasources/time_data_source.dart';
import 'package:watch/features/clock/data/repositories/time_repository_impl.dart';
import 'package:watch/features/clock/domain/repositories/time_repository.dart';
import 'package:watch/features/clock/domain/usecases/get_time_stream.dart';

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
final timeStreamProvider = StreamProvider<DateTime>((ref) {
  final getTimeStream = ref.watch(getTimeStreamProvider);
  return getTimeStream();
});
