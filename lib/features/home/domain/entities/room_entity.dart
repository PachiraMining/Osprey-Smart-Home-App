import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final int sortOrder;

  const RoomEntity({
    required this.id,
    required this.name,
    this.icon,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, name, icon, sortOrder];
}
