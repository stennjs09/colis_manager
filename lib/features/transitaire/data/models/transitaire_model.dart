/// Data model for Transitaire.
///
/// Extends the domain entity and adds serialization (fromMap/toMap)
/// for SQLite storage.
import 'package:colis_manager/features/transitaire/domain/entities/transitaire.dart';

class TransitaireModel extends Transitaire {
  const TransitaireModel({
    required super.id,
    required super.nom,
    super.logoPath,
    required super.createdAt,
  });

  /// Create a TransitaireModel from a database map.
  factory TransitaireModel.fromMap(Map<String, dynamic> map) {
    return TransitaireModel(
      id: map['id'] as String,
      nom: map['nom'] as String,
      logoPath: map['logo_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'logo_path': logoPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a TransitaireModel from a domain entity.
  factory TransitaireModel.fromEntity(Transitaire entity) {
    return TransitaireModel(
      id: entity.id,
      nom: entity.nom,
      logoPath: entity.logoPath,
      createdAt: entity.createdAt,
    );
  }
}
