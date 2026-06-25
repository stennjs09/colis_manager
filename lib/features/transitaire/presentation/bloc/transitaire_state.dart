/// Transitaire BLoC states.
import 'package:equatable/equatable.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';

sealed class TransitaireState extends Equatable {
  const TransitaireState();

  @override
  List<Object?> get props => [];
}

class TransitaireInitial extends TransitaireState {}

class TransitaireLoading extends TransitaireState {}

class TransitaireLoaded extends TransitaireState {
  final List<Transitaire> transitaires;

  const TransitaireLoaded({required this.transitaires});

  @override
  List<Object?> get props => [transitaires];
}

class TransitaireEmpty extends TransitaireState {}

class TransitaireError extends TransitaireState {
  final String message;

  const TransitaireError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransitaireActionSuccess extends TransitaireState {
  final String message;

  const TransitaireActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
