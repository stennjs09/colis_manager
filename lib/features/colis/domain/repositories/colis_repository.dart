import 'package:dartz/dartz.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';

abstract class ColisRepository {
  Future<Either<Failure, List<Colis>>> getColisByTransport(String transportModeId);
  Future<Either<Failure, List<Colis>>> getColisByTransportPaginated(
    String transportModeId, {
    int limit = 20,
    int offset = 0,
  });
  Future<Either<Failure, int>> getColisCountByTransport(String transportModeId);
  Future<Either<Failure, void>> addColis(Colis colis);
  Future<Either<Failure, void>> updateColis(Colis colis);
  Future<Either<Failure, void>> updateColisStatus(String id, String status);
  Future<Either<Failure, void>> bulkUpdateColisStatus(List<String> ids, String status);
  Future<Either<Failure, void>> bulkUpdateDateArrivee(List<String> ids, DateTime? date);
  Future<Either<Failure, void>> deleteColis(String id);
}
