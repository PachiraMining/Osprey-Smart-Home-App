import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/features/ai/domain/entities/weather_recommendation.dart';
import 'package:smart_curtain_app/features/ai/domain/repositories/weather_repository.dart';
import 'package:smart_curtain_app/features/ai/domain/usecases/get_weather_recommendation.dart';

class _MockRepo extends Mock implements WeatherRepository {}

void main() {
  test('returns recommendation from repository', () async {
    final repo = _MockRepo();
    when(() => repo.currentRecommendation()).thenAnswer(
      (_) async => const Right(
        WeatherRecommendation(
          position: 30,
          reason: 'Sunny — reduce heat',
          temperatureCelsius: 32,
          cloudCoverPercent: 10,
          isDay: true,
        ),
      ),
    );

    final usecase = GetWeatherRecommendation(repo);
    final result = await usecase();

    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse(() => throw StateError('no rec')).position,
      30,
    );
  });
}
