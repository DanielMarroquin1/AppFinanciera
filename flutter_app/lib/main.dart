import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/color_palette_provider.dart';
import 'presentation/widgets/common/session_timeout_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es');

  final sharedPreferences = await SharedPreferences.getInstance();

  final hasSeenOnboarding = sharedPreferences.getBool('has_seen_onboarding') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final _router = AppRouter.createRouter(widget.hasSeenOnboarding);

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final palette = ref.watch(colorPaletteProvider);

    final lightTheme = AppTheme.lightTheme.copyWith(
      primaryColor: palette.colors[0],
      colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
        primary: palette.colors[0],
        secondary: palette.colors[1],
        tertiary: palette.colors[2],
      ),
    );

    final darkTheme = AppTheme.darkTheme.copyWith(
      primaryColor: palette.colors[0],
      colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
        primary: palette.colors[0],
        secondary: palette.colors[1],
        tertiary: palette.colors[2],
      ),
    );

    return MaterialApp.router(
      title: 'App Financiera',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return SessionTimeoutManager(child: child!);
      },
    );
  }
}
