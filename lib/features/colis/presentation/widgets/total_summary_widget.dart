import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:colis_manager/core/theme/app_theme.dart';

class TotalSummaryWidget extends StatelessWidget {
  final int totalColis;
  final String subtitle;
  final double totalPoidsKg;
  final double totalPoidsM3;
  final double totalPrix;
  final bool isAerien;
  final int totalNombre;

  const TotalSummaryWidget({
    super.key,
    required this.totalColis,
    required this.subtitle,
    required this.totalPoidsKg,
    required this.totalPoidsM3,
    required this.totalPrix,
    this.isAerien = true,
    this.totalNombre = 0,
  });

  Color get _accentColor =>
      isAerien ? AppTheme.accentAerien : AppTheme.accentMaritime;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0', 'fr');
    final weightFormat = NumberFormat('#,##0.######', 'fr');
    final hasKg = totalPoidsKg > 0;
    final hasM3 = totalPoidsM3 > 0;

    final gradientColors = isAerien
        ? <Color>[_accentColor, const Color(0xFF334155)]
        : <Color>[_accentColor, const Color(0xFF0891B2)];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStat(
              context,
              icon: Icons.inventory_2_rounded,
              value: totalNombre > 0 ? '$totalNombre' : '$totalColis',
              label: totalNombre > 0 ? 'articles' : 'colis',
              subLabel: subtitle,
            ),
            if (hasKg) ...[
              _buildDivider(),
              _buildStat(
                context,
                icon: Icons.scale_rounded,
                value: weightFormat.format(totalPoidsKg),
                label: 'KG',
              ),
            ],
            if (hasM3 || (!hasKg && !hasM3)) ...[
              _buildDivider(),
              _buildStat(
                context,
                icon: Icons.view_in_ar_rounded,
                value: weightFormat.format(totalPoidsM3),
                label: 'M3',
              ),
            ],
            _buildDivider(),
            _buildStat(
              context,
              icon: Icons.payments_rounded,
              value: numberFormat.format(totalPrix),
              label: 'Ar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    String? subLabel,
  }) {
    const onColor = Colors.white;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: onColor.withValues(alpha: 0.85), size: 22),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: onColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: onColor.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
          if (subLabel != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subLabel,
                style: TextStyle(
                  color: onColor.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
