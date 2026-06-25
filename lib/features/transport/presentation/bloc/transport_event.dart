/// Transport BLoC events.
import 'package:equatable/equatable.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';

sealed class TransportEvent extends Equatable {
  const TransportEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransportModesEvent extends TransportEvent {
  final String transitaireId;

  const LoadTransportModesEvent({required this.transitaireId});

  @override
  List<Object?> get props => [transitaireId];
}

class AddTransportModeEvent extends TransportEvent {
  final TransportMode transportMode;

  const AddTransportModeEvent({required this.transportMode});

  @override
  List<Object?> get props => [transportMode];
}

class UpdateTransportModeEvent extends TransportEvent {
  final TransportMode transportMode;

  const UpdateTransportModeEvent({required this.transportMode});

  @override
  List<Object?> get props => [transportMode];
}

class DeleteTransportModeEvent extends TransportEvent {
  final String id;

  const DeleteTransportModeEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

