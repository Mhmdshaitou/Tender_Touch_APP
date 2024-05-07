import 'package:flutter/material.dart';
import 'package:tender_touch/login/responsive.dart';
import 'background.dart'; // Updated import path
import 'activities_form.dart';

const double defaultPadding = 16.0;
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileActivityScreen(),
          desktop: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      child: ActivitiesForm(),
                    ),
                    SizedBox(height: defaultPadding / 2),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MobileActivityScreen extends StatelessWidget {
  const MobileActivityScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: ActivitiesForm(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
