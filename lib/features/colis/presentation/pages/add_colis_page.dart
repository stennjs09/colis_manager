import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:colis_manager/core/theme/app_theme.dart';
import 'package:colis_manager/core/utils/image_cropper_util.dart';
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/entities/colis_status.dart';
import 'package:colis_manager/features/colis/domain/entities/unite_mesure.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_bloc.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_event.dart';
import 'package:colis_manager/features/colis/presentation/widgets/paste_text_dialog.dart';
import 'package:colis_manager/core/utils/text_parser_util.dart';
import 'package:path_provider/path_provider.dart';

class AddColisPage extends StatefulWidget {
  final TransportMode transportMode;
  final ColisBloc colisBloc;
  final Colis? existingColis;

  const AddColisPage({
    super.key,
    required this.transportMode,
    required this.colisBloc,
    this.existingColis,
  });

  bool get isEditMode => existingColis != null;

  @override
  State<AddColisPage> createState() => _AddColisPageState();
}

class _AddColisPageState extends State<AddColisPage> {
  final _formKey = GlobalKey<FormState>();
  final _trackingController = TextEditingController();
  final _poidsController = TextEditingController();
  final _prixController = TextEditingController();
  final _nombreController = TextEditingController();
  File? _selectedImage;
  final _imageCropperUtil = ImageCropperUtil();
  bool _isSaving = false;
  late String _selectedUnite;
  late ColisStatus _selectedStatus;
  DateTime? _dateArrivee;

