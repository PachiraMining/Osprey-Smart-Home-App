import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/speech_to_text_datasource.dart';
import '../../domain/entities/voice_intent.dart';
import '../../domain/usecases/parse_voice_intent.dart';

// ─── Events ─────────────────────────────────────────────────────
abstract class VoiceCommandEvent extends Equatable {
  const VoiceCommandEvent();
  @override
  List<Object?> get props => [];
}

class StartListening extends VoiceCommandEvent {
  const StartListening();
}

class StopListening extends VoiceCommandEvent {
  const StopListening();
}

class _TranscriptReceived extends VoiceCommandEvent {
  final String transcript;
  final bool isFinal;
  const _TranscriptReceived(this.transcript, this.isFinal);
  @override
  List<Object?> get props => [transcript, isFinal];
}

// ─── States ─────────────────────────────────────────────────────
abstract class VoiceCommandState extends Equatable {
  const VoiceCommandState();
  @override
  List<Object?> get props => [];
}

class VoiceIdle extends VoiceCommandState {
  const VoiceIdle();
}

class VoiceListening extends VoiceCommandState {
  final String partial;
  const VoiceListening({this.partial = ''});
  @override
  List<Object?> get props => [partial];
}

class VoiceParsing extends VoiceCommandState {
  final String transcript;
  const VoiceParsing(this.transcript);
  @override
  List<Object?> get props => [transcript];
}

class VoiceCommandReady extends VoiceCommandState {
  final VoiceIntent intent;
  const VoiceCommandReady(this.intent);
  @override
  List<Object?> get props => [intent];
}

class VoiceError extends VoiceCommandState {
  final String message;
  const VoiceError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ───────────────────────────────────────────────────────
class VoiceCommandBloc extends Bloc<VoiceCommandEvent, VoiceCommandState> {
  final SpeechToTextDataSource _stt;
  final ParseVoiceIntent _parse;

  VoiceCommandBloc({
    required SpeechToTextDataSource stt,
    required ParseVoiceIntent parse,
  })  : _stt = stt,
        _parse = parse,
        super(const VoiceIdle()) {
    on<StartListening>(_onStart);
    on<StopListening>(_onStop);
    on<_TranscriptReceived>(_onTranscript);
  }

  Future<void> _onStart(StartListening _, Emitter<VoiceCommandState> emit) async {
    emit(const VoiceListening());
    await _stt.startListening(
      onResult: (transcript, isFinal) =>
          add(_TranscriptReceived(transcript, isFinal)),
    );
  }

  Future<void> _onStop(StopListening _, Emitter<VoiceCommandState> emit) async {
    await _stt.stopListening();
    if (state is VoiceListening) emit(const VoiceIdle());
  }

  Future<void> _onTranscript(
      _TranscriptReceived e, Emitter<VoiceCommandState> emit) async {
    if (!e.isFinal) {
      emit(VoiceListening(partial: e.transcript));
      return;
    }
    emit(VoiceParsing(e.transcript));
    final result = await _parse(e.transcript);
    result.fold(
      (f) => emit(VoiceError(f.message)),
      (intent) => emit(VoiceCommandReady(intent)),
    );
  }
}
