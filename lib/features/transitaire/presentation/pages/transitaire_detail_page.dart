import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:colis_manager/core/theme/app_theme.dart';
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';
import 'package:colis_manager/features/transport/presentation/bloc/transport_bloc.dart';
import 'package:colis_manager/features/transport/presentation/bloc/transport_event.dart';
import 'package:colis_manager/features/transport/presentation/bloc/transport_state.dart';
import 'package:colis_manager/features/transport/presentation/widgets/transport_mode_card.dart';
import 'package:colis_manager/features/colis/presentation/pages/colis_list_page.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_bloc.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_state.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/usecases/get_colis_by_transport.dart';

class TransitaireDetailPage extends StatelessWidget {
  final Transitaire transitaire;

  const TransitaireDetailPage({super.key, required this.transitaire});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.I<TransportBloc>()
            ..add(LoadTransportModesEvent(transitaireId: transitaire.id)),
        ),
        BlocProvider(create: (_) => GetIt.I<ColisBloc>()),
      ],
      child: _TransitaireDetailView(transitaire: transitaire),
    );
  }
}

class _TransitaireDetailView extends StatelessWidget {
  final Transitaire transitaire;

  const _TransitaireDetailView({required this.transitaire});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transitaire.nom),
      ),
      body: BlocConsumer<TransportBloc, TransportState>(
        listener: (context, state) {
          if (state is TransportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.statusNonLivre,
              ),
            );
          }
          if (state is TransportActionSuccess) {
            // No notification for smoother UX
          }
        },
        builder: (context, state) {
          if (state is TransportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransportLoaded) {
            return _buildContent(context, state.transportModes);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TransportMode> modes) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: modes.length,
      itemBuilder: (context, index) {
        final mode = modes[index];
        return _TransportModeCardWithCounts(
          mode: mode,
          transitaireName: transitaire.nom,
          index: index,
        );
      },
    );
  }
}

class _TransportModeCardWithCounts extends StatefulWidget {
  final TransportMode mode;
  final String transitaireName;
  final int index;

  const _TransportModeCardWithCounts({
    required this.mode,
    required this.transitaireName,
    required this.index,
  });

  @override
  State<_TransportModeCardWithCounts> createState() =>
      _TransportModeCardWithCountsState();
}

class _TransportModeCardWithCountsState
    extends State<_TransportModeCardWithCounts> {
  int _colisCount = 0;
  int _nonLivreCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final bloc = context.read<ColisBloc>();
    final state = bloc.state is ColisLoaded
        ? bloc.state as ColisLoaded
        : null;
    if (state != null && state.allColis.isNotEmpty &&
        state.allColis.first.transportModeId == widget.mode.id) {
      _updateCounts(state.allColis);
      return;
    }

    final result = await _getColisForMode(bloc, widget.mode.id);
    if (result != null && mounted) {
      _updateCounts(result);
    }
  }

  List<Colis>? _cachedResult;

  Future<List<Colis>?> _getColisForMode(ColisBloc bloc, String modeId) async {
    try {
      if (_cachedResult != null) return _cachedResult;

      final GetColisByTransport useCase = GetIt.I();
      final result = await useCase(GetColisParams(transportModeId: modeId));
      return result.fold((_) => null, (colis) {
        _cachedResult = colis;
        return colis;
      });
    } catch (_) {
      return null;
    }
  }

  void _updateCounts(List<Colis> colis) {
    setState(() {
      _colisCount = colis.length;
      _nonLivreCount = colis.where((c) => !c.isLivre).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
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
      child: TransportModeCard(
        transportMode: widget.mode,
        colisCount: _colisCount,
        nonLivreCount: _nonLivreCount,
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ColisListPage(
                transportMode: widget.mode,
                transitaireName: widget.transitaireName,
              ),
            ),
          );
        },
      ),
    );
  }
}
