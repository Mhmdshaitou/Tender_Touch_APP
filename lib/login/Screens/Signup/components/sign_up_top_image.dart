import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double defaultPadding = 16.0;

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Sign Up".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: defaultPadding),

      ],
    );
  }
}
