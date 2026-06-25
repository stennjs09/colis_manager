/// Colis BLoC events.
import 'package:equatable/equatable.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';

sealed class ColisEvent extends Equatable {
  const ColisEvent();

  @override
  List<Object?> get props => [];
}

class LoadColisEvent extends ColisEvent {
  final String transportModeId;

  const LoadColisEvent({required this.transportModeId});

  @override
  List<Object?> get props => [transportModeId];
}

class AddColisEvent extends ColisEvent {
  final Colis colis;

  const AddColisEvent({required this.colis});

  @override
  List<Object?> get props => [colis];
}

class UpdateColisEvent extends ColisEvent {
  final Colis colis;

  const UpdateColisEvent({required this.colis});

  @override
  List<Object?> get props => [colis];
}

class UpdateColisStatusEvent extends ColisEvent {
  final String id;
  final String status;

  const UpdateColisStatusEvent({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}

class BulkUpdateStatusEvent extends ColisEvent {
  final String status;

  const BulkUpdateStatusEvent({required this.status});

  @override
  List<Object?> get props => [status];
}

class BulkUpdateDateArriveeEvent extends ColisEvent {
  final DateTime? date;

  const BulkUpdateDateArriveeEvent({this.date});

  @override
  List<Object?> get props => [date];
}

class BulkDeleteColisEvent extends ColisEvent {
  final List<String> ids;

  const BulkDeleteColisEvent({required this.ids});

  @override
  List<Object?> get props => [ids];
}

class DeleteColisEvent extends ColisEvent {
  final String id;

  const DeleteColisEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// Selection events
class ToggleSelectionModeEvent extends ColisEvent {}

class ToggleColisSelectionEvent extends ColisEvent {
  final String colisId;

  const ToggleColisSelectionEvent({required this.colisId});

  @override
  List<Object?> get props => [colisId];
}

class SelectAllColisEvent extends ColisEvent {
  final List<String>? targetIds;

  const SelectAllColisEvent({this.targetIds});

  @override
  List<Object?> get props => [targetIds];
}

class ClearSelectionEvent extends ColisEvent {}

// Filter events
class FilterColisEvent extends ColisEvent {
  final String? statusFilter; // null = all, 'non_livre', 'livre'

  const FilterColisEvent({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class SearchColisEvent extends ColisEvent {
  final String query;

  const SearchColisEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class LoadMoreColisEvent extends ColisEvent {}
