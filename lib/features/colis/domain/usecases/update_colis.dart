import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';

class UpdateColis implements UseCase<void, UpdateColisParams> {
  final ColisRepository repository;

  UpdateColis(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateColisParams params) async {
    final colis = params.colis;
    if (colis.trackingNumber.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Le numéro de tracking est requis'),
      );
    }
    if (colis.poids < 0) {
      return const Left(
        ValidationFailure(message: 'Le poids ne peut pas être négatif'),
      );
    }
    if (colis.prixFret < 0) {
      return const Left(
        ValidationFailure(message: 'Le prix du fret ne peut pas être négatif'),
      );
    }
    return await repository.updateColis(colis);
  }
}

class UpdateColisParams extends Equatable {
  final Colis colis;

  const UpdateColisParams({required this.colis});

  @override
  List<Object?> get props => [colis];
}
