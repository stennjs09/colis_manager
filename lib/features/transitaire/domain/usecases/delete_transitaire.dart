/// Use case: Delete a transitaire.
///
/// Cascade deletion of transport modes and colis is handled by SQLite.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transitaire/domain/repositories/transitaire_repository.dart';

class DeleteTransitaire implements UseCase<void, DeleteTransitaireParams> {
  final TransitaireRepository repository;

  DeleteTransitaire(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransitaireParams params) async {
    return await repository.deleteTransitaire(params.id);
  }
}

class DeleteTransitaireParams extends Equatable {
  final String id;

  const DeleteTransitaireParams({required this.id});

  @override
  List<Object?> get props => [id];
}
