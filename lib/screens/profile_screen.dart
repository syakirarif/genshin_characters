import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genshin_characters/screens/user_info_screen.dart';
import 'package:genshin_characters/widgets/google_sign_in_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.data == null) {
            return _widgetLogin();
          } else {
            User? user = FirebaseAuth.instance.currentUser;
            return UserInfoScreen(user: user!);
          }
        },
      ),
    );
  }

  Widget _widgetLogin() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              isLoggedIn
                  ? 'You are logged in'
                  : 'Login to save your redemption history.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            const SizedBox(
              height: 18,
            ),
            const GoogleSignInButton(),
            const SizedBox(height: 20),
            Container(
              color: const Color(0xFFEEEEEE),
              height: 1,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            )
          ],
        ),
      ),
    );
  }
}
