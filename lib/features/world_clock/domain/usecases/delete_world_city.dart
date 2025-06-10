import 'package:watch/features/world_clock/domain/repositories/world_clock_repository.dart';

class DeleteWorldCity {
  final WorldClockRepository repository;

  DeleteWorldCity(this.repository);

  Future<void> call(String cityId) {
    return repository.deleteWorldCity(cityId);
  }
}
