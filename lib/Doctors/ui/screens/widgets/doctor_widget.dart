import 'package:flutter/material.dart';
import 'package:tender_touch/Doctors/constants.dart';
import 'package:tender_touch/Doctors/models/doctor.dart';
import 'package:tender_touch/Doctors/ui/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';

class DoctorWidget extends StatelessWidget {
  const DoctorWidget({
    Key? key,
    required this.index,
    required this.doctorList,
  }) : super(key: key);

  final int index;
  final List<Doctor> doctorList; // Capitalized Doctor

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            child: DetailPage(
              doctorId: doctorList[index].id,
            ),
            type: PageTransitionType.bottomToTop,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 80.0,
        padding: const EdgeInsets.only(left: 10, top: 10),
        margin: const EdgeInsets.only(bottom: 10, top: 10),
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(.8),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 80.0,
                    child: doctorList[index].image.startsWith('http')
                        ? Image.network(doctorList[index].image) // Network Image
                        : Image.asset(doctorList[index].image), // Asset Image
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorList[index].specialty),
                      Text(
                        doctorList[index].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Constants.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(right: 10),
            ),
          ],
        ),
      ),
    );
  }
}
