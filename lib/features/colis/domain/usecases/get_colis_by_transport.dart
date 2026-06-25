/// Use case: Get colis by transport mode.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';

class GetColisByTransport implements UseCase<List<Colis>, GetColisParams> {
  final ColisRepository repository;

  GetColisByTransport(this.repository);

  @override
  Future<Either<Failure, List<Colis>>> call(GetColisParams params) async {
    return await repository.getColisByTransport(params.transportModeId);
  }
}

class GetColisParams extends Equatable {
  final String transportModeId;

  const GetColisParams({required this.transportModeId});

  @override
  List<Object?> get props => [transportModeId];
}
