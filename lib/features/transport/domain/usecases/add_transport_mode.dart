/// Use case: Add a transport mode to a transitaire.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';
import 'package:colis_manager/features/transport/domain/repositories/transport_repository.dart';

class AddTransportMode implements UseCase<void, AddTransportModeParams> {
  final TransportRepository repository;

  AddTransportMode(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransportModeParams params) async {
    // Business rule: Maritime must use M3
    if (params.transportMode.type == TransportType.maritime &&
        params.transportMode.unite.toUpperCase() != 'M3') {
      return const Left(
        ValidationFailure(message: 'Le mode maritime utilise uniquement le M3'),
      );
    }
    return await repository.addTransportMode(params.transportMode);
  }
}

class AddTransportModeParams extends Equatable {
  final TransportMode transportMode;

  const AddTransportModeParams({required this.transportMode});

  @override
  List<Object?> get props => [transportMode];
}
