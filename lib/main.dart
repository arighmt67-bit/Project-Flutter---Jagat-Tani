import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'provider/padi_classifier_provider.dart';
import 'provider/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = PadiClassifierProvider();
            provider.initModel();
            return provider;
          },
        ),
      ],
      child: const JagatTaniApp(),
    ),
  );
}

class JagatTaniApp extends StatelessWidget {
  const JagatTaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jagat Tani',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        fontFamily:
            'PlusJakartaSans', // boleh dihapus kalau belum pakai font ini
      ),
      home: const HomeScreen(),
    );
  }
}
