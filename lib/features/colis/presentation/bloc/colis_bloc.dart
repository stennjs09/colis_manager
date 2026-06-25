import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';
import 'package:colis_manager/features/colis/domain/usecases/add_colis.dart';
import 'package:colis_manager/features/colis/domain/usecases/update_colis.dart';
import 'package:colis_manager/features/colis/domain/usecases/get_colis_by_transport.dart';
import 'package:colis_manager/features/colis/domain/usecases/get_colis_by_transport_paginated.dart';
import 'package:colis_manager/features/colis/domain/usecases/get_colis_count.dart';
import 'package:colis_manager/features/colis/domain/usecases/update_colis_status.dart';
import 'package:colis_manager/features/colis/domain/usecases/bulk_update_colis_status.dart';
import 'package:colis_manager/features/colis/domain/usecases/delete_colis.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_event.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_state.dart';

class ColisBloc extends Bloc<ColisEvent, ColisState> {
  final GetColisByTransport getColisByTransport;
  final GetColisByTransportPaginated getColisByTransportPaginated;
  final GetColisCount getColisCount;
  final AddColis addColis;
  final UpdateColis updateColis;
  final UpdateColisStatus updateColisStatus;
  final BulkUpdateColisStatus bulkUpdateColisStatus;
  final ColisRepository colisRepository;
  final DeleteColis deleteColis;

  String? _currentTransportModeId;
  static const int _pageSize = 20;

  ColisBloc({
    required this.getColisByTransport,
    required this.getColisByTransportPaginated,
    required this.getColisCount,
    required this.addColis,
    required this.updateColis,
    required this.updateColisStatus,
    required this.bulkUpdateColisStatus,
    required this.colisRepository,
    required this.deleteColis,
  }) : super(ColisInitial()) {
    on<LoadColisEvent>(_onLoad);
    on<LoadMoreColisEvent>(_onLoadMore);
    on<AddColisEvent>(_onAdd);
    on<UpdateColisEvent>(_onUpdateColis);
    on<UpdateColisStatusEvent>(_onUpdateStatus);
    on<BulkUpdateStatusEvent>(_onBulkUpdate);
    on<BulkUpdateDateArriveeEvent>(_onBulkUpdateDateArrivee);
    on<BulkDeleteColisEvent>(_onBulkDelete);
    on<DeleteColisEvent>(_onDelete);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<ToggleColisSelectionEvent>(_onToggleSelection);
    on<SelectAllColisEvent>(_onSelectAll);
    on<ClearSelectionEvent>(_onClearSelection);
    on<FilterColisEvent>(_onFilter);
    on<SearchColisEvent>(_onSearch);
  }

