import 'package:equatable/equatable.dart';

import '../../domain/entities/discovered_osprey_device.dart';

abstract class PairingEvent extends Equatable {
  const PairingEvent();

  @override
  List<Object?> get props => [];
}

class StartPairingEvent extends PairingEvent {
  final DiscoveredOspreyDevice device;
  final String ssid;
  final String wifiPassword;
  final String? roomId;

  const StartPairingEvent({
    required this.device,
    required this.ssid,
    required this.wifiPassword,
    this.roomId,
  });

  @override
  List<Object?> get props => [device, ssid, wifiPassword, roomId];
}

class ResetPairingEvent extends PairingEvent {
  const ResetPairingEvent();
}
