/// Use case: Get all transitaires.
import 'package:dartz/dartz.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';
import 'package:colis_manager/features/transitaire/domain/repositories/transitaire_repository.dart';

class GetAllTransitaires implements UseCase<List<Transitaire>, NoParams> {
  final TransitaireRepository repository;

  GetAllTransitaires(this.repository);

  @override
  Future<Either<Failure, List<Transitaire>>> call(NoParams params) async {
    return await repository.getAllTransitaires();
  }
}
