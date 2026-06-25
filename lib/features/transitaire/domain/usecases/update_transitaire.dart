/// Use case: Update an existing transitaire.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';
import 'package:colis_manager/features/transitaire/domain/repositories/transitaire_repository.dart';

class UpdateTransitaire implements UseCase<void, UpdateTransitaireParams> {
  final TransitaireRepository repository;

  UpdateTransitaire(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTransitaireParams params) async {
    if (params.transitaire.nom.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Le nom du transitaire ne peut pas être vide'),
      );
    }
    return await repository.updateTransitaire(params.transitaire);
  }
}

class UpdateTransitaireParams extends Equatable {
  final Transitaire transitaire;

  const UpdateTransitaireParams({required this.transitaire});

  @override
  List<Object?> get props => [transitaire];
}
