import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/weather_recommendation.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remote;

  WeatherRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, WeatherRecommendation>> currentRecommendation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return const Left(
            ServerFailure('LOC_DENIED', message: 'Location permission denied'),
          );
        }
      }
      final position = await Geolocator.getCurrentPosition();
      final snapshot = await _remote.fetchCurrent(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      // Best-effort air quality for the home weather card (null on failure).
      final pm25 = await _remote.fetchPm25(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final recommendation = _recommendFromSnapshot(snapshot, pm25);
      return Right(recommendation);
    } on ServerException catch (e) {
      return Left(ServerFailure('WEATHER_FAILED', message: e.message));
    } catch (e) {
      return Left(ServerFailure('WEATHER_FAILED', message: e.toString()));
    }
  }

  WeatherRecommendation _recommendFromSnapshot(WeatherSnapshot s, double? pm25) {
    int position;
    String reason;
    if (!s.isDay) {
      position = 0;
      reason = 'Night-time — close curtains for privacy and warmth.';
    } else if (s.temperatureCelsius > 30 && s.cloudCoverPercent < 30) {
      position = 30;
      reason =
          'Sunny ${s.temperatureCelsius.toStringAsFixed(0)}°C — lower curtains to reduce heat.';
    } else if (s.cloudCoverPercent > 80) {
      position = 100;
      reason = 'Overcast — open curtains wide for natural light.';
    } else {
      position = 70;
      reason =
          '${s.temperatureCelsius.toStringAsFixed(0)}°C, ${s.cloudCoverPercent}% cloud — comfortable filtered light.';
    }
    return WeatherRecommendation(
      position: position,
      reason: reason,
      temperatureCelsius: s.temperatureCelsius,
      cloudCoverPercent: s.cloudCoverPercent,
      isDay: s.isDay,
      humidityPercent: s.humidityPercent,
      pressureHpa: s.pressureHpa,
      windSpeedMs: s.windSpeedMs,
      pm25: pm25,
    );
  }
}
