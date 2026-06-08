import 'package:equatable/equatable.dart';

import '../../domain/entities/discovered_osprey_device.dart';

abstract class OspreyScanState extends Equatable {
  const OspreyScanState();

  @override
  List<Object?> get props => [];
}

class OspreyScanInitial extends OspreyScanState {}

/// Đang load catalog + khởi động scan.
class OspreyScanStarting extends OspreyScanState {}

/// Đang scan — [devices] cập nhật liên tục.
class OspreyScanning extends OspreyScanState {
  final List<DiscoveredOspreyDevice> devices;
  const OspreyScanning(this.devices);

  @override
  List<Object?> get props => [devices];
}

/// Scan đã dừng (timeout hoặc user dừng), giữ kết quả cuối.
class OspreyScanStopped extends OspreyScanState {
  final List<DiscoveredOspreyDevice> devices;
  const OspreyScanStopped(this.devices);

  @override
  List<Object?> get props => [devices];
}

class OspreyScanError extends OspreyScanState {
  final String message;
  const OspreyScanError(this.message);

  @override
  List<Object?> get props => [message];
}
