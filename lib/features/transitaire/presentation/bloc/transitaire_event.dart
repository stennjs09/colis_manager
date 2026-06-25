/// Transitaire BLoC events.
import 'package:equatable/equatable.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';

sealed class TransitaireEvent extends Equatable {
  const TransitaireEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransitairesEvent extends TransitaireEvent {}

class AddTransitaireEvent extends TransitaireEvent {
  final Transitaire transitaire;

  const AddTransitaireEvent({required this.transitaire});

  @override
  List<Object?> get props => [transitaire];
}

class UpdateTransitaireEvent extends TransitaireEvent {
  final Transitaire transitaire;

  const UpdateTransitaireEvent({required this.transitaire});

  @override
  List<Object?> get props => [transitaire];
}

class DeleteTransitaireEvent extends TransitaireEvent {
  final String id;

  const DeleteTransitaireEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
