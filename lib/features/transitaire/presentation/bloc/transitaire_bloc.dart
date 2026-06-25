/// Transitaire BLoC.
///
/// Delegates all business logic to use cases. Contains no domain logic.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:colis_manager/core/usecases/usecase.dart';
import 'package:colis_manager/features/transitaire/domain/usecases/add_transitaire.dart';
import 'package:colis_manager/features/transitaire/domain/usecases/get_all_transitaires.dart';
import 'package:colis_manager/features/transitaire/domain/usecases/delete_transitaire.dart';
import 'package:colis_manager/features/transitaire/domain/usecases/update_transitaire.dart';
import 'package:colis_manager/features/transitaire/presentation/bloc/transitaire_event.dart';
import 'package:colis_manager/features/transitaire/presentation/bloc/transitaire_state.dart';

class TransitaireBloc extends Bloc<TransitaireEvent, TransitaireState> {
  final GetAllTransitaires getAllTransitaires;
  final AddTransitaire addTransitaire;
  final DeleteTransitaire deleteTransitaire;
  final UpdateTransitaire updateTransitaire;

  TransitaireBloc({
    required this.getAllTransitaires,
    required this.addTransitaire,
    required this.deleteTransitaire,
    required this.updateTransitaire,
  }) : super(TransitaireInitial()) {
    on<LoadTransitairesEvent>(_onLoadTransitaires);
    on<AddTransitaireEvent>(_onAddTransitaire);
    on<UpdateTransitaireEvent>(_onUpdateTransitaire);
    on<DeleteTransitaireEvent>(_onDeleteTransitaire);
  }

  Future<void> _onLoadTransitaires(
    LoadTransitairesEvent event,
    Emitter<TransitaireState> emit,
  ) async {
    emit(TransitaireLoading());
    final result = await getAllTransitaires(NoParams());
    result.fold(
      (failure) => emit(TransitaireError(message: failure.message)),
      (transitaires) {
        if (transitaires.isEmpty) {
          emit(TransitaireEmpty());
        } else {
          emit(TransitaireLoaded(transitaires: transitaires));
        }
      },
    );
  }

  Future<void> _onAddTransitaire(
    AddTransitaireEvent event,
    Emitter<TransitaireState> emit,
  ) async {
    final result = await addTransitaire(
      AddTransitaireParams(transitaire: event.transitaire),
    );
    result.fold(
      (failure) => emit(TransitaireError(message: failure.message)),
      (_) {
        emit(const TransitaireActionSuccess(message: 'Transitaire ajouté avec succès'));
        add(LoadTransitairesEvent());
      },
    );
  }

  Future<void> _onUpdateTransitaire(
    UpdateTransitaireEvent event,
    Emitter<TransitaireState> emit,
  ) async {
    final result = await updateTransitaire(
      UpdateTransitaireParams(transitaire: event.transitaire),
    );
    result.fold(
      (failure) => emit(TransitaireError(message: failure.message)),
      (_) {
        emit(const TransitaireActionSuccess(message: 'Transitaire modifié avec succès'));
        add(LoadTransitairesEvent());
      },
    );
  }

  Future<void> _onDeleteTransitaire(
    DeleteTransitaireEvent event,
    Emitter<TransitaireState> emit,
  ) async {
    final result = await deleteTransitaire(
      DeleteTransitaireParams(id: event.id),
    );
    result.fold(
      (failure) => emit(TransitaireError(message: failure.message)),
      (_) {
        emit(const TransitaireActionSuccess(message: 'Transitaire supprimé avec succès'));
        add(LoadTransitairesEvent());
      },
    );
  }
}
