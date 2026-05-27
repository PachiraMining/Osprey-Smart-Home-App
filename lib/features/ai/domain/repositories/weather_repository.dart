import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/weather_recommendation.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherRecommendation>> currentRecommendation();
}
