import 'package:dartz/dartz.dart';
import 'package:colis_manager/core/error/exceptions.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';
import 'package:colis_manager/features/colis/data/datasources/colis_local_datasource.dart';
import 'package:colis_manager/features/colis/data/models/colis_model.dart';

class ColisRepositoryImpl implements ColisRepository {
  final ColisLocalDatasource localDatasource;

  ColisRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<Colis>>> getColisByTransport(
      String transportModeId) async {
    try {
      final models = await localDatasource.getColisByTransport(transportModeId);
      return Right(models);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Colis>>> getColisByTransportPaginated(
    String transportModeId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final models = await localDatasource.getColisByTransportPaginated(
        transportModeId,
        limit: limit,
        offset: offset,
      );
      return Right(models);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getColisCountByTransport(
      String transportModeId) async {
    try {
      final count =
          await localDatasource.getColisCountByTransport(transportModeId);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addColis(Colis colis) async {
    try {
      final model = ColisModel.fromEntity(colis);
      await localDatasource.addColis(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateColis(Colis colis) async {
    try {
      final model = ColisModel.fromEntity(colis);
      await localDatasource.updateColis(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateColisStatus(
      String id, String status) async {
    try {
      await localDatasource.updateColisStatus(id, status);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> bulkUpdateColisStatus(
      List<String> ids, String status) async {
    try {
      await localDatasource.bulkUpdateColisStatus(ids, status);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> bulkUpdateDateArrivee(
      List<String> ids, DateTime? date) async {
    try {
      await localDatasource.bulkUpdateDateArrivee(ids, date);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteColis(String id) async {
    try {
      await localDatasource.deleteColis(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }
}
