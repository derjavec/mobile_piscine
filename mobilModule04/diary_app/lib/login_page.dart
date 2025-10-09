import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'diary_page.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) 'dart:io';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';



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
      // inicia el login
      final GoogleSignInAccount? account = await googleSignIn.authenticate();
      if (account == null) return null; // usuario canceló login

      // obtenemos el token de autenticación
      final GoogleSignInAuthentication auth = account.authentication;

      // creamos credencial Firebase
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken, // solo idToken es suficiente
      );

      // login con Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error login Google: $e");
      return null;
    }
  }
}


  Future<void> signInWithGitHubWeb() async {
      try {
        final githubProvider = GithubAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(githubProvider);

        print("¡Login exitoso con GitHub!");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          final email = e.email!;
          print("Email recibido: ${email}");
          final pendingCredential = e.credential;
          // final List<String> signInMethods = await FirebaseAuth.instance
          //     .fetchSignInMethodsForEmail(email);
          // print(signInMethods);

          try {
            final googleProvider = GoogleAuthProvider();
            final googleUser = await FirebaseAuth.instance.signInWithPopup(googleProvider);

            await googleUser.user?.linkWithCredential(pendingCredential!);

            print("✅ Cuenta de GitHub vinculada con Google correctamente");
          } catch (linkError) {
            print("❌ Error vinculando credenciales: $linkError");
          }
        } else {
          print('Error en GitHub login: $e');
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      Future.microtask(() => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DiaryPage())));
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
                        MaterialPageRoute(builder: (_) => const DiaryPage()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),

                SignInButton(
                  Buttons.GitHub,
                  onPressed: () async {
                    await signInWithGitHubWeb();
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DiaryPage()),
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
       

            

