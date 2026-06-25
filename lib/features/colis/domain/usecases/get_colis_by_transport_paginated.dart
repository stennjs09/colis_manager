import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';

class GetColisByTransportPaginated
    implements UseCase<List<Colis>, GetColisPaginatedParams> {
  final ColisRepository repository;

  GetColisByTransportPaginated(this.repository);

  @override
  Future<Either<Failure, List<Colis>>> call(
      GetColisPaginatedParams params) async {
    return await repository.getColisByTransportPaginated(
      params.transportModeId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetColisPaginatedParams extends Equatable {
  final String transportModeId;
  final int limit;
  final int offset;

  const GetColisPaginatedParams({
    required this.transportModeId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [transportModeId, limit, offset];
}
