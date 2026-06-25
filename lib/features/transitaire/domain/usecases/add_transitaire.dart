/// Use case: Add a new transitaire.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';
import 'package:colis_manager/features/transitaire/domain/repositories/transitaire_repository.dart';

class AddTransitaire implements UseCase<void, AddTransitaireParams> {
  final TransitaireRepository repository;

  AddTransitaire(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransitaireParams params) async {
    if (params.transitaire.nom.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Le nom du transitaire ne peut pas être vide'),
      );
    }
    return await repository.addTransitaire(params.transitaire);
  }
}

class AddTransitaireParams extends Equatable {
  final Transitaire transitaire;

  const AddTransitaireParams({required this.transitaire});

  @override
  List<Object?> get props => [transitaire];
}
