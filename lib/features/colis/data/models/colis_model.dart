import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/entities/colis_status.dart';
import 'package:colis_manager/features/colis/domain/entities/unite_mesure.dart';

class ColisModel extends Colis {
  const ColisModel({
    required super.id,
    required super.transportModeId,
    required super.trackingNumber,
    required super.poids,
    required super.unite,
    required super.prixFret,
    required super.statut,
    super.imagePath,
    required super.dateAjout,
    super.dateArrivee,
    super.nombre,
  });

  factory ColisModel.fromMap(Map<String, dynamic> map) {
    return ColisModel(
      id: map['id'] as String,
      transportModeId: map['transport_mode_id'] as String,
      trackingNumber: map['tracking_number'] as String,
      poids: (map['poids'] as num).toDouble(),
      unite: UniteMesure.fromString(map['unite'] as String),
      prixFret: (map['prix_fret'] as num).toDouble(),
      statut: ColisStatus.fromString(map['statut'] as String),
      imagePath: map['image_path'] as String?,
      dateAjout: DateTime.parse(map['date_ajout'] as String),
      dateArrivee: map['date_arrivee'] != null
          ? DateTime.parse(map['date_arrivee'] as String)
          : null,
      nombre: map['nombre'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transport_mode_id': transportModeId,
      'tracking_number': trackingNumber,
      'poids': poids,
      'unite': unite.value,
      'prix_fret': prixFret,
      'statut': statut.value,
      'image_path': imagePath,
      'date_ajout': dateAjout.toIso8601String(),
      'date_arrivee': dateArrivee?.toIso8601String(),
      'nombre': nombre,
    };
  }

  factory ColisModel.fromEntity(Colis entity) {
    return ColisModel(
      id: entity.id,
      transportModeId: entity.transportModeId,
      trackingNumber: entity.trackingNumber,
      poids: entity.poids,
      unite: entity.unite,
      prixFret: entity.prixFret,
      statut: entity.statut,
      imagePath: entity.imagePath,
      dateAjout: entity.dateAjout,
      dateArrivee: entity.dateArrivee,
      nombre: entity.nombre,
    );
  }
}
