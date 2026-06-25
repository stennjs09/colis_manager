/// Repository implementation for Transitaire.
///
/// Converts between domain entities and data models,
/// handles exceptions from the datasource and returns Either types.
import 'package:dartz/dartz.dart';
import 'package:colis_manager/core/error/exceptions.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';
import 'package:colis_manager/features/transitaire/domain/repositories/transitaire_repository.dart';
import 'package:colis_manager/features/transitaire/data/datasources/transitaire_local_datasource.dart';
import 'package:colis_manager/features/transitaire/data/models/transitaire_model.dart';

class TransitaireRepositoryImpl implements TransitaireRepository {
  final TransitaireLocalDatasource localDatasource;

  TransitaireRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<Transitaire>>> getAllTransitaires() async {
    try {
      final models = await localDatasource.getAllTransitaires();
      return Right(models);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Transitaire>> getTransitaireById(String id) async {
    try {
      final model = await localDatasource.getTransitaireById(id);
      return Right(model);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addTransitaire(Transitaire transitaire) async {
    try {
      final model = TransitaireModel.fromEntity(transitaire);
      await localDatasource.addTransitaire(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransitaire(Transitaire transitaire) async {
    try {
      final model = TransitaireModel.fromEntity(transitaire);
      await localDatasource.updateTransitaire(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransitaire(String id) async {
    try {
      await localDatasource.deleteTransitaire(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }
}
