/// Transport BLoC.
///
/// Manages transport modes for a specific transitaire.
/// Auto-creates Aérien and Maritime modes if none exist.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';
import 'package:colis_manager/features/transport/domain/usecases/add_transport_mode.dart';
import 'package:colis_manager/features/transport/domain/usecases/get_transport_modes_by_transitaire.dart';
import 'package:colis_manager/features/transport/domain/usecases/delete_transport_mode.dart';
import 'package:colis_manager/features/transport/domain/usecases/update_transport_mode.dart';
import 'package:colis_manager/features/transport/presentation/bloc/transport_event.dart';
import 'package:colis_manager/features/transport/presentation/bloc/transport_state.dart';

class TransportBloc extends Bloc<TransportEvent, TransportState> {
  final GetTransportModesByTransitaire getTransportModesByTransitaire;
  final AddTransportMode addTransportMode;
  final UpdateTransportMode updateTransportMode;
  final DeleteTransportMode deleteTransportMode;

  String? _currentTransitaireId;

  TransportBloc({
    required this.getTransportModesByTransitaire,
    required this.addTransportMode,
    required this.updateTransportMode,
    required this.deleteTransportMode,
  }) : super(TransportInitial()) {
    on<LoadTransportModesEvent>(_onLoad);
    on<AddTransportModeEvent>(_onAdd);
    on<UpdateTransportModeEvent>(_onUpdateTransportMode);
    on<DeleteTransportModeEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadTransportModesEvent event,
    Emitter<TransportState> emit,
  ) async {
    _currentTransitaireId = event.transitaireId;
    emit(TransportLoading());
    final result = await getTransportModesByTransitaire(
      GetTransportModesParams(transitaireId: event.transitaireId),
    );
    await result.fold(
      (failure) async => emit(TransportError(message: failure.message)),
      (modes) async {
        if (modes.isEmpty) {
          // Auto-create default Aérien and Maritime modes
          await _createDefaultModes(event.transitaireId);
          // Reload after creation
          final reloadResult = await getTransportModesByTransitaire(
            GetTransportModesParams(transitaireId: event.transitaireId),
          );
          reloadResult.fold(
            (failure) => emit(TransportError(message: failure.message)),
            (newModes) => emit(TransportLoaded(transportModes: newModes)),
          );
        } else {
          emit(TransportLoaded(transportModes: modes));
        }
      },
    );
  }

  Future<void> _createDefaultModes(String transitaireId) async {
    const uuid = Uuid();
    final aerien = TransportMode(
      id: uuid.v4(),
      transitaireId: transitaireId,
      type: TransportType.aerien,
      unite: 'KG',
    );
    final maritime = TransportMode(
      id: uuid.v4(),
      transitaireId: transitaireId,
      type: TransportType.maritime,
      unite: 'M3',
    );
    await addTransportMode(AddTransportModeParams(transportMode: aerien));
    await addTransportMode(AddTransportModeParams(transportMode: maritime));
  }

  Future<void> _onAdd(
    AddTransportModeEvent event,
    Emitter<TransportState> emit,
  ) async {
    final result = await addTransportMode(
      AddTransportModeParams(transportMode: event.transportMode),
    );
    result.fold(
      (failure) => emit(TransportError(message: failure.message)),
      (_) {
        emit(const TransportActionSuccess(message: 'Mode de transport ajouté'));
        if (_currentTransitaireId != null) {
          add(LoadTransportModesEvent(transitaireId: _currentTransitaireId!));
        }
      },
    );
  }

  Future<void> _onUpdateTransportMode(
    UpdateTransportModeEvent event,
    Emitter<TransportState> emit,
  ) async {
    final result = await updateTransportMode(
      UpdateTransportModeParams(transportMode: event.transportMode),
    );
    result.fold(
      (failure) => emit(TransportError(message: failure.message)),
      (_) {
        emit(const TransportActionSuccess(message: 'Mode de transport modifié'));
        if (_currentTransitaireId != null) {
          add(LoadTransportModesEvent(transitaireId: _currentTransitaireId!));
        }
      },
    );
  }

  Future<void> _onDelete(
    DeleteTransportModeEvent event,
    Emitter<TransportState> emit,
  ) async {
    final result = await deleteTransportMode(
      DeleteTransportModeParams(id: event.id),
    );
    result.fold(
      (failure) => emit(TransportError(message: failure.message)),
      (_) {
        emit(const TransportActionSuccess(message: 'Mode de transport supprimé'));
        if (_currentTransitaireId != null) {
          add(LoadTransportModesEvent(transitaireId: _currentTransitaireId!));
        }
      },
    );
  }
}
