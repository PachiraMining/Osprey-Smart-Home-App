import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/automation_suggestion.dart';
import '../../domain/usecases/analyze_usage_patterns.dart';

abstract class AiSuggestionEvent extends Equatable {
  const AiSuggestionEvent();
  @override
  List<Object?> get props => [];
}

class LoadSuggestions extends AiSuggestionEvent {
  const LoadSuggestions();
}

abstract class AiSuggestionState extends Equatable {
  const AiSuggestionState();
  @override
  List<Object?> get props => [];
}

class AiSuggestionInitial extends AiSuggestionState {
  const AiSuggestionInitial();
}

class AiSuggestionsLoading extends AiSuggestionState {
  const AiSuggestionsLoading();
}

class AiSuggestionsLoaded extends AiSuggestionState {
  final List<AutomationSuggestion> suggestions;
  const AiSuggestionsLoaded(this.suggestions);
  @override
  List<Object?> get props => [suggestions];
}

class AiSuggestionsEmpty extends AiSuggestionState {
  const AiSuggestionsEmpty();
}

class AiSuggestionsError extends AiSuggestionState {
  final String message;
  const AiSuggestionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class AiSuggestionBloc extends Bloc<AiSuggestionEvent, AiSuggestionState> {
  final AnalyzeUsagePatterns _analyze;

  AiSuggestionBloc(this._analyze) : super(const AiSuggestionInitial()) {
    on<LoadSuggestions>((event, emit) async {
      emit(const AiSuggestionsLoading());
      final result = await _analyze();
      result.fold(
        (f) => emit(AiSuggestionsError(f.message)),
        (list) => emit(
          list.isEmpty ? const AiSuggestionsEmpty() : AiSuggestionsLoaded(list),
        ),
      );
    });
  }
}
