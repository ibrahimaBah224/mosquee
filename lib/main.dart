import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/prayer/presentation/bloc/prayer_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/home/presentation/bloc/mosque_info_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DependencyInjection.init();
  runApp(const MosqueeApp());
}

class MosqueeApp extends StatelessWidget {
  const MosqueeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => getIt<AuthBloc>()),
        BlocProvider<PrayerBloc>(
          create: (context) => getIt<PrayerBloc>()..add(LoadPrayerTimes()),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => getIt<SettingsBloc>()..add(LoadSettings()),
        ),
        BlocProvider<MosqueInfoBloc>(
          create: (context) =>
              MosqueInfoBloc()..add(const MosqueInfoLoadRequested()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
