import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:colis_manager/core/error/exceptions.dart';
import 'package:colis_manager/features/colis/data/models/colis_model.dart';

abstract class ColisLocalDatasource {
  Future<List<ColisModel>> getColisByTransport(String transportModeId);
  Future<List<ColisModel>> getColisByTransportPaginated(
    String transportModeId, {
    int limit = 20,
    int offset = 0,
  });
  Future<int> getColisCountByTransport(String transportModeId);
  Future<void> addColis(ColisModel model);
  Future<void> updateColis(ColisModel model);
  Future<void> updateColisStatus(String id, String status);
  Future<void> bulkUpdateColisStatus(List<String> ids, String status);
  Future<void> bulkUpdateDateArrivee(List<String> ids, DateTime? date);
  Future<void> deleteColis(String id);
}

class ColisLocalDatasourceImpl implements ColisLocalDatasource {
  final Database database;

  ColisLocalDatasourceImpl({required this.database});

  @override
  Future<List<ColisModel>> getColisByTransport(String transportModeId) async {
    try {
      final maps = await database.query(
        'colis',
        where: 'transport_mode_id = ?',
        whereArgs: [transportModeId],
        orderBy: 'date_ajout DESC',
      );
      return maps.map((map) => ColisModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors du chargement des colis: $e');
    }
  }

  @override
  Future<List<ColisModel>> getColisByTransportPaginated(
    String transportModeId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final maps = await database.query(
        'colis',
        where: 'transport_mode_id = ?',
        whereArgs: [transportModeId],
        orderBy: 'date_ajout DESC',
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => ColisModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors du chargement des colis: $e');
    }
  }

  @override
  Future<int> getColisCountByTransport(String transportModeId) async {
    try {
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM colis WHERE transport_mode_id = ?',
        [transportModeId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors du comptage des colis: $e');
    }
  }

  @override
  Future<void> addColis(ColisModel model) async {
    try {
      await database.insert(
        'colis',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors de l\'ajout du colis: $e');
    }
  }

  @override
  Future<void> updateColis(ColisModel model) async {
    try {
      await database.update(
        'colis',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      throw DatabaseException(
          message: 'Erreur lors de la mise à jour du colis: $e');
    }
  }

  @override
  Future<void> updateColisStatus(String id, String status) async {
    try {
      await database.update(
        'colis',
        {'statut': status},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException(
          message: 'Erreur lors de la mise à jour du statut: $e');
    }
  }

  @override
  Future<void> bulkUpdateColisStatus(List<String> ids, String status) async {
    try {
      final batch = database.batch();
      for (final id in ids) {
        batch.update(
          'colis',
          {'statut': status},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw DatabaseException(
          message: 'Erreur lors de la mise à jour en lot: $e');
    }
  }

  @override
  Future<void> bulkUpdateDateArrivee(List<String> ids, DateTime? date) async {
    try {
      final batch = database.batch();
      for (final id in ids) {
        batch.update(
          'colis',
          {'date_arrivee': date?.toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw DatabaseException(
          message: 'Erreur lors de la mise à jour de la date: $e');
    }
  }

  @override
  Future<void> deleteColis(String id) async {
    try {
      await database.delete(
        'colis',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException(message: 'Erreur lors de la suppression du colis: $e');
    }
  }
}
