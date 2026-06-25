/// Use case: Update a single colis status.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';

class UpdateColisStatus implements UseCase<void, UpdateColisStatusParams> {
  final ColisRepository repository;

  UpdateColisStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateColisStatusParams params) async {
    return await repository.updateColisStatus(params.id, params.status);
  }
}

class UpdateColisStatusParams extends Equatable {
  final String id;
  final String status;

  const UpdateColisStatusParams({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}
