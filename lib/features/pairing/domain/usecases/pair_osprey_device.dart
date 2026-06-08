import '../entities/discovered_osprey_device.dart';
import '../entities/pairing_progress.dart';
import '../repositories/pairing_repository.dart';

class PairOspreyDevice {
  final PairingRepository repository;
  PairOspreyDevice(this.repository);

  Stream<PairingProgress> call({
    required DiscoveredOspreyDevice device,
    required String ssid,
    required String wifiPassword,
    String? roomId,
  }) =>
      repository.pairDevice(
        device: device,
        ssid: ssid,
        wifiPassword: wifiPassword,
        roomId: roomId,
      );
}
