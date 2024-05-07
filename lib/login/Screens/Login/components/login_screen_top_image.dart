import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double defaultPadding = 16.0;

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "LOGIN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: defaultPadding * 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              // Wrap the SvgPicture with a SizedBox or Container to control its size
              flex: 4,
              child: SizedBox(
                // Specify the width and height to control the size
                // Adjust these values according to your needs
                height: 300, // Example height
                width: 300, // Example width
                child: SvgPicture.asset("images/icons/login.svg"),
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
