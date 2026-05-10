import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../screens/toogle_widget.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return const MaterialApp(
        title: "Plantão",
        debugShowCheckedModeBanner: false,
        home: InitScreen(),
        routes: {},
      );
    });
  }
}