  Future<void> _onLoad(
    LoadColisEvent event,
    Emitter<ColisState> emit,
  ) async {
    _currentTransportModeId = event.transportModeId;
    emit(ColisLoading());
    final results = await Future.wait([
      getColisByTransportPaginated(
        GetColisPaginatedParams(
          transportModeId: event.transportModeId,
          limit: _pageSize,
          offset: 0,
        ),
      ),
      getColisCount(
        GetColisCountParams(transportModeId: event.transportModeId),
      ),
    ]);

    final colisResult = results[0] as Either<Failure, List<Colis>>;
    final countResult = results[1] as Either<Failure, int>;

    colisResult.fold(
      (failure) => emit(ColisError(message: failure.message)),
      (colisList) {
        final totalCount = countResult.fold((_) => 0, (count) => count);
        if (colisList.isEmpty) {
          emit(ColisEmpty());
        } else {
          emit(ColisLoaded(
            allColis: colisList,
            filteredColis: colisList,
            currentPage: 0,
            hasMore: colisList.length < totalCount,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreColisEvent event,
    Emitter<ColisState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ColisLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore ||
        _currentTransportModeId == null) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await getColisByTransportPaginated(
      GetColisPaginatedParams(
        transportModeId: _currentTransportModeId!,
        limit: _pageSize,
        offset: nextPage * _pageSize,
      ),
    );

    final eitherNewColis = result;
    if (eitherNewColis.isLeft()) {
      emit(currentState.copyWith(isLoadingMore: false));
      return;
    }

    final newColis = eitherNewColis.getOrElse(() => []);
    final totalCountEither = currentState.hasMore
        ? await getColisCount(
            GetColisCountParams(
                transportModeId: _currentTransportModeId!),
          )
        : null;
    final totalCount =
        totalCountEither?.fold((_) => 0, (count) => count) ?? 0;

    final allColis = [...currentState.allColis, ...newColis];
    final hasMore = allColis.length < totalCount;

    final filtered = _applyFilters(
      allColis,
      currentState.searchQuery,
    );

    emit(ColisLoaded(
      allColis: allColis,
      filteredColis: filtered,
      selectedIds: currentState.selectedIds,
      isSelectionMode: currentState.isSelectionMode,
      statusFilter: currentState.statusFilter,
      searchQuery: currentState.searchQuery,
      currentPage: nextPage,
      hasMore: hasMore,
    ));
  }

  Future<void> _onAdd(
    AddColisEvent event,
    Emitter<ColisState> emit,
  ) async {
    final result = await addColis(AddColisParams(colis: event.colis));
    result.fold(
      (failure) => emit(ColisError(message: failure.message)),
      (_) {
        emit(const ColisActionSuccess(message: 'Colis ajouté avec succès'));
        if (_currentTransportModeId != null) {
          add(LoadColisEvent(transportModeId: _currentTransportModeId!));
        }
      },
    );
  }

  Future<void> _onUpdateColis(
    UpdateColisEvent event,
    Emitter<ColisState> emit,
  ) async {
    final result = await updateColis(UpdateColisParams(colis: event.colis));
    result.fold(
      (failure) => emit(ColisError(message: failure.message)),
      (_) {
        emit(const ColisActionSuccess(message: 'Colis modifié avec succès'));
        if (_currentTransportModeId != null) {
          add(LoadColisEvent(transportModeId: _currentTransportModeId!));
        }
      },
    );
  }

  Future<void> _onUpdateStatus(
    UpdateColisStatusEvent event,
    Emitter<ColisState> emit,
  ) async {
    final result = await updateColisStatus(
      UpdateColisStatusParams(id: event.id, status: event.status),
    );
    result.fold(
      (failure) => emit(ColisError(message: failure.message)),
      (_) {
        if (_currentTransportModeId != null) {
          add(LoadColisEvent(transportModeId: _currentTransportModeId!));
        }
      },
    );
  }

  Future<void> _onBulkUpdate(
    BulkUpdateStatusEvent event,
    Emitter<ColisState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ColisLoaded) return;

    final ids = currentState.selectedIds.toList();
    if (ids.isEmpty) return;

    final result = await bulkUpdateColisStatus(
      BulkUpdateParams(ids: ids, status: event.status),
    );
    result.fold(
      (failure) => emit(ColisError(message: failure.message)),
      (_) {
        final action = event.status == 'livre' ? 'livré(s)' : 'non livré(s)';
        emit(ColisActionSuccess(
          message: '${ids.length} colis marqué(s) comme $action',
        ));
        if (_currentTransportModeId != null) {
          add(LoadColisEvent(transportModeId: _currentTransportModeId!));
        }
      },
    );
  }

  Future<void> _onBulkUpdateDateArrivee(
    BulkUpdateDateArriveeEvent event,
    Emitter<ColisState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ColisLoaded) return;

    final ids = currentState.selectedIds.toList();
    if (ids.isEmpty) return;

    final result = await colisRepository.bulkUpdateDateArrivee(ids, event.date);
    result.fold(
      (failure) => emit(ColisError(message: failure.message)),
      (_) {
        if (_currentTransportModeId != null) {
          add(LoadColisEvent(transportModeId: _currentTransportModeId!));
        }
      },
    );
  }

  Future<void> _onBulkDelete(
    BulkDeleteColisEvent event,
    Emitter<ColisState> emit,
  ) async {
    for (final id in event.ids) {
      final result = await deleteColis(DeleteColisParams(id: id));
      if (result.isLeft()) {
        emit(ColisError(message: 'Erreur lors de la suppression'));
        return;
      }
    }
    emit(ColisActionSuccess(
      message: '${event.ids.length} colis supprimé(s)',
    ));
    if (_currentTransportModeId != null) {
      add(LoadColisEvent(transportModeId: _currentTransportModeId!));
    }
  }

  Future<void> _onDelete(
    DeleteColisEvent event,
    Emitter<ColisState> emit,
  ) async {
    final result = await deleteColis(DeleteColisParams(id: event.id));
    result.fold(
      (failure) => emit(ColisError(message: failure.message)),
      (_) {
        emit(const ColisActionSuccess(message: 'Colis supprimé'));
        if (_currentTransportModeId != null) {
          add(LoadColisEvent(transportModeId: _currentTransportModeId!));
        }
      },
    );
  }

  void _onToggleSelectionMode(
    ToggleSelectionModeEvent event,
    Emitter<ColisState> emit,
  ) {
    final currentState = state;
    if (currentState is ColisLoaded) {
      emit(currentState.copyWith(
        isSelectionMode: !currentState.isSelectionMode,
        selectedIds: {},
      ));
    }
  }

  void _onToggleSelection(
    ToggleColisSelectionEvent event,
    Emitter<ColisState> emit,
  ) {
    final currentState = state;
    if (currentState is ColisLoaded) {
      final newSelected = Set<String>.from(currentState.selectedIds);
      if (newSelected.contains(event.colisId)) {
        newSelected.remove(event.colisId);
      } else {
        newSelected.add(event.colisId);
      }
      emit(currentState.copyWith(
        selectedIds: newSelected,
        isSelectionMode: newSelected.isNotEmpty,
      ));
    }
  }

  void _onSelectAll(
    SelectAllColisEvent event,
    Emitter<ColisState> emit,
  ) {
    final currentState = state;
    if (currentState is ColisLoaded) {
      final allIds = event.targetIds != null
          ? event.targetIds!.toSet()
          : currentState.filteredColis.map((c) => c.id).toSet();
      emit(currentState.copyWith(selectedIds: allIds));
    }
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<ColisState> emit,
  ) {
    final currentState = state;
    if (currentState is ColisLoaded) {
      emit(currentState.copyWith(
        selectedIds: {},
        isSelectionMode: false,
      ));
    }
  }

  void _onFilter(
    FilterColisEvent event,
    Emitter<ColisState> emit,
  ) {
    final currentState = state;
    if (currentState is ColisLoaded) {
      final filtered = _applyFilters(
        currentState.allColis,
        currentState.searchQuery,
      );
      emit(currentState.copyWith(
        filteredColis: filtered,
        statusFilter: event.statusFilter,
        selectedIds: {},
        isSelectionMode: false,
      ));
    }
  }

  void _onSearch(
    SearchColisEvent event,
    Emitter<ColisState> emit,
  ) {
    final currentState = state;
    if (currentState is ColisLoaded) {
      final filtered = _applyFilters(
        currentState.allColis,
        event.query,
      );
      emit(currentState.copyWith(
        filteredColis: filtered,
        searchQuery: event.query,
      ));
    }
  }

  List<Colis> _applyFilters(
    List<Colis> allColis,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return allColis;

    final query = searchQuery.toLowerCase();
    return allColis
        .where((c) => c.trackingNumber.toLowerCase().contains(query))
        .toList();
  }
}
