/// Local datasource for Transport modes using SQLite.
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:colis_manager/core/error/exceptions.dart';
import 'package:colis_manager/features/transport/data/models/transport_mode_model.dart';

abstract class TransportLocalDatasource {
  Future<List<TransportModeModel>> getTransportModesByTransitaire(String transitaireId);
  Future<TransportModeModel> getTransportModeById(String id);
  Future<void> addTransportMode(TransportModeModel model);
  Future<void> updateTransportMode(TransportModeModel model);
  Future<void> deleteTransportMode(String id);
}

class TransportLocalDatasourceImpl implements TransportLocalDatasource {
  final Database database;

  TransportLocalDatasourceImpl({required this.database});

  @override
  Future<List<TransportModeModel>> getTransportModesByTransitaire(
      String transitaireId) async {
    try {
      final maps = await database.query(
        'transport_modes',
        where: 'transitaire_id = ?',
        whereArgs: [transitaireId],
      );
      return maps.map((map) => TransportModeModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
          message: 'Erreur lors du chargement des modes de transport: $e');
    }
  }

  @override
  Future<TransportModeModel> getTransportModeById(String id) async {
    try {
      final maps = await database.query(
        'transport_modes',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        throw const DatabaseException(message: 'Mode de transport non trouvé');
      }
      return TransportModeModel.fromMap(maps.first);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
          message: 'Erreur lors du chargement du mode de transport: $e');
    }
  }

  @override
  Future<void> addTransportMode(TransportModeModel model) async {
    try {
      await database.insert(
        'transport_modes',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException(
          message: 'Erreur lors de l\'ajout du mode de transport: $e');
    }
  }

  @override
  Future<void> updateTransportMode(TransportModeModel model) async {
    try {
      await database.update(
        'transport_modes',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      throw DatabaseException(
          message: 'Erreur lors de la mise à jour du mode de transport: $e');
    }
  }

  @override
  Future<void> deleteTransportMode(String id) async {
    try {
      await database.delete(
        'transport_modes',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException(
          message: 'Erreur lors de la suppression du mode de transport: $e');
    }
  }
}
