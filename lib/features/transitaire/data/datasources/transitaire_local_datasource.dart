/// Local datasource for Transitaire using SQLite.
///
/// Implements CRUD operations against the transitaires table.
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:colis_manager/core/error/exceptions.dart';
import 'package:colis_manager/features/transitaire/data/models/transitaire_model.dart';

abstract class TransitaireLocalDatasource {
  Future<List<TransitaireModel>> getAllTransitaires();
  Future<TransitaireModel> getTransitaireById(String id);
  Future<void> addTransitaire(TransitaireModel model);
  Future<void> updateTransitaire(TransitaireModel model);
  Future<void> deleteTransitaire(String id);
}

class TransitaireLocalDatasourceImpl implements TransitaireLocalDatasource {
  final Database database;

  TransitaireLocalDatasourceImpl({required this.database});

  @override
  Future<List<TransitaireModel>> getAllTransitaires() async {
    try {
      final maps = await database.query(
        'transitaires',
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => TransitaireModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors du chargement des transitaires: $e');
    }
  }

  @override
  Future<TransitaireModel> getTransitaireById(String id) async {
    try {
      final maps = await database.query(
        'transitaires',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        throw const DatabaseException(message: 'Transitaire non trouvé');
      }
      return TransitaireModel.fromMap(maps.first);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(message: 'Erreur lors du chargement du transitaire: $e');
    }
  }

  @override
  Future<void> addTransitaire(TransitaireModel model) async {
    try {
      await database.insert(
        'transitaires',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors de l\'ajout du transitaire: $e');
    }
  }

  @override
  Future<void> updateTransitaire(TransitaireModel model) async {
    try {
      await database.update(
        'transitaires',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors de la mise à jour du transitaire: $e');
    }
  }

  @override
  Future<void> deleteTransitaire(String id) async {
    try {
      await database.delete(
        'transitaires',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors de la suppression du transitaire: $e');
    }
  }
}
