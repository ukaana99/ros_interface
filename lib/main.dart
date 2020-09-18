import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:ros_interface/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AutoOrientation.landscapeAutoMode();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ROS Interface',
      theme: ThemeData(
        brightness: Brightness.dark,
        // primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
