import 'package:fitman_app/screens/auth_wrapper.dart';
import 'package:fitman_app/utils/my_custom_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitman_app/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "packages/fitman_app/.env");
  await initializeDateFormatting('ru', null);
  await ApiService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitman MVP2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 16.0),
          titleMedium: TextStyle(fontSize: 14.0),
          labelLarge: TextStyle(fontSize: 14.0),
        ),
      ),
      scrollBehavior: MyCustomScrollBehavior(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', ''), // Russian
      ],
      home: AuthWrapper(), // Используем AuthWrapper как главный экран
    );
  }
}