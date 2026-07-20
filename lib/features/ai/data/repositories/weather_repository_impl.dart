import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/weather_recommendation.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';
import '../weather_location_store.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remote;
  final WeatherLocationStore _locationStore;

  WeatherRepositoryImpl(this._remote, this._locationStore);

  @override
  Future<Either<Failure, WeatherRecommendation>> currentRecommendation() async {
    try {
      final double latitude;
      final double longitude;

      // A manually switched location wins over GPS (and needs no permission).
      final manual = await _locationStore.get();
      if (manual != null) {
        latitude = manual.latitude;
        longitude = manual.longitude;
      } else {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          final requested = await Geolocator.requestPermission();
          if (requested == LocationPermission.denied ||
              requested == LocationPermission.deniedForever) {
            return const Left(
              ServerFailure('LOC_DENIED',
                  message: 'Location permission denied'),
            );
          }
        }
        final position = await Geolocator.getCurrentPosition();
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final snapshot = await _remote.fetchCurrent(
        latitude: latitude,
        longitude: longitude,
      );
      // Best-effort air quality for the home weather card (null on failure).
      final pm25 = await _remote.fetchPm25(
        latitude: latitude,
        longitude: longitude,
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
