import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'profile_page.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) 'dart:io';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert';




class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

Future<UserCredential?> signInWithGoogle() async {
  if (kIsWeb) {
    final GoogleAuthProvider provider = GoogleAuthProvider();
    provider.addScope('email');
    return await FirebaseAuth.instance.signInWithPopup(provider);
  } else {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      clientId: null,
      serverClientId: '524351846273-bhh4ti51ovqat60n7gm0ldrutgi2qmoj.apps.googleusercontent.com',
    );
    try {
      final GoogleSignInAccount? account = await googleSignIn.authenticate();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error login Google: $e");
      return null;
    }
  }
}


  Future<UserCredential?> signInWithGitHub() async {
  final firebaseAuth = FirebaseAuth.instance;

  // Configurar proveedor de GitHub
  final githubProvider = GithubAuthProvider();
  githubProvider.addScope('read:user');
  githubProvider.addScope('user:email');

  try {
    UserCredential userCredential;

    if (kIsWeb) {
      // 🌐 WEB
      userCredential = await firebaseAuth.signInWithPopup(githubProvider);
    } else {
      // 📱 ANDROID / IOS
      userCredential = await firebaseAuth.signInWithProvider(githubProvider);
    }

    print('✅ Login GitHub exitoso');
    return userCredential;

  } on FirebaseAuthException catch (e) {
    // ⚠️ Si ya existe una cuenta con el mismo email
    if (e.code == 'account-exists-with-different-credential') {
      final email = e.email;
      final pendingCred = e.credential;
      print('⚠️ Cuenta existente para $email. Intentando login automático con Google...');

      if (email != null) {
        try {
          final googleProvider = GoogleAuthProvider();

          // Login automático con Google (funciona en web y mobile)
          UserCredential googleUser;
          if (kIsWeb) {
            googleUser = await firebaseAuth.signInWithPopup(googleProvider);
          } else {
            googleUser = await firebaseAuth.signInWithProvider(googleProvider);
          }

          // Vincular GitHub a la cuenta Google existente
          if (pendingCred != null) {
            await googleUser.user?.linkWithCredential(pendingCred);
            print('✅ Cuenta de GitHub vinculada correctamente a Google.');
          }

          return googleUser;
        } catch (e2) {
          print('❌ Falló el login automático con Google: $e2');
          return null;
        }
      }
      return null;
    } else {
      print("Error login GitHub: $e");
      return null;
    }
  } catch (e) {
    print("Error inesperado login GitHub: $e");
    return null;
  }
}




  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      Future.microtask(() => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ProfilePage())));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children:[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Diary App",
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                SignInButton(
                  Buttons.Google,
                  onPressed: () async {
                    await signInWithGoogle();
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),

                SignInButton(
                  Buttons.GitHub,
                  onPressed: () async {
                    await signInWithGitHub();
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
       ],
      ),
    );
  }
}
       

            

