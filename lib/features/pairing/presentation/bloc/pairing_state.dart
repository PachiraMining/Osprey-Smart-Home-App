import 'package:equatable/equatable.dart';

import '../../domain/entities/pairing_progress.dart';

abstract class PairingState extends Equatable {
  const PairingState();

  @override
  List<Object?> get props => [];
}

class PairingInitial extends PairingState {}

class PairingInProgress extends PairingState {
  final PairingStep step;
  const PairingInProgress(this.step);

  @override
  List<Object?> get props => [step];
}

class PairingSuccess extends PairingState {
  /// TB device id của thiết bị vừa pair.
  final String deviceId;
  const PairingSuccess(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class PairingFailure extends PairingState {
  final String message;

  /// Bước đang chạy khi lỗi xảy ra (hiển thị lại stepper).
  final PairingStep? failedAtStep;

  const PairingFailure(this.message, {this.failedAtStep});

  @override
  List<Object?> get props => [message, failedAtStep];
}
