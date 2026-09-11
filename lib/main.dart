import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Aapki Firebase config file
import 'screens/admin_dashboard.dart'; // Dashboard wali file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web, // Firebase connect ho raha hai
  );
  runApp(const CopystarCRMApp());
}

class CopystarCRMApp extends StatelessWidget {
  const CopystarCRMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copystar CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF63D392),
          surface: Color(0xFF121212),
        ),
      ),
      home: const AdminDashboard(), // Yahan se aapka CRM start hoga
    );
  }
}