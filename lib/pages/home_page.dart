import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ros_interface/pages/interface_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final urlController = TextEditingController(text: '192.168.43.110');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[400],
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20),
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/ros_logo.svg',
                fit: BoxFit.fitHeight,
                height: 36,
              ),
              SizedBox(width: 10),
              Text(
                'ROS Interface',
                style: TextStyle(
                  fontSize: 48.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              width: 300.0,
              decoration: ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'IP Address',
                      hintText: '192.168.43.110',
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ActionChip(
                      label: Text('ENTER'),
                      onPressed: () {
                        // print(urlController.text);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              InterfacePage(url: urlController.text),
                        ));
                      }),
                ],
              ),
            ),
          ),
          SizedBox(height: 70),
          Center(
            child: Text('UTM Robocon 2020'),
          ),
        ],
      ),
    );
  }
}
