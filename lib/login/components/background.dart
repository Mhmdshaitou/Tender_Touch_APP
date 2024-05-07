import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
    this.topImage = "images/Images/main_top.png",
    this.bottomImage = "images/Images/login_bottom.png",
  }) : super(key: key);

  final String topImage, bottomImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                topImage, // This uses the topImage variable now
                width: 120,
              ),
            ),
            // Uncomment and use this for the bottom image
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                bottomImage,
                width: 120,
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
