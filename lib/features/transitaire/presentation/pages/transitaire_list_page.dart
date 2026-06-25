/// Transitaire list page — Home page of the application.
///
/// Displays all transitaires in a list with add/edit/delete capabilities.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:colis_manager/core/theme/app_theme.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';
import 'package:colis_manager/features/transitaire/presentation/bloc/transitaire_bloc.dart';
import 'package:colis_manager/features/transitaire/presentation/bloc/transitaire_event.dart';
import 'package:colis_manager/features/transitaire/presentation/bloc/transitaire_state.dart';
import 'package:colis_manager/features/transitaire/presentation/widgets/transitaire_card.dart';
import 'package:colis_manager/features/transitaire/presentation/widgets/add_transitaire_dialog.dart';
import 'package:colis_manager/features/transitaire/presentation/pages/transitaire_detail_page.dart';
import 'package:colis_manager/core/widgets/skeleton_widget.dart';


class TransitaireListPage extends StatefulWidget {
  const TransitaireListPage({super.key});

  @override
  State<TransitaireListPage> createState() => _TransitaireListPageState();
}

class _TransitaireListPageState extends State<TransitaireListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    context.read<TransitaireBloc>().add(LoadTransitairesEvent());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colis Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.local_shipping_rounded, size: 28),
                    SizedBox(width: 12),
                    Text('Colis Manager'),
                  ],
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Version 1.0.0'),
                    SizedBox(height: 8),
                    Text(
                      'Gestion centralisée de colis transitaires.\n'
                      'Transport Aérien & Maritime.',
                      style: TextStyle(color: Colors.grey, height: 1.4),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<TransitaireBloc, TransitaireState>(
        listener: (context, state) {
          if (state is TransitaireError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.statusNonLivre,
              ),
            );
          }
          if (state is TransitaireActionSuccess) {
            // No notification for smoother UX
          }
        },
        builder: (context, state) {
          if (state is TransitaireLoading) {
            return _buildSkeletonList();
          }

          if (state is TransitaireEmpty) {
            return _buildEmptyState();
          }

          if (state is TransitaireLoaded) {
            return _buildList(state.transitaires);
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Transitaire'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun transitaire',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier transitaire\npour commencer à gérer vos colis',
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
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const SkeletonWidget(width: 56, height: 56, borderRadius: BorderRadius.all(Radius.circular(16))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonWidget(width: 120, height: 20),
                      SizedBox(height: 8),
                      SkeletonWidget(width: 80, height: 14),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const SkeletonWidget(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<Transitaire> transitaires) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransitaireBloc>().add(LoadTransitairesEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: transitaires.length,
        itemBuilder: (context, index) {
          final transitaire = transitaires[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: TransitaireCard(
              transitaire: transitaire,
              onTap: () => _navigateToDetail(transitaire),
              onEdit: () => _showEditDialog(transitaire),
              onDelete: () => _confirmDelete(transitaire),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(Transitaire transitaire) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransitaireDetailPage(transitaire: transitaire),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (_) => const AddTransitaireDialog(),
    );

    if (result != null && mounted) {
      final transitaire = Transitaire(
        id: const Uuid().v4(),
        nom: result['nom']!,
        logoPath: result['logoPath'],
        createdAt: DateTime.now(),
      );
      context.read<TransitaireBloc>().add(
        AddTransitaireEvent(transitaire: transitaire),
      );
    }
  }

  Future<void> _showEditDialog(Transitaire transitaire) async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (_) => AddTransitaireDialog(
        title: 'Modifier le Transitaire',
        initialNom: transitaire.nom,
        initialLogoPath: transitaire.logoPath,
      ),
    );

    if (result != null && mounted) {
      final updated = transitaire.copyWith(
        nom: result['nom'],
        logoPath: result['logoPath'],
      );
      context.read<TransitaireBloc>().add(
        UpdateTransitaireEvent(transitaire: updated),
      );
    }
  }

  Future<void> _confirmDelete(Transitaire transitaire) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le transitaire'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${transitaire.nom}" ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.statusNonLivre),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<TransitaireBloc>().add(
        DeleteTransitaireEvent(id: transitaire.id),
      );
    }
  }
}
