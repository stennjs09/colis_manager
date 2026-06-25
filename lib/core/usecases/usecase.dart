/// Generic UseCase interface following Clean Architecture.
///
/// Every use case implements this interface, ensuring a consistent
/// contract: call(params) returns Either<Failure, Type>.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:colis_manager/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Used when a use case does not require any parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
