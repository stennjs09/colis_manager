/// Selection bar widget.
///
/// Shows at the bottom when selection mode is active.
/// Displays count, total weight, total amount, and actions.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:colis_manager/core/theme/app_theme.dart';

class ColisSelectionBar extends StatelessWidget {
  final int selectedCount;
  final double totalPoidsKg;
  final double totalPoidsM3;
  final double totalPrix;
  final bool areAllLivre;
  final Color accentColor;
  final VoidCallback onToggleStatus;
  final VoidCallback? onEdit;
  final VoidCallback onUpdateDateArrivee;
  final VoidCallback onDelete;

  const ColisSelectionBar({
    super.key,
    required this.selectedCount,
    required this.totalPoidsKg,
    required this.totalPoidsM3,
    required this.totalPrix,
    required this.areAllLivre,
    required this.accentColor,
    required this.onToggleStatus,
    this.onEdit,
    required this.onUpdateDateArrivee,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0', 'fr');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Stats row
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.check_box_rounded,
                    value: '$selectedCount',
                    label: 'sélectionné(s)',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    icon: _getIcon(),
                    value: _formatWeight(),
                    label: _getLabel(),
                    color: AppTheme.accentAerien,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    icon: Icons.payments_rounded,
                    value: '${numberFormat.format(totalPrix)} Ar',
                    label: 'montant total',
                    color: AppTheme.accentMaritime,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: areAllLivre
                        ? Icons.undo_rounded
                        : Icons.check_circle_rounded,
                    onTap: onToggleStatus,
                  ),
                  if (selectedCount == 1 && onEdit != null)
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      onTap: onEdit!,
                    ),
                  _buildActionButton(
                    icon: Icons.calendar_today_rounded,
                    onTap: onUpdateDateArrivee,
                  ),
                  _buildActionButton(
                    icon: Icons.delete_rounded,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Icon(icon, color: accentColor, size: 24),
      ),
    );
  }

  String _formatWeight() {
    final hasKg = totalPoidsKg > 0;
    final hasM3 = totalPoidsM3 > 0;
    final formatter = NumberFormat('#,##0.######', 'fr');
    
    if (hasKg && hasM3) {
      return '${formatter.format(totalPoidsKg)}KG\n${formatter.format(totalPoidsM3)}M3';
    } else if (hasKg) {
      return '${formatter.format(totalPoidsKg)} KG';
    } else {
      return '${formatter.format(totalPoidsM3)} M3';
    }
  }

  IconData _getIcon() {
    if (totalPoidsKg > 0 && totalPoidsM3 > 0) return Icons.widgets_rounded;
    if (totalPoidsM3 > 0) return Icons.view_in_ar_rounded;
    return Icons.scale_rounded;
  }

  String _getLabel() {
    if (totalPoidsKg > 0 && totalPoidsM3 > 0) return 'poids & volume';
    if (totalPoidsM3 > 0 && totalPoidsKg == 0) return 'volume total';
    return 'poids total';
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
