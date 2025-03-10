import 'package:bloood_donation_app/features/auth/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/providers/donor.dart';
import 'core/providers/receiver.dart';
import 'core/providers/request.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(
            create: (_) => DonorProvider()), // ✅ Added Provider
        ChangeNotifierProvider(
            create: (_) => ReceiverProvider()), // ✅ Added Provider
        // ✅ Added Provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation App',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const SplashScreen(), // Splash Screen is the first screen
    );
  }
}
