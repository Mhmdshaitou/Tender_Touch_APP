import 'package:flutter/material.dart';
import 'package:tender_touch/login/responsive.dart';
import '../../components/background.dart';
import 'components/login_form.dart';
import 'components/login_screen_top_image.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';
  final String destinationRoute;

  const LoginScreen({Key? key, required this.destinationRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileLoginScreen(destinationRoute: destinationRoute),
          desktop: Row(
            children: [
              Expanded(
                child: LoginScreenTopImage(),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      child: LoginForm(destinationRoute: destinationRoute),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  final String destinationRoute;
  const MobileLoginScreen({Key? key, required this.destinationRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const LoginScreenTopImage(),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: LoginForm(destinationRoute: destinationRoute),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
