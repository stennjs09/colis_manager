/// Repository implementation for Transport modes.
import 'package:dartz/dartz.dart';
import 'package:colis_manager/core/error/exceptions.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';
import 'package:colis_manager/features/transport/domain/repositories/transport_repository.dart';
import 'package:colis_manager/features/transport/data/datasources/transport_local_datasource.dart';
import 'package:colis_manager/features/transport/data/models/transport_mode_model.dart';

class TransportRepositoryImpl implements TransportRepository {
  final TransportLocalDatasource localDatasource;

  TransportRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<TransportMode>>> getTransportModesByTransitaire(
      String transitaireId) async {
    try {
      final models =
          await localDatasource.getTransportModesByTransitaire(transitaireId);
      return Right(models);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TransportMode>> getTransportModeById(String id) async {
    try {
      final model = await localDatasource.getTransportModeById(id);
      return Right(model);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addTransportMode(TransportMode mode) async {
    try {
      final model = TransportModeModel.fromEntity(mode);
      await localDatasource.addTransportMode(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransportMode(TransportMode mode) async {
    try {
      final model = TransportModeModel.fromEntity(mode);
      await localDatasource.updateTransportMode(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransportMode(String id) async {
    try {
      await localDatasource.deleteTransportMode(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }
}
