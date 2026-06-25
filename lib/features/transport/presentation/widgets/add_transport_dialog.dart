/// Dialog for adding/editing a transport mode.
///
/// Lets the user choose between Aérien and Maritime.
/// The unit is auto-determined: Aérien = KG, Maritime = M3.
/// In edit mode, the type is locked and only description can be changed.
import 'package:flutter/material.dart';
import 'package:colis_manager/core/theme/app_theme.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';

class AddTransportDialog extends StatefulWidget {
  final TransportMode? existingMode;

  const AddTransportDialog({super.key, this.existingMode});

  bool get isEditMode => existingMode != null;

  @override
  State<AddTransportDialog> createState() => _AddTransportDialogState();
}

class _AddTransportDialogState extends State<AddTransportDialog> {
  late TransportType _selectedType;
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _selectedType = widget.existingMode!.type;
      _descriptionController.text = widget.existingMode!.description ?? '';
    } else {
      _selectedType = TransportType.aerien;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              widget.isEditMode
                  ? 'Modifier le Mode de Transport'
                  : 'Nouveau Mode de Transport',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Type selector
            if (widget.isEditMode) ...[
              // Show locked type indicator in edit mode
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_selectedType == TransportType.aerien
                          ? AppTheme.accentAerien
                          : AppTheme.accentMaritime)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedType == TransportType.aerien
                        ? AppTheme.accentAerien
                        : AppTheme.accentMaritime,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedType == TransportType.aerien
                          ? Icons.flight_rounded
                          : Icons.directions_boat_rounded,
                      color: _selectedType == TransportType.aerien
                          ? AppTheme.accentAerien
                          : AppTheme.accentMaritime,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedType == TransportType.aerien
                          ? 'Aérien'
                          : 'Maritime',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selectedType == TransportType.aerien
                            ? AppTheme.accentAerien
                            : AppTheme.accentMaritime,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _TypeOption(
                      type: TransportType.aerien,
                      isSelected: _selectedType == TransportType.aerien,
                      onTap: () {
                        setState(() {
                          _selectedType = TransportType.aerien;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeOption(
                      type: TransportType.maritime,
                      isSelected: _selectedType == TransportType.maritime,
                      onTap: () {
                        setState(() {
                          _selectedType = TransportType.maritime;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedType == TransportType.aerien
                    ? AppTheme.accentAerien.withValues(alpha: 0.1)
                    : AppTheme.accentMaritime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedType == TransportType.aerien
                        ? Icons.flight_rounded
                        : Icons.directions_boat_rounded,
                    color: _selectedType == TransportType.aerien
                        ? AppTheme.accentAerien
                        : AppTheme.accentMaritime,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedType == TransportType.aerien
                        ? 'Aérien utilise le KG'
                        : 'Maritime utilise le M3',
                    style: TextStyle(
                      color: _selectedType == TransportType.aerien
                          ? AppTheme.accentAerien
                          : AppTheme.accentMaritime,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Ex: Vol régulier, Bateau mensuel...',
                prefixIcon: Icon(Icons.description_rounded),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 28),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'type': _selectedType,
                        'unite': _selectedType == TransportType.aerien ? 'KG' : 'M3',
                        'description': _descriptionController.text.trim().isEmpty
                            ? null
                            : _descriptionController.text.trim(),
                      });
                    },
                    child: Text(widget.isEditMode ? 'Modifier' : 'Ajouter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
     ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final TransportType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAerien = type == TransportType.aerien;
    final color = isAerien ? AppTheme.accentAerien : AppTheme.accentMaritime;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isAerien ? Icons.flight_rounded : Icons.directions_boat_rounded,
              color: isSelected
                  ? color
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey.shade400),
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              isAerien ? 'Aérien' : 'Maritime',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? color
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.grey.shade500),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
