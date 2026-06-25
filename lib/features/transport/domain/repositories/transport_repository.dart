/// Abstract repository interface for Transport modes.
import 'package:dartz/dartz.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';

abstract class TransportRepository {
  Future<Either<Failure, List<TransportMode>>> getTransportModesByTransitaire(String transitaireId);
  Future<Either<Failure, TransportMode>> getTransportModeById(String id);
  Future<Either<Failure, void>> addTransportMode(TransportMode mode);
  Future<Either<Failure, void>> updateTransportMode(TransportMode mode);
  Future<Either<Failure, void>> deleteTransportMode(String id);
}
