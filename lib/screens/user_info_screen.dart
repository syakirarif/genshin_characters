import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genshin_characters/screens/setting_screen.dart';
import 'package:genshin_characters/utils/custom_colors.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;
  bool _isSigningOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SettingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildProfile2();
  }

  Widget buildProfile2() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 20.0,
        ),
        child: Column(
          children: [
            _user.photoURL != null
                ? ClipOval(
                    child: Material(
                      color: CustomColors.firebaseGrey.withOpacity(0.3),
                      child: Image.network(
                        _user.photoURL!,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                : ClipOval(
                    child: Material(
                      color: CustomColors.firebaseGrey.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: CustomColors.firebaseGrey,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 30),
            Text(_user.displayName!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 8),
            Text(_user.email!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 20),
            const Text(
              'You are now signed in using your Google account, so you can record your code redemption history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black, fontSize: 14, letterSpacing: 0.2),
            ),
            SizedBox(height: 16.0),
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
