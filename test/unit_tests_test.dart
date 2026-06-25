import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:colis_manager/core/error/failures.dart';
import 'package:colis_manager/core/utils/text_parser_util.dart';
import 'package:colis_manager/features/colis/domain/entities/colis.dart';
import 'package:colis_manager/features/colis/domain/entities/colis_status.dart';
import 'package:colis_manager/features/colis/domain/entities/unite_mesure.dart';
import 'package:colis_manager/features/colis/domain/usecases/add_colis.dart';
import 'package:colis_manager/features/colis/domain/usecases/update_colis.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';
import 'package:colis_manager/features/colis/data/models/colis_model.dart';

class ColisRepositoryFake implements ColisRepository {
  @override
  Future<Either<Failure, List<Colis>>> getColisByTransport(
      String transportModeId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Colis>>> getColisByTransportPaginated(
    String transportModeId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, int>> getColisCountByTransport(
      String transportModeId) async {
    return const Right(0);
  }

  @override
  Future<Either<Failure, void>> addColis(Colis colis) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateColis(Colis colis) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateColisStatus(
      String id, String status) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> bulkUpdateColisStatus(
      List<String> ids, String status) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteColis(String id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> bulkUpdateDateArrivee(
      List<String> ids, DateTime? date) async {
    return const Right(null);
  }
}

void main() {
  late ColisRepositoryFake fakeRepo;
  late AddColis addColis;
  late UpdateColis updateColis;

  final validColis = Colis(
    id: '1',
    transportModeId: 'mode1',
    trackingNumber: 'TRACK123',
    poids: 10.5,
    unite: UniteMesure.kg,
    prixFret: 50000,
    statut: ColisStatus.enTransit,
    dateAjout: DateTime.now(),
    dateArrivee: null,
    nombre: null,
  );

  setUp(() {
    fakeRepo = ColisRepositoryFake();
    addColis = AddColis(fakeRepo);
    updateColis = UpdateColis(fakeRepo);
  });

  group('TextParserUtil', () {
    test('extrait tracking, poids et prix correctement', () {
      const text = '''
Estimation tracking n°:  465441716960265
Le poids de ce colis est: 0.5KG
Le prix du fret de ce colis est: 33750Ar
''';
      final result = TextParserUtil.parse(text);
      expect(result.isSuccess, true);
      expect(result.data!.trackingNumber, '465441716960265');
      expect(result.data!.poids, 0.5);
      expect(result.data!.unite, 'KG');
      expect(result.data!.prixFret, 33750);
    });

    test('retourne erreur si tracking absent', () {
      const text = '''
Le poids de ce colis est: 0.5KG
Le prix du fret de ce colis est: 33750Ar
''';
      final result = TextParserUtil.parse(text);
      expect(result.hasErrors, true);
      expect(result.errors.containsKey('tracking'), true);
    });

    test('accepte KG et M3 comme unités', () {
      const textKg = '''
Estimation tracking n°: 123456
Le poids de ce colis est: 1.5KG
Le prix du fret de ce colis est: 50000Ar
''';
      const textM3 = '''
Estimation tracking n°: 789012
Le volume de ce colis est: 2.0M3
Le prix du fret de ce colis est: 80000Ar
''';
      final resultKg = TextParserUtil.parse(textKg);
      final resultM3 = TextParserUtil.parse(textM3);
      expect(resultKg.data!.unite, 'KG');
      expect(resultM3.data!.unite, 'M3');
    });

    test('ignore les espaces supplémentaires', () {
      const text = '''
Estimation tracking  n°  :   465441716960265
Le poids  de ce colis est :  0.5  KG
Le prix  du fret de ce colis est :   33750  Ar
''';
      final result = TextParserUtil.parse(text);
      expect(result.data!.trackingNumber, '465441716960265');
      expect(result.data!.poids, 0.5);
      expect(result.data!.prixFret, 33750);
    });

    test('retourne erreur si poids absent', () {
      const text = '''
Estimation tracking n°: 123456
Le prix du fret de ce colis est: 50000Ar
''';
      final result = TextParserUtil.parse(text);
      expect(result.hasErrors, true);
      expect(result.errors.containsKey('poids'), true);
    });

    test('retourne erreur si prix absent', () {
      const text = '''
Estimation tracking n°: 123456
Le poids de ce colis est: 1.5KG
''';
      final result = TextParserUtil.parse(text);
      expect(result.hasErrors, true);
      expect(result.errors.containsKey('prix'), true);
    });

    test('parse avec succès si tous les champs présents même dans le désordre', () {
      const text = '''
Le prix du fret de ce colis est: 50000Ar
Estimation tracking n°: 123456
Le poids de ce colis est: 1.5KG
''';
      final result = TextParserUtil.parse(text);
      expect(result.isSuccess, true);
      expect(result.data!.trackingNumber, '123456');
    });
  });

  group('AddColis use case', () {
    test('valide le tracking non vide', () async {
      final invalid = validColis.copyWith(trackingNumber: '');
      final result = await addColis(AddColisParams(colis: invalid));
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Devrait échouer - tracking vide'),
      );
    });

    test('valide le poids >= 0', () async {
      final invalid = validColis.copyWith(poids: -1);
      final result = await addColis(AddColisParams(colis: invalid));
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Devrait échouer - poids négatif'),
      );
    });

    test('accepte poids = 0', () async {
      final zero = validColis.copyWith(poids: 0);
      final result = await addColis(AddColisParams(colis: zero));
      expect(result.isRight(), true);
    });

    test('valide le prix >= 0', () async {
      final invalid = validColis.copyWith(prixFret: -1);
      final result = await addColis(AddColisParams(colis: invalid));
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Devrait échouer - prix négatif'),
      );
    });

    test('accepte un colis valide', () async {
      final result = await addColis(AddColisParams(colis: validColis));
      expect(result.isRight(), true);
    });
  });

