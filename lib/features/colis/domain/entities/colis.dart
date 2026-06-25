import 'package:equatable/equatable.dart';
import 'package:colis_manager/features/colis/domain/entities/colis_status.dart';
import 'package:colis_manager/features/colis/domain/entities/unite_mesure.dart';

class Colis extends Equatable {
  final String id;
  final String transportModeId;
  final String trackingNumber;
  final double poids;
  final UniteMesure unite;
  final double prixFret;
  final ColisStatus statut;
  final String? imagePath;
  final DateTime dateAjout;
  final DateTime? dateArrivee;
  final int? nombre;

  const Colis({
    required this.id,
    required this.transportModeId,
    required this.trackingNumber,
    required this.poids,
    required this.unite,
    required this.prixFret,
    required this.statut,
    this.imagePath,
    required this.dateAjout,
    this.dateArrivee,
    this.nombre,
  });

  bool get isValid => poids > 0 && prixFret >= 0 && trackingNumber.isNotEmpty;

  bool get isLivre => statut == ColisStatus.livre;

  bool get isNonLivre => statut != ColisStatus.livre;

  Colis copyWith({
    String? id,
    String? transportModeId,
    String? trackingNumber,
    double? poids,
    UniteMesure? unite,
    double? prixFret,
    ColisStatus? statut,
    String? imagePath,
    DateTime? dateAjout,
    DateTime? dateArrivee,
    int? nombre,
  }) {
    return Colis(
      id: id ?? this.id,
      transportModeId: transportModeId ?? this.transportModeId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      poids: poids ?? this.poids,
      unite: unite ?? this.unite,
      prixFret: prixFret ?? this.prixFret,
      statut: statut ?? this.statut,
      imagePath: imagePath ?? this.imagePath,
      dateAjout: dateAjout ?? this.dateAjout,
      dateArrivee: dateArrivee ?? this.dateArrivee,
      nombre: nombre ?? this.nombre,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transportModeId,
        trackingNumber,
        poids,
        unite,
        prixFret,
        statut,
        imagePath,
        dateAjout,
        dateArrivee,
        nombre,
      ];
}
