/// Dependency injection container using GetIt.
///
/// Registers all datasources, repositories, use cases, and blocs.
/// Nothing is instantiated directly in widgets — everything goes through GetIt.
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:colis_manager/core/database/database_helper.dart';

// Transitaire
import 'package:colis_manager/features/transitaire/data/datasources/transitaire_local_datasource.dart';
import 'package:colis_manager/features/transitaire/data/repositories/transitaire_repository_impl.dart';
import 'package:colis_manager/features/transitaire/domain/repositories/transitaire_repository.dart';
import 'package:colis_manager/features/transitaire/domain/usecases/add_transitaire.dart';
import 'package:colis_manager/features/transitaire/domain/usecases/get_all_transitaires.dart';
import 'package:colis_manager/features/transitaire/domain/usecases/delete_transitaire.dart';
import 'package:colis_manager/features/transitaire/domain/usecases/update_transitaire.dart';
import 'package:colis_manager/features/transitaire/presentation/bloc/transitaire_bloc.dart';

// Transport
import 'package:colis_manager/features/transport/data/datasources/transport_local_datasource.dart';
import 'package:colis_manager/features/transport/data/repositories/transport_repository_impl.dart';
import 'package:colis_manager/features/transport/domain/repositories/transport_repository.dart';
import 'package:colis_manager/features/transport/domain/usecases/add_transport_mode.dart';
import 'package:colis_manager/features/transport/domain/usecases/get_transport_modes_by_transitaire.dart';
import 'package:colis_manager/features/transport/domain/usecases/delete_transport_mode.dart';
import 'package:colis_manager/features/transport/domain/usecases/update_transport_mode.dart';
import 'package:colis_manager/features/transport/presentation/bloc/transport_bloc.dart';

// Colis
import 'package:colis_manager/features/colis/data/datasources/colis_local_datasource.dart';
import 'package:colis_manager/features/colis/data/repositories/colis_repository_impl.dart';
import 'package:colis_manager/features/colis/domain/repositories/colis_repository.dart';
import 'package:colis_manager/features/colis/domain/usecases/add_colis.dart';
import 'package:colis_manager/features/colis/domain/usecases/get_colis_by_transport.dart';
import 'package:colis_manager/features/colis/domain/usecases/get_colis_by_transport_paginated.dart';
import 'package:colis_manager/features/colis/domain/usecases/get_colis_count.dart';
import 'package:colis_manager/features/colis/domain/usecases/update_colis_status.dart';
import 'package:colis_manager/features/colis/domain/usecases/update_colis.dart';
import 'package:colis_manager/features/colis/domain/usecases/bulk_update_colis_status.dart';
import 'package:colis_manager/features/colis/domain/usecases/delete_colis.dart';
import 'package:colis_manager/features/colis/presentation/bloc/colis_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ══════════════════════════════════════════════════════════
  // DATABASE
  // ══════════════════════════════════════════════════════════
  final database = await DatabaseHelper.database;
  sl.registerLazySingleton<Database>(() => database);

  // ══════════════════════════════════════════════════════════
  // FEATURE: TRANSITAIRE
  // ══════════════════════════════════════════════════════════

  // Bloc — factory because each screen gets a new instance
  sl.registerFactory(
    () => TransitaireBloc(
      getAllTransitaires: sl(),
      addTransitaire: sl(),
      deleteTransitaire: sl(),
      updateTransitaire: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllTransitaires(sl()));
  sl.registerLazySingleton(() => AddTransitaire(sl()));
  sl.registerLazySingleton(() => DeleteTransitaire(sl()));
  sl.registerLazySingleton(() => UpdateTransitaire(sl()));

  // Repository
  sl.registerLazySingleton<TransitaireRepository>(
    () => TransitaireRepositoryImpl(localDatasource: sl()),
  );

  // Datasource
  sl.registerLazySingleton<TransitaireLocalDatasource>(
    () => TransitaireLocalDatasourceImpl(database: sl()),
  );

  // ══════════════════════════════════════════════════════════
  // FEATURE: TRANSPORT MODE
  // ══════════════════════════════════════════════════════════

  sl.registerFactory(
    () => TransportBloc(
      getTransportModesByTransitaire: sl(),
      addTransportMode: sl(),
      updateTransportMode: sl(),
      deleteTransportMode: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetTransportModesByTransitaire(sl()));
  sl.registerLazySingleton(() => AddTransportMode(sl()));
  sl.registerLazySingleton(() => UpdateTransportMode(sl()));
  sl.registerLazySingleton(() => DeleteTransportMode(sl()));

  sl.registerLazySingleton<TransportRepository>(
    () => TransportRepositoryImpl(localDatasource: sl()),
  );

  sl.registerLazySingleton<TransportLocalDatasource>(
    () => TransportLocalDatasourceImpl(database: sl()),
  );

  // ══════════════════════════════════════════════════════════
  // FEATURE: COLIS
  // ══════════════════════════════════════════════════════════

  sl.registerFactory(
    () => ColisBloc(
      getColisByTransport: sl(),
      getColisByTransportPaginated: sl(),
      getColisCount: sl(),
      addColis: sl(),
      updateColis: sl(),
      updateColisStatus: sl(),
      bulkUpdateColisStatus: sl(),
      colisRepository: sl(),
      deleteColis: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetColisByTransport(sl()));
  sl.registerLazySingleton(() => GetColisByTransportPaginated(sl()));
  sl.registerLazySingleton(() => GetColisCount(sl()));
  sl.registerLazySingleton(() => AddColis(sl()));
  sl.registerLazySingleton(() => UpdateColis(sl()));
  sl.registerLazySingleton(() => UpdateColisStatus(sl()));
  sl.registerLazySingleton(() => BulkUpdateColisStatus(sl()));
  sl.registerLazySingleton(() => DeleteColis(sl()));

  sl.registerLazySingleton<ColisRepository>(
    () => ColisRepositoryImpl(localDatasource: sl()),
  );

  sl.registerLazySingleton<ColisLocalDatasource>(
    () => ColisLocalDatasourceImpl(database: sl()),
  );
}
