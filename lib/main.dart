import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/app_localizations.dart';
import 'services/business_card_service.dart';
import 'providers/card_provider.dart';
import 'providers/language_provider.dart';
import 'screens/home_screen.dart';
import 'screens/card_preview_screen.dart';
import 'models/business_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hiveの初期化
  await BusinessCardService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CardProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Quick Card',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ja', 'JP'),
              Locale('en', 'US'),
            ],
            home: const _RootScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: context.read<CardProvider>().loadCards(),
      builder: (context, snapshot) {
        final provider = context.watch<CardProvider>();
        final existing = provider.currentCard;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (existing != null) {
          return CardPreviewScreen(card: existing, showQRCodeInitially: false);
        }
        return const HomeScreen();
      },
    );
  }
}
