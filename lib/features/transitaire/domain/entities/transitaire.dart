/// Transitaire domain entity.
///
/// Pure domain object with no external dependencies.
/// Represents a freight forwarding agent.
import 'package:equatable/equatable.dart';

class Transitaire extends Equatable {
  final String id;
  final String nom;
  final String? logoPath;
  final DateTime createdAt;

  const Transitaire({
    required this.id,
    required this.nom,
    this.logoPath,
    required this.createdAt,
  });

  /// Business rule: nom must not be empty.
  bool get isValid => nom.trim().isNotEmpty;

  Transitaire copyWith({
    String? id,
    String? nom,
    String? logoPath,
    DateTime? createdAt,
  }) {
    return Transitaire(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      logoPath: logoPath ?? this.logoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, nom, logoPath, createdAt];
}
