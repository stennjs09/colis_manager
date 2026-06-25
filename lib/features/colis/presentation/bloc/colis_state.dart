import 'package:equatable/equatable.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';

sealed class ColisState extends Equatable {
  const ColisState();

  @override
  List<Object?> get props => [];
}

class ColisInitial extends ColisState {}

class ColisLoading extends ColisState {}

class ColisLoaded extends ColisState {
  final List<Colis> allColis;
  final List<Colis> filteredColis;
  final Set<String> selectedIds;
  final bool isSelectionMode;
  final String? statusFilter;
  final String searchQuery;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;

  const ColisLoaded({
    required this.allColis,
    required this.filteredColis,
    this.selectedIds = const {},
    this.isSelectionMode = false,
    this.statusFilter,
    this.searchQuery = '',
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
  });

  int get totalCount => allColis.length;
  int get nonLivreCount =>
      allColis.where((c) => !c.isLivre).length;
  int get livreCount =>
      allColis.where((c) => c.isLivre).length;

  List<Colis> get nonLivreColis =>
      allColis.where((c) => !c.isLivre).toList();
  List<Colis> get livreColis =>
      allColis.where((c) => c.isLivre).toList();

  int get arrivedNonLivreCount =>
      allColis.where((c) => c.isArrived).length;
  List<Colis> get arrivedNonLivreColis =>
      allColis.where((c) => c.isArrived).toList();

  double get totalPoids =>
      allColis.fold(0.0, (sum, c) => sum + c.poids);
  double get totalPoidsKg =>
      allColis.where((c) => c.unite.label == 'KG').fold(0.0, (sum, c) => sum + c.poids);
  double get totalPoidsM3 =>
      allColis.where((c) => c.unite.label == 'M3').fold(0.0, (sum, c) => sum + c.poids);
  double get totalPrixFret =>
      allColis.fold(0.0, (sum, c) => sum + c.prixFret);

  List<Colis> get selectedColis =>
      allColis.where((c) => selectedIds.contains(c.id)).toList();
  double get selectedTotalPoids =>
      selectedColis.fold(0.0, (sum, c) => sum + c.poids);
  double get selectedTotalPoidsKg =>
      selectedColis.where((c) => c.unite.label == 'KG').fold(0.0, (sum, c) => sum + c.poids);
  double get selectedTotalPoidsM3 =>
      selectedColis.where((c) => c.unite.label == 'M3').fold(0.0, (sum, c) => sum + c.poids);
  double get selectedTotalPrix =>
      selectedColis.fold(0.0, (sum, c) => sum + c.prixFret);

  ColisLoaded copyWith({
    List<Colis>? allColis,
    List<Colis>? filteredColis,
    Set<String>? selectedIds,
    bool? isSelectionMode,
    String? statusFilter,
    String? searchQuery,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return ColisLoaded(
      allColis: allColis ?? this.allColis,
      filteredColis: filteredColis ?? this.filteredColis,
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      statusFilter: statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        allColis,
        filteredColis,
        selectedIds,
        isSelectionMode,
        statusFilter,
        searchQuery,
        isLoadingMore,
        hasMore,
        currentPage,
      ];
}

class ColisEmpty extends ColisState {}

class ColisError extends ColisState {
  final String message;

  const ColisError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ColisActionSuccess extends ColisState {
  final String message;

  const ColisActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
