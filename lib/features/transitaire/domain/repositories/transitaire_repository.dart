/// Abstract repository interface for the Transitaire domain.
///
/// Defines the contract that the data layer must implement.
import 'package:dartz/dartz.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';

abstract class TransitaireRepository {
  Future<Either<Failure, List<Transitaire>>> getAllTransitaires();
  Future<Either<Failure, Transitaire>> getTransitaireById(String id);
  Future<Either<Failure, void>> addTransitaire(Transitaire transitaire);
  Future<Either<Failure, void>> updateTransitaire(Transitaire transitaire);
  Future<Either<Failure, void>> deleteTransitaire(String id);
}
