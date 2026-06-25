/// Use case: Bulk update colis status.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';

class BulkUpdateColisStatus implements UseCase<void, BulkUpdateParams> {
  final ColisRepository repository;

  BulkUpdateColisStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(BulkUpdateParams params) async {
    return await repository.bulkUpdateColisStatus(params.ids, params.status);
  }
}

class BulkUpdateParams extends Equatable {
  final List<String> ids;
  final String status;

  const BulkUpdateParams({required this.ids, required this.status});

  @override
  List<Object?> get props => [ids, status];
}
