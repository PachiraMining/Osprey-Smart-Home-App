import 'package:equatable/equatable.dart';

class SmartHomeEntity extends Equatable {
  final String id;
  final String name;

  const SmartHomeEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
