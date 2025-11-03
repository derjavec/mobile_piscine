import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Si ya hay una instancia, no volver a inicializar
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDRAjmaxtl-tnurUQI9629CIL3iAGLuzBQ",
          authDomain: "diary-app-ded13.firebaseapp.com",
          projectId: "diary-app-ded13",
          messagingSenderId: "524351846273",
          appId: "1:524351846273:web:7f78384b8cedf6bf745a80",
        ),
      );
      print("✅ Firebase inicializado");
    } else {
      print("⚠️ Firebase ya estaba inicializado");
    }
  } catch (e) {
    print("Firebase init error: $e");
  }

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diary App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => LoginPage(),
      },
    );
}
}
