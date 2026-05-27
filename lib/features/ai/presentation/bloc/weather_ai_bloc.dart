import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/weather_recommendation.dart';
import '../../domain/usecases/get_weather_recommendation.dart';

abstract class WeatherAiEvent extends Equatable {
  const WeatherAiEvent();
  @override
  List<Object?> get props => [];
}

class RefreshWeather extends WeatherAiEvent {
  const RefreshWeather();
}

abstract class WeatherAiState extends Equatable {
  const WeatherAiState();
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherAiState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherAiState {
  const WeatherLoading();
}

class WeatherLoaded extends WeatherAiState {
  final WeatherRecommendation recommendation;
  const WeatherLoaded(this.recommendation);
  @override
  List<Object?> get props => [recommendation];
}

class WeatherUnavailable extends WeatherAiState {
  final String message;
  const WeatherUnavailable(this.message);
  @override
  List<Object?> get props => [message];
}

class WeatherAiBloc extends Bloc<WeatherAiEvent, WeatherAiState> {
  final GetWeatherRecommendation _get;

  WeatherAiBloc(this._get) : super(const WeatherInitial()) {
    on<RefreshWeather>((event, emit) async {
      emit(const WeatherLoading());
      final result = await _get();
      result.fold(
        (f) => emit(WeatherUnavailable(f.message)),
        (r) => emit(WeatherLoaded(r)),
      );
    });
  }
}
