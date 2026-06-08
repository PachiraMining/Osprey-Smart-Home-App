import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/pairing_progress.dart';
import '../../domain/usecases/pair_osprey_device.dart';
import 'pairing_event.dart';
import 'pairing_state.dart';

/// Chạy pairing flow và map từng [PairingProgress] thành state cho UI.
class PairingBloc extends Bloc<PairingEvent, PairingState> {
  final PairOspreyDevice pairDevice;

  PairingBloc({required this.pairDevice}) : super(PairingInitial()) {
    on<StartPairingEvent>(_onStartPairing);
    on<ResetPairingEvent>((event, emit) => emit(PairingInitial()));
  }

  Future<void> _onStartPairing(
    StartPairingEvent event,
    Emitter<PairingState> emit,
  ) async {
    if (state is PairingInProgress) return; // đang chạy — bỏ qua double tap

    var lastStep = PairingStep.connecting;
    await emit.onEach<PairingProgress>(
      pairDevice(
        device: event.device,
        ssid: event.ssid,
        wifiPassword: event.wifiPassword,
        roomId: event.roomId,
      ),
      onData: (progress) {
        lastStep = progress.step;
        if (progress.step == PairingStep.done) {
          emit(PairingSuccess(progress.deviceId ?? ''));
        } else {
          emit(PairingInProgress(progress.step));
        }
      },
      onError: (error, stackTrace) {
        final message =
            error is Failure ? error.message : error.toString();
        emit(PairingFailure(message, failedAtStep: lastStep));
      },
    );
  }
}
