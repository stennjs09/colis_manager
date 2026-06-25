import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:colis_manager/core/theme/app_theme.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/entities/colis_status.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ColisCard extends StatelessWidget {
  final Colis colis;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ColisCard({
    super.key,
    required this.colis,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
  });

  bool get _isArrived => colis.dateArrivee != null && colis.statut == ColisStatus.enTransit;

  Color get _badgeColor {
    if (_isArrived) return AppTheme.statusArrive;
    switch (colis.statut) {
      case ColisStatus.enTransit:
        return AppTheme.statusNonLivre;
      case ColisStatus.livre:
        return AppTheme.statusLivre;
    }
  }

  IconData get _badgeIcon {
    final isMaritime = colis.unite.label == 'M3';
    if (_isArrived) return Icons.location_on_rounded;
    switch (colis.statut) {
      case ColisStatus.enTransit:
        return isMaritime ? Icons.directions_boat_rounded : Icons.flight_rounded;
      case ColisStatus.livre:
        return Icons.check_circle_rounded;
    }
  }

  String get _badgeLabel {
    if (_isArrived) return 'Arrivé';
    return colis.statut.label;
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0', 'fr');
    final displayDate = colis.dateArrivee;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : null,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              onLongPress();
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (isSelectionMode) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onTap(),
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                  _buildThumbnail(context),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      colis.trackingNumber,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        fontFamily: GoogleFonts.spaceMono().fontFamily,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoChip(
                                colis.unite.label == 'M3' ? Icons.view_in_ar_rounded : Icons.scale_rounded,
                                '${NumberFormat('#,##0.######', 'fr').format(colis.poids)} ${colis.unite.label}',
                                AppTheme.accentAerien,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _buildInfoChip(
                                Icons.payments_rounded,
                                '${numberFormat.format(colis.prixFret)} Ar',
                                AppTheme.accentMaritime,
                              ),
                            ),
                          ],
                        ),
                        if (displayDate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Arrivé le ${DateFormat('dd/MM/yyyy').format(displayDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fade(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildThumbnail(BuildContext context) {
    Widget thumbnail;
    if (colis.imagePath != null && colis.imagePath!.isNotEmpty) {
      final file = File(colis.imagePath!);
      if (file.existsSync()) {
        thumbnail = GestureDetector(
          onTap: () => _showImageBottomSheet(context, file),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(file),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      } else {
        thumbnail = _buildPlaceholder(context);
      }
    } else {
      thumbnail = _buildPlaceholder(context);
    }

    if (colis.nombre != null && colis.nombre! > 1) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          thumbnail,
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${colis.nombre}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return thumbnail;
  }

  Widget _buildPlaceholder(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: primaryColor.withValues(alpha: 0.1),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: primaryColor.withValues(alpha: 0.5),
        size: 26,
      ),
    );
  }

  void _showImageBottomSheet(BuildContext context, File file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(file, height: 280, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_rounded, size: 20, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Numéro de tracking',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          colis.trackingNumber,
                          style: GoogleFonts.spaceMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20, color: AppTheme.primaryColor),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: colis.trackingNumber));
                        HapticFeedback.lightImpact();
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _badgeIcon,
            size: 13,
            color: _badgeColor,
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
