import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:colis_manager/core/theme/app_theme.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_bloc.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_event.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_state.dart';
import 'package:colis_manager/features/colis/presentation/widgets/colis_card.dart';
import 'package:colis_manager/features/colis/presentation/widgets/colis_selection_bar.dart';
import 'package:colis_manager/features/colis/presentation/widgets/total_summary_widget.dart';
import 'package:colis_manager/features/colis/presentation/pages/add_colis_page.dart';
import 'package:colis_manager/core/widgets/skeleton_widget.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';

class ColisListPage extends StatelessWidget {
  final TransportMode transportMode;
  final String transitaireName;

  const ColisListPage({
    super.key,
    required this.transportMode,
    required this.transitaireName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ColisBloc>()
        ..add(LoadColisEvent(transportModeId: transportMode.id)),
      child: _ColisListView(
        transportMode: transportMode,
        transitaireName: transitaireName,
      ),
    );
  }
}

class _ColisListView extends StatefulWidget {
  final TransportMode transportMode;
  final String transitaireName;

  const _ColisListView({
    required this.transportMode,
    required this.transitaireName,
  });

  @override
  State<_ColisListView> createState() => _ColisListViewState();
}

class _ColisListViewState extends State<_ColisListView> {
  final _searchController = TextEditingController();
  final _nonLivreScrollController = ScrollController();
  final _livreScrollController = ScrollController();
  final _pageController = PageController();
  int _currentTabIndex = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _nonLivreScrollController.addListener(() => _onScroll(_nonLivreScrollController));
    _livreScrollController.addListener(() => _onScroll(_livreScrollController));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nonLivreScrollController.dispose();
    _livreScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll(ScrollController controller) {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      context.read<ColisBloc>().add(LoadMoreColisEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAerien = widget.transportMode.type == TransportType.aerien;

    return BlocConsumer<ColisBloc, ColisState>(
      buildWhen: (previous, current) {
        if (current is ColisActionSuccess) return false;
        if (current is ColisLoading &&
            (previous is ColisLoaded || previous is ColisActionSuccess)) {
          return false;
        }
        return true;
      },
      listener: (context, state) {
        if (state is ColisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.statusNonLivre,
            ),
          );
        }
        if (state is ColisActionSuccess) {
          // No notification for smoother UX
        }
      },
      builder: (context, state) {
        final ColisLoaded? loadedState =
            state is ColisLoaded ? state : null;
        final isSelectionMode =
            loadedState != null && loadedState.isSelectionMode;

        return Scaffold(
          appBar: _buildAppBar(context, state, isSelectionMode),
          body: _buildBody(context, state),
          floatingActionButton: isSelectionMode
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _navigateToAddColis(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Colis'),
                  backgroundColor:
                      isAerien ? AppTheme.accentAerien : AppTheme.accentMaritime,
                ),
          bottomSheet: isSelectionMode
              ? ColisSelectionBar(
                  selectedCount: loadedState.selectedIds.length,
                  totalPoidsKg: loadedState.selectedTotalPoidsKg,
                  totalPoidsM3: loadedState.selectedTotalPoidsM3,
                  totalPrix: loadedState.selectedTotalPrix,
                  areAllLivre: loadedState.selectedColis.every(
                    (c) => c.isLivre,
                  ),
                  accentColor: widget.transportMode.type == TransportType.aerien
                      ? AppTheme.accentAerien
                      : AppTheme.accentMaritime,
                  onToggleStatus: () {
                    HapticFeedback.mediumImpact();
                    final allLivre = loadedState.selectedColis.every(
                      (c) => c.isLivre,
                    );
                    context.read<ColisBloc>().add(
                      BulkUpdateStatusEvent(
                        status: allLivre ? 'en_attente' : 'livre',
                      ),
                    );
                  },
                  onEdit: loadedState.selectedIds.length == 1
                      ? () {
                          final colis = loadedState.selectedColis.first;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddColisPage(
                                transportMode: widget.transportMode,
                                colisBloc: context.read<ColisBloc>(),
                                existingColis: colis,
                              ),
                            ),
                          );
                        }
                      : null,
                  onUpdateDateArrivee: () {
                    HapticFeedback.mediumImpact();
                    _showBulkDatePicker(context, loadedState.selectedIds.toList());
                  },
                  onDelete: () {
                    HapticFeedback.mediumImpact();
                    _confirmBulkDelete(context, loadedState.selectedIds.toList());
                  },
                )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColisState state,
    bool isSelectionMode,
  ) {
    if (isSelectionMode && state is ColisLoaded) {
      return AppBar(
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            context.read<ColisBloc>().add(ClearSelectionEvent());
          },
        ),
        title: Text(
          '${state.selectedIds.length} sélectionné(s)',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Builder(
            builder: (context) {
              final currentList = _currentTabIndex == 0
                  ? state.nonLivreColis
                  : state.livreColis;
              final allSelected = currentList.every(
                (c) => state.selectedIds.contains(c.id),
              );
              return TextButton.icon(
                onPressed: () {
                  if (allSelected) {
                    context.read<ColisBloc>().add(ClearSelectionEvent());
                  } else {
                    context.read<ColisBloc>().add(
                      SelectAllColisEvent(
                        targetIds: currentList.map((c) => c.id).toList(),
                      ),
                    );
                  }
                },
                icon: Icon(
                  allSelected
                      ? Icons.deselect_rounded
                      : Icons.select_all_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  allSelected ? 'Aucun' : 'Tout',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      );
    }

    if (_isSearching) {
      final isAerien = widget.transportMode.type == TransportType.aerien;
      return AppBar(
        backgroundColor: isAerien ? AppTheme.accentAerien : AppTheme.accentMaritime,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            setState(() => _isSearching = false);
            _searchController.clear();
            context.read<ColisBloc>().add(const SearchColisEvent(query: ''));
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Rechercher par tracking...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: (query) {
            context.read<ColisBloc>().add(SearchColisEvent(query: query));
          },
        ),
      );
    }

    final isAerien = widget.transportMode.type == TransportType.aerien;
    return AppBar(
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      title: Column(
        children: [
          Text(
            widget.transitaireName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            isAerien ? 'Aérien' : 'Maritime',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      backgroundColor:
          isAerien ? AppTheme.accentAerien : AppTheme.accentMaritime,
      actions: [
        if (state is ColisLoaded && state.allColis.isNotEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded),
                tooltip: 'Notifications',
                onPressed: () => _showNotificationSheet(context, state),
              ),
              if (state.arrivedNonLivreCount > 0)
                Positioned(
                  top: 10,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.statusNonLivre,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
                    child: Text(
                      '${state.arrivedNonLivreCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => setState(() => _isSearching = true),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ColisState state) {
    if (state is ColisLoading) {
      return _buildSkeletonList();
    }

    if (state is ColisEmpty) {
      return _buildEmptyState();
    }

    if (state is ColisLoaded) {
      return _buildContent(context, state);
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    final isAerien = widget.transportMode.type == TransportType.aerien;
    final color = isAerien ? AppTheme.accentAerien : AppTheme.accentMaritime;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              size: 80,
              color: color.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun colis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier colis\nen collant le texte du transitaire',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonWidget(width: 52, height: 52, borderRadius: BorderRadius.all(Radius.circular(12))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonWidget(width: double.infinity, height: 18),
                      SizedBox(height: 12),
                      SkeletonWidget(width: 100, height: 14),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          SkeletonWidget(width: 60, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
                          SizedBox(width: 8),
                          SkeletonWidget(width: 80, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ColisLoaded state) {
    final currentList = _currentTabIndex == 0 ? state.nonLivreColis : state.livreColis;
    final currentPoidsKg = currentList
        .where((c) => c.unite.label == 'KG')
        .fold(0.0, (s, c) => s + c.poids);
    final currentPoidsM3 = currentList
        .where((c) => c.unite.label == 'M3')
        .fold(0.0, (s, c) => s + c.poids);
    final currentPrix = currentList.fold(0.0, (s, c) => s + c.prixFret);
    final currentNombre = currentList.fold<int>(0, (s, c) => s + (c.nombre ?? 1));
    final subtitle = _currentTabIndex == 0
        ? '${currentList.length} non livré(s)'
        : '${currentList.length} livré(s)';

    return Column(
      children: [
        TotalSummaryWidget(
          totalColis: currentList.length,
          subtitle: subtitle,
          totalPoidsKg: currentPoidsKg,
          totalPoidsM3: currentPoidsM3,
          totalPrix: currentPrix,
          isAerien: widget.transportMode.type == TransportType.aerien,
          totalNombre: currentNombre,
        ),
        _buildSegmentControl(context, state),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentTabIndex = index);
            },
            children: [
              _buildColisPage(
                context, state, state.nonLivreColis,
                scrollController: _nonLivreScrollController,
              ),
              _buildColisPage(
                context, state, state.livreColis,
                scrollController: _livreScrollController,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColisPage(
    BuildContext context,
    ColisLoaded state,
    List<Colis> colisList, {
    required ScrollController scrollController,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ColisBloc>().add(
          LoadColisEvent(transportModeId: widget.transportMode.id),
        );
      },
      child: colisList.isEmpty
          ? _buildFilteredEmptyState(context, state)
          : ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.only(
                top: 4,
                bottom: state.isSelectionMode ? 200 : 88,
              ),
              itemCount: colisList.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= colisList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  );
                }
                final colis = colisList[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(
                      milliseconds: 200 + (index * 50).clamp(0, 300)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 15 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: ColisCard(
                    colis: colis,
                    isSelectionMode: state.isSelectionMode,
                    isSelected: state.selectedIds.contains(colis.id),
                    onTap: () {
                      if (state.isSelectionMode) {
                        context.read<ColisBloc>().add(
                          ToggleColisSelectionEvent(colisId: colis.id),
                        );
                      }
                    },
                    onLongPress: () {
                      if (!state.isSelectionMode) {
                        context.read<ColisBloc>().add(
                          ToggleSelectionModeEvent(),
                        );
                      }
                      context.read<ColisBloc>().add(
                        ToggleColisSelectionEvent(colisId: colis.id),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFilteredEmptyState(BuildContext context, ColisLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Essayez de modifier vos filtres\nou votre recherche',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              context.read<ColisBloc>().add(const SearchColisEvent(query: ''));
              _searchController.clear();
              setState(() => _isSearching = false);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réinitialiser les filtres'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentControl(BuildContext context, ColisLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildSegment(
            context,
            label: 'Non Livrés (${state.nonLivreCount})',
            isSelected: _currentTabIndex == 0,
            color: AppTheme.statusNonLivre,
            onTap: () {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
              );
            },
          ),
          const SizedBox(width: 8),
          _buildSegment(
            context,
            label: 'Livrés (${state.livreCount})',
            isSelected: _currentTabIndex == 1,
            color: AppTheme.statusLivre,
            onTap: () {
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? color : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddColis(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddColisPage(
          transportMode: widget.transportMode,
          colisBloc: context.read<ColisBloc>(),
        ),
      ),
    );
  }

  Widget _buildSheetThumbnail(Colis colis) {
    if (colis.imagePath != null && colis.imagePath!.isNotEmpty) {
      final file = File(colis.imagePath!);
      if (file.existsSync()) {
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.statusNonLivre.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.inventory_2_rounded,
        size: 22,
        color: AppTheme.statusNonLivre,
      ),
    );
  }

  Widget _buildNotificationSummary(List<Colis> colis) {
    final weightFormat = NumberFormat('#,##0.######', 'fr');
    final numberFormat = NumberFormat('#,##0', 'fr');
    final kg = colis.where((c) => c.unite.label == 'KG').fold(0.0, (s, c) => s + c.poids);
    final m3 = colis.where((c) => c.unite.label == 'M3').fold(0.0, (s, c) => s + c.poids);
    final fret = colis.fold(0.0, (s, c) => s + c.prixFret);
    final isAerien = widget.transportMode.type == TransportType.aerien;
    final color = isAerien ? AppTheme.accentAerien : AppTheme.accentMaritime;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (isAerien)
            _buildNotifStat(Icons.scale_rounded, '${weightFormat.format(kg)} KG', color),
          if (!isAerien)
            _buildNotifStat(Icons.view_in_ar_rounded, '${weightFormat.format(m3)} M3', color),
          _buildNotifStat(Icons.payments_rounded, '${numberFormat.format(fret)} Ar', color),
        ],
      ),
    );
  }

  Widget _buildNotifStat(IconData icon, String text, Color color) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSheet(BuildContext context, ColisLoaded state) {
    final bloc = context.read<ColisBloc>();
    final items = state.arrivedNonLivreColis.toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.85,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.notifications_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${items.length} colis arrivé(s)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (items.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                for (final c in items) {
                                  bloc.add(
                                    UpdateColisStatusEvent(
                                      id: c.id,
                                      status: 'livre',
                                    ),
                                  );
                                }
                                setSheetState(() => items.clear());
                              },
                              child: const Text('Tout livrer'),
                            ),
                        ],
                      ),
                      if (items.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildNotificationSummary(items),
                      ],
                      const Divider(),
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        size: 48, color: AppTheme.statusLivre),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Aucun colis en attente',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: items.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (_, index) {
                                  final c = items[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                    leading: _buildSheetThumbnail(c),
                                    title: Text(
                                      'N° ${c.trackingNumber}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${NumberFormat('#,##0.######', 'fr').format(c.poids)} ${c.unite.label}  ·  '
                                      '${NumberFormat('#,##0', 'fr').format(c.prixFret)} Ar  ·  '
                                      'Arrivé ${DateFormat('dd/MM/yyyy').format(c.dateArrivee!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: AppTheme.statusLivre,
                                      ),
                                      onPressed: () {
                                        context.read<ColisBloc>().add(
                                          UpdateColisStatusEvent(
                                            id: c.id,
                                            status: 'livre',
                                          ),
                                        );
                                        setSheetState(() => items.removeAt(index));
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showBulkDatePicker(BuildContext context, List<String> ids) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: "Date d'arrivée",
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
    if (picked != null && context.mounted) {
      context.read<ColisBloc>().add(BulkUpdateDateArriveeEvent(date: picked));
    }
  }

  Future<void> _confirmBulkDelete(BuildContext context, List<String> ids) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer ${ids.length} colis'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ces colis ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.statusNonLivre),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ColisBloc>().add(BulkDeleteColisEvent(ids: ids));
    }
  }
}
