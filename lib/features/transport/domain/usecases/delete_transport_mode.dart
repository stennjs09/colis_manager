/// Use case: Delete a transport mode.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transport/domain/repositories/transport_repository.dart';

class DeleteTransportMode implements UseCase<void, DeleteTransportModeParams> {
  final TransportRepository repository;

  DeleteTransportMode(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransportModeParams params) async {
    return await repository.deleteTransportMode(params.id);
  }
}

class DeleteTransportModeParams extends Equatable {
  final String id;

  const DeleteTransportModeParams({required this.id});

  @override
  List<Object?> get props => [id];
}
