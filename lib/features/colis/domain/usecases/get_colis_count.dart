import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';

class GetColisCount implements UseCase<int, GetColisCountParams> {
  final ColisRepository repository;

  GetColisCount(this.repository);

  @override
  Future<Either<Failure, int>> call(GetColisCountParams params) async {
    return await repository.getColisCountByTransport(params.transportModeId);
  }
}

class GetColisCountParams extends Equatable {
  final String transportModeId;

  const GetColisCountParams({required this.transportModeId});

  @override
  List<Object?> get props => [transportModeId];
}