  group('UpdateColis use case', () {
    test('valide le tracking non vide', () async {
      final invalid = validColis.copyWith(trackingNumber: '');
      final result = await updateColis(UpdateColisParams(colis: invalid));
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Devrait échouer - tracking vide'),
      );
    });

    test('valide le poids >= 0', () async {
      final invalid = validColis.copyWith(poids: -1);
      final result = await updateColis(UpdateColisParams(colis: invalid));
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Devrait échouer - poids négatif'),
      );
    });

    test('accepte poids = 0', () async {
      final zero = validColis.copyWith(poids: 0);
      final result = await updateColis(UpdateColisParams(colis: zero));
      expect(result.isRight(), true);
    });

    test('valide le prix >= 0', () async {
      final invalid = validColis.copyWith(prixFret: -1);
      final result = await updateColis(UpdateColisParams(colis: invalid));
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Devrait échouer - prix négatif'),
      );
    });

    test('accepte un colis valide', () async {
      final result =
          await updateColis(UpdateColisParams(colis: validColis));
      expect(result.isRight(), true);
    });
  });

  group('Colis entity', () {
    test('isValid retourne true pour colis valide', () {
      expect(validColis.isValid, true);
    });

    test('isValid retourne false si tracking vide', () {
      expect(validColis.copyWith(trackingNumber: '').isValid, false);
    });

    test('isValid retourne true si poids = 0', () {
      expect(validColis.copyWith(poids: 0).isValid, true);
    });

    test('isValid retourne false si poids < 0', () {
      expect(validColis.copyWith(poids: -1).isValid, false);
    });

    test('isValid retourne false si prix < 0', () {
      expect(validColis.copyWith(prixFret: -1).isValid, false);
    });

    test('isLivre retourne true si statut livre', () {
      final livre = validColis.copyWith(statut: ColisStatus.livre);
      expect(livre.isLivre, true);
    });

    test('isLivre retourne false si statut non livre', () {
      expect(validColis.isLivre, false);
    });

    test('isNonLivre retourne true si statut non livre', () {
      expect(validColis.isNonLivre, true);
    });

    test('isNonLivre retourne false si statut livre', () {
      final livre = validColis.copyWith(statut: ColisStatus.livre);
      expect(livre.isNonLivre, false);
    });

    test('copyWith préserve les champs non modifiés', () {
      final modified = validColis.copyWith(trackingNumber: 'NEW123');
      expect(modified.trackingNumber, 'NEW123');
      expect(modified.poids, validColis.poids);
      expect(modified.prixFret, validColis.prixFret);
      expect(modified.id, validColis.id);
    });
  });

  group('UniteMesure', () {
    test('fromString retourne kg pour "kg"', () {
      expect(UniteMesure.fromString('kg'), UniteMesure.kg);
    });

    test('fromString retourne m3 pour "m3"', () {
      expect(UniteMesure.fromString('m3'), UniteMesure.m3);
    });

    test('fromString retourne kg par défaut', () {
      expect(UniteMesure.fromString('unknown'), UniteMesure.kg);
    });

    test('label retourne KG pour kg', () {
      expect(UniteMesure.kg.label, 'KG');
    });

    test('label retourne M3 pour m3', () {
      expect(UniteMesure.m3.label, 'M3');
    });

    test('value retourne "kg" pour kg', () {
      expect(UniteMesure.kg.value, 'kg');
    });

    test('value retourne "m3" pour m3', () {
      expect(UniteMesure.m3.value, 'm3');
    });
  });

  group('ColisStatus', () {
    test('fromString retourne enTransit pour "en_transit"', () {
      expect(ColisStatus.fromString('en_transit'), ColisStatus.enTransit);
    });

    test('fromString retourne livre pour "livre"', () {
      expect(ColisStatus.fromString('livre'), ColisStatus.livre);
    });

    test('fromString retourne enTransit par défaut', () {
      expect(ColisStatus.fromString('unknown'), ColisStatus.enTransit);
    });

    test('value retourne "en_transit" pour enTransit', () {
      expect(ColisStatus.enTransit.value, 'en_transit');
    });

    test('value retourne "livre" pour livre', () {
      expect(ColisStatus.livre.value, 'livre');
    });

    test('label retourne "En transit" pour enTransit', () {
      expect(ColisStatus.enTransit.label, 'En transit');
    });

    test('label retourne "Livré" pour livre', () {
      expect(ColisStatus.livre.label, 'Livré');
    });

    test('isNonLivre retourne true pour enTransit', () {
      expect(ColisStatus.enTransit.isNonLivre, true);
    });

    test('isNonLivre retourne false pour livre', () {
      expect(ColisStatus.livre.isNonLivre, false);
    });
  });

  group('ColisModel serialization', () {
    test('toMap/fromMap avec nombre null', () {
      final model = ColisModel(
        id: '1',
        transportModeId: 'mode1',
        trackingNumber: 'TRACK123',
        poids: 10.5,
        unite: UniteMesure.kg,
        prixFret: 50000,
        statut: ColisStatus.enTransit,
        dateAjout: DateTime(2024, 1, 1),
        dateArrivee: null,
        nombre: null,
      );
      final map = model.toMap();
      final restored = ColisModel.fromMap(map);
      expect(restored.id, model.id);
      expect(restored.nombre, null);
    });

    test('toMap/fromMap avec nombre non-null', () {
      final model = ColisModel(
        id: '2',
        transportModeId: 'mode1',
        trackingNumber: 'TRACK456',
        poids: 5.0,
        unite: UniteMesure.kg,
        prixFret: 25000,
        statut: ColisStatus.enTransit,
        dateAjout: DateTime(2024, 1, 1),
        dateArrivee: null,
        nombre: 5,
      );
      final map = model.toMap();
      expect(map['nombre'], 5);
      final restored = ColisModel.fromMap(map);
      expect(restored.nombre, 5);
    });

    test('fromEntity préserve nombre', () {
      final colis = validColis.copyWith(nombre: 3);
      final model = ColisModel.fromEntity(colis);
      expect(model.nombre, 3);
    });
  });

  group('Failure types', () {
    test('ServerFailure a un message', () {
      const failure = ServerFailure(message: 'Erreur serveur');
      expect(failure.message, 'Erreur serveur');
    });

    test('CacheFailure a un message', () {
      const failure = CacheFailure(message: 'Erreur cache');
      expect(failure.message, 'Erreur cache');
    });

    test('ValidationFailure a un message', () {
      const failure = ValidationFailure(message: 'Erreur validation');
      expect(failure.message, 'Erreur validation');
    });

    test('DatabaseFailure a un message', () {
      const failure = DatabaseFailure(message: 'Erreur DB');
      expect(failure.message, 'Erreur DB');
    });

    test('Failure equality works', () {
      const a = ValidationFailure(message: 'test');
      const b = ValidationFailure(message: 'test');
      const c = ValidationFailure(message: 'other');
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
