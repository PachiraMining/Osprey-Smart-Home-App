import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/weather_recommendation.dart';
import '../repositories/weather_repository.dart';

class GetWeatherRecommendation {
  final WeatherRepository _repo;

  GetWeatherRecommendation(this._repo);

  Future<Either<Failure, WeatherRecommendation>> call() {
    return _repo.currentRecommendation();
  }
}
