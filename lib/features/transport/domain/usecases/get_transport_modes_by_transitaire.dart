/// Use case: Get transport modes for a transitaire.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';
import 'package:colis_manager/features/transport/domain/repositories/transport_repository.dart';

class GetTransportModesByTransitaire
    implements UseCase<List<TransportMode>, GetTransportModesParams> {
  final TransportRepository repository;

  GetTransportModesByTransitaire(this.repository);

  @override
  Future<Either<Failure, List<TransportMode>>> call(
      GetTransportModesParams params) async {
    return await repository.getTransportModesByTransitaire(params.transitaireId);
  }
}

class GetTransportModesParams extends Equatable {
  final String transitaireId;

  const GetTransportModesParams({required this.transitaireId});

  @override
  List<Object?> get props => [transitaireId];
}
