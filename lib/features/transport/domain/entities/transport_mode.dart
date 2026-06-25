/// Transport mode domain entity.
///
/// Represents a transport mode (aerial or maritime) for a transitaire.
import 'package:equatable/equatable.dart';

enum TransportType { aerien, maritime }

class TransportMode extends Equatable {
  final String id;
  final String transitaireId;
  final TransportType type;
  final String? description;
  final String unite; // 'KG' or 'M3' for aerien, 'M3' only for maritime

  const TransportMode({
    required this.id,
    required this.transitaireId,
    required this.type,
    this.description,
    required this.unite,
  });

  /// Maritime mode always uses M3.
  bool get isValid {
    if (type == TransportType.maritime && unite.toUpperCase() != 'M3') {
      return false;
    }
    return true;
  }

  String get typeLabel =>
      type == TransportType.aerien ? 'Aérien' : 'Maritime';

  TransportMode copyWith({
    String? id,
    String? transitaireId,
    TransportType? type,
    String? description,
    String? unite,
  }) {
    return TransportMode(
      id: id ?? this.id,
      transitaireId: transitaireId ?? this.transitaireId,
      type: type ?? this.type,
      description: description ?? this.description,
      unite: unite ?? this.unite,
    );
  }

  @override
  List<Object?> get props => [id, transitaireId, type, description, unite];
}
