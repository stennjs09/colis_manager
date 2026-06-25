/// Use case: Delete a colis.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';

class DeleteColis implements UseCase<void, DeleteColisParams> {
  final ColisRepository repository;

  DeleteColis(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteColisParams params) async {
    return await repository.deleteColis(params.id);
  }
}

class DeleteColisParams extends Equatable {
  final String id;

  const DeleteColisParams({required this.id});

  @override
  List<Object?> get props => [id];
}
