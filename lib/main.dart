import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:colis_manager/core/theme/app_theme.dart';
import 'package:colis_manager/injection_container.dart' as di;
import 'package:colis_manager/features/transitaire/presentation/bloc/transitaire_bloc.dart';
import 'package:colis_manager/features/transitaire/presentation/pages/transitaire_list_page.dart';
import 'package:colis_manager/core/widgets/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  final onboardingDone = await OnboardingPage.isOnboardingDone();

  runApp(ColisManagerApp(showOnboarding: !onboardingDone));
}

class ColisManagerApp extends StatelessWidget {
  final bool showOnboarding;

  const ColisManagerApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransitaireBloc>(
          create: (_) => GetIt.I<TransitaireBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Colis Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: showOnboarding
            ? OnboardingPage(home: const TransitaireListPage())
            : const TransitaireListPage(),
      ),
    );
  }
}
