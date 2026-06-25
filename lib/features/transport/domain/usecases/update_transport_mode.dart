/// Use case: Update an existing transport mode.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';
import 'package:colis_manager/features/transport/domain/repositories/transport_repository.dart';

class UpdateTransportMode implements UseCase<void, UpdateTransportModeParams> {
  final TransportRepository repository;

  UpdateTransportMode(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTransportModeParams params) async {
    return await repository.updateTransportMode(params.transportMode);
  }
}

class UpdateTransportModeParams extends Equatable {
  final TransportMode transportMode;

  const UpdateTransportModeParams({required this.transportMode});

  @override
  List<Object?> get props => [transportMode];
}
