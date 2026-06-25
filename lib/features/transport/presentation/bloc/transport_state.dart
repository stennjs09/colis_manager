/// Transport BLoC states.
import 'package:equatable/equatable.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';

sealed class TransportState extends Equatable {
  const TransportState();

  @override
  List<Object?> get props => [];
}

class TransportInitial extends TransportState {}

class TransportLoading extends TransportState {}

class TransportLoaded extends TransportState {
  final List<TransportMode> transportModes;

  const TransportLoaded({required this.transportModes});

  @override
  List<Object?> get props => [transportModes];
}

class TransportEmpty extends TransportState {}

class TransportError extends TransportState {
  final String message;

  const TransportError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransportActionSuccess extends TransportState {
  final String message;

  const TransportActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