  @override
  void initState() {
    super.initState();
    final isAerien = widget.transportMode.type == TransportType.aerien;
    _selectedUnite = isAerien ? 'KG' : 'M3';
    _selectedStatus = ColisStatus.enTransit;
    if (widget.isEditMode) {
      final colis = widget.existingColis!;
      _trackingController.text = colis.trackingNumber;
      _poidsController.text = colis.poids.toString();
      _prixController.text = colis.prixFret.toStringAsFixed(0);
      _selectedStatus = colis.statut;
      _dateArrivee = colis.dateArrivee;
      if (colis.nombre != null) {
        _nombreController.text = colis.nombre.toString();
      }
      if (colis.imagePath != null && colis.imagePath!.isNotEmpty) {
        final file = File(colis.imagePath!);
        if (file.existsSync()) {
          _selectedImage = file;
        }
      }
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _poidsController.dispose();
    _prixController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    final isAerien = widget.transportMode.type == TransportType.aerien;
    return isAerien ? AppTheme.accentAerien : AppTheme.accentMaritime;
  }

  Color _statusColor(ColisStatus status) {
    switch (status) {
      case ColisStatus.enTransit:
        return AppTheme.statusNonLivre;
      case ColisStatus.livre:
        return AppTheme.statusLivre;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAerien = widget.transportMode.type == TransportType.aerien;
    final accentColor = _accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Modifier le colis' : 'Nouveau colis'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _showPasteDialog,
              icon: Icon(Icons.content_paste_rounded, color: accentColor, size: 20),
              label: Text(
                'Coller',
                style: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                backgroundColor: accentColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(isAerien, accentColor),
              const SizedBox(height: 20),

              TextFormField(
                controller: _trackingController,
                decoration: const InputDecoration(
                  labelText: 'Tracking',
                  hintText: 'Ex: 465441716960265',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Requis';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Nbr on its own line
              _buildField(_nombreController, 'Nbr', '1', Icons.inventory_rounded, TextInputType.number),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildField(_poidsController, _selectedUnite == 'M3' ? 'Volume' : 'Poids', '0.00',
                      _selectedUnite == 'M3' ? Icons.view_in_ar_rounded : Icons.scale_rounded, const TextInputType.numberWithOptions(decimal: true),
                      suffix: _selectedUnite, isRequired: false)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_prixController, 'Fret', '0', Icons.payments_rounded, const TextInputType.numberWithOptions(decimal: true), isRequired: false)),
                ],
              ),
              const SizedBox(height: 16),

              _buildStatusSelector(),
              const SizedBox(height: 14),

              _buildDatePicker(accentColor),
              const SizedBox(height: 14),

              _buildPhotoSection(accentColor),
              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveColis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(widget.isEditMode ? 'Enregistrer' : 'Ajouter',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIconData(ColisStatus status) {
    final isAerien = widget.transportMode.type == TransportType.aerien;
    switch (status) {
      case ColisStatus.enTransit:
        return isAerien ? Icons.flight_rounded : Icons.directions_boat_rounded;
      case ColisStatus.livre:
        return Icons.check_circle_rounded;
    }
  }

  Future<void> _pickDateArrivee() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateArrivee ?? now,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      helpText: "Date d'arrivée",
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
    if (picked != null) {
      setState(() => _dateArrivee = picked);
    }
  }

  Widget _buildHeader(bool isAerien, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(isAerien ? Icons.flight_takeoff_rounded : Icons.directions_boat_rounded, color: accentColor, size: 18),
          const SizedBox(width: 10),
          Text(isAerien ? "Transport Aérien" : "Transport Maritime",
            style: TextStyle(color: accentColor, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, String hint, IconData icon, TextInputType keyboard, {String? suffix, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixText: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        floatingLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        labelStyle: const TextStyle(fontSize: 14),
        hintStyle: const TextStyle(fontSize: 14),
      ),
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          if (isRequired) return 'Requis';
          return null;
        }
        if (keyboard != TextInputType.number && keyboard != const TextInputType.numberWithOptions(decimal: true)) return null;
        if (double.tryParse(value.trim()) == null) return 'Invalide';
        return null;
      },
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statut', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 8),
        Row(
          children: ColisStatus.values.map((status) {
            final selected = _selectedStatus == status;
            final color = _statusColor(status);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedStatus = status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: 0.12) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? color : Colors.grey.shade300, width: selected ? 1.5 : 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_statusIconData(status), size: 14, color: selected ? color : Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(status.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: selected ? color : Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker(Color accentColor) {
    return InkWell(
      onTap: _pickDateArrivee,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: _dateArrivee != null ? accentColor : Colors.grey.shade500, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _dateArrivee != null ? DateFormat('dd/MM/yyyy').format(_dateArrivee!) : 'Date arrivée',
                style: TextStyle(fontSize: 14, color: _dateArrivee != null ? Colors.black87 : Colors.grey.shade500,
                  fontWeight: _dateArrivee != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (_dateArrivee != null)
              GestureDetector(
                onTap: () => setState(() => _dateArrivee = null),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 14, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(Color accentColor) {
    if (_selectedImage != null) {
      return Stack(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildImageButton(accentColor, Icons.camera_alt_rounded, 'Caméra', ImageSource.camera)),
        const SizedBox(width: 12),
        Expanded(child: _buildImageButton(accentColor, Icons.photo_library_rounded, 'Galerie', ImageSource.gallery)),
      ],
    );
  }

  Widget _buildImageButton(Color accentColor, IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () => _pickImage(source),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 26),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _showPasteDialog() async {
    final result = await showDialog<ParsedColisData>(
      context: context,
      builder: (_) => PasteTextDialog(expectedUnite: _selectedUnite),
    );

    if (result != null) {
      setState(() {
        if (result.trackingNumber != null) {
          _trackingController.text = result.trackingNumber!;
        }
        if (result.poids != null) {
          _poidsController.text = result.poids.toString();
        }
        if (result.prixFret != null) {
          _prixController.text = result.prixFret!.toStringAsFixed(0);
        }
      });
    }
  }

  int? _parseNombre() {
    final text = _nombreController.text.trim();
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) return null;
    return parsed;
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = source == ImageSource.camera
        ? await _imageCropperUtil.pickAndCropFromCamera(context)
        : await _imageCropperUtil.pickAndCropFromGallery(context);
    if (file != null) {
      final savedFile = await _saveImageLocally(file);
      setState(() => _selectedImage = savedFile);
    }
  }

  Future<File> _saveImageLocally(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final colisImagesDir = Directory('${appDir.path}/colis_images');
    if (!await colisImagesDir.exists()) {
      await colisImagesDir.create(recursive: true);
    }
    final fileName = '${const Uuid().v4()}.jpg';
    final savedFile = await file.copy('${colisImagesDir.path}/$fileName');
    return savedFile;
  }

  Future<void> _saveColis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    double _parseValue(String text) {
      return double.tryParse(text.trim()) ?? 0.0;
    }

    if (widget.isEditMode) {
      final updated = widget.existingColis!.copyWith(
        trackingNumber: _trackingController.text.trim(),
        poids: _parseValue(_poidsController.text),
        unite: UniteMesure.fromString(_selectedUnite),
        prixFret: _parseValue(_prixController.text),
        statut: _selectedStatus,
        imagePath: _selectedImage?.path,
        dateArrivee: _dateArrivee,
        nombre: _parseNombre(),
      );
      widget.colisBloc.add(UpdateColisEvent(colis: updated));
    } else {
      final colis = Colis(
        id: const Uuid().v4(),
        transportModeId: widget.transportMode.id,
        trackingNumber: _trackingController.text.trim(),
        poids: _parseValue(_poidsController.text),
        unite: UniteMesure.fromString(_selectedUnite),
        prixFret: _parseValue(_prixController.text),
        statut: _selectedStatus,
        imagePath: _selectedImage?.path,
        dateAjout: DateTime.now(),
        dateArrivee: _dateArrivee,
        nombre: _parseNombre(),
      );
      widget.colisBloc.add(AddColisEvent(colis: colis));
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }
}
