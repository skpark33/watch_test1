import 'package:watch/features/clock/data/datasources/time_data_source.dart';
import 'package:watch/features/clock/domain/repositories/time_repository.dart';

class TimeRepositoryImpl implements TimeRepository {
  final TimeDataSource dataSource;

  TimeRepositoryImpl(this.dataSource);

  @override
  Stream<DateTime> getTimeStream() {
    return dataSource.getTimeStream();
  }
}
