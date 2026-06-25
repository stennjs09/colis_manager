/// Data model for TransportMode.
///
/// Extends the domain entity and adds serialization.
import 'package:colis_manager/features/transport/domain/entities/transport_mode.dart';

class TransportModeModel extends TransportMode {
  const TransportModeModel({
    required super.id,
    required super.transitaireId,
    required super.type,
    super.description,
    required super.unite,
  });

  factory TransportModeModel.fromMap(Map<String, dynamic> map) {
    return TransportModeModel(
      id: map['id'] as String,
      transitaireId: map['transitaire_id'] as String,
      type: map['type'] == 'aerien' ? TransportType.aerien : TransportType.maritime,
      description: map['description'] as String?,
      unite: (map['unite'] as String? ?? 'kg').toUpperCase(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transitaire_id': transitaireId,
      'type': type == TransportType.aerien ? 'aerien' : 'maritime',
      'description': description,
      'unite': unite.toLowerCase(),
    };
  }

  factory TransportModeModel.fromEntity(TransportMode entity) {
    return TransportModeModel(
      id: entity.id,
      transitaireId: entity.transitaireId,
      type: entity.type,
      description: entity.description,
      unite: entity.unite,
    );
  }
}
