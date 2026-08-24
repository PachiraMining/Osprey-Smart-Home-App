import '../entities/discovered_osprey_device.dart';
import '../repositories/pairing_repository.dart';

class ScanForOspreyDevices {
  final PairingRepository repository;
  ScanForOspreyDevices(this.repository);

  Stream<List<DiscoveredOspreyDevice>> call() => repository.scanForDevices();

  Stream<bool> bluetoothOn() => repository.bluetoothOn();

  Stream<bool> scanning() => repository.scanning();

  Future<void> start() => repository.startScan();
  Future<void> stop() => repository.stopScan();
}
