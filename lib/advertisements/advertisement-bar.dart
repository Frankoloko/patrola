import 'package:flutter/material.dart';
import '../global-values.dart' as globalValues;

class AdvertisementBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          globalValues.contactUs(context);
        },
        child: Container(
          height: 60.0,
          child: Image.asset('assets/advertise-here.jpg'),
        ));
  }
}
