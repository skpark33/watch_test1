import 'package:watch/features/clock/domain/repositories/font_repository.dart';

class GetFont {
  final FontRepository repository;

  GetFont(this.repository);

  Future<int> call() {
    return repository.getFontIndex();
  }
}
