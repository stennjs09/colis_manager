/// Use case: Add a colis.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';

class AddColis implements UseCase<void, AddColisParams> {
  final ColisRepository repository;

  AddColis(this.repository);

  @override
  Future<Either<Failure, void>> call(AddColisParams params) async {
    final colis = params.colis;
    if (colis.trackingNumber.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Le numéro de tracking est requis'),
      );
    }
    if (colis.poids <= 0) {
      return const Left(
        ValidationFailure(message: 'Le poids doit être supérieur à 0'),
      );
    }
    if (colis.prixFret < 0) {
      return const Left(
        ValidationFailure(message: 'Le prix du fret ne peut pas être négatif'),
      );
    }
    return await repository.addColis(colis);
  }
}

class AddColisParams extends Equatable {
  final Colis colis;

  const AddColisParams({required this.colis});

  @override
  List<Object?> get props => [colis];
}
