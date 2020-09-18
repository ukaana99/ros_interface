import 'dart:math' as _math;
import 'package:vector_math/vector_math.dart' as _vmath;

import 'package:flutter/material.dart';
import 'package:roslib/roslib.dart';
import 'package:control_pad/control_pad.dart';
import 'package:ros_interface/widgets/video_feedback.dart';

class InterfacePage extends StatefulWidget {
  final url;
  InterfacePage({@required this.url, Key key}) : super(key: key);
  @override
  _InterfacePageState createState() => new _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
  TextEditingController rosPortController;
  TextEditingController videoPortController;
  TextEditingController videoPathController;
  TextEditingController mapPathController;
  TextEditingController subscribedTopicController;
  TextEditingController publishedVelTopicController;

  Ros ros;
  Topic info;
  Topic cmdVel;

  bool _rosConnected;
  bool _videoConnected;

  bool _menuVisibility;
  bool _settingVisibility;
  bool _gridOn;
  bool _invertJoystick;
  bool _mapViewOn;
  String _streamUrl;
  List<String> _topics;
  String _selectedTopic;

  @override
  void initState() {
    _rosConnected = false;
    _videoConnected = false;
    _menuVisibility = false;
    _settingVisibility = false;
    _gridOn = false;
    _invertJoystick = false;
    _mapViewOn = false;
    _streamUrl = null;

    _topics = ['/info', '/cmd_vel', '/ip', '/led', '/hspm', '/bdc'];
    _selectedTopic = _topics.first;

    rosPortController = TextEditingController(text: '9090');
    videoPortController = TextEditingController(text: '8080');
    videoPathController = TextEditingController(
        text: '/stream?topic=/usb_cam/image_raw&type=mjpeg');
    mapPathController = TextEditingController(text: '/');
    subscribedTopicController = TextEditingController(text: '/info');
    publishedVelTopicController = TextEditingController(text: '/cmd_vel');

    ros = Ros(url: 'ws://' + widget.url + ':' + rosPortController.text);
    info = Topic(
      ros: ros,
      name: subscribedTopicController.text,
      type: "std_msgs/String",
      reconnectOnClose: true,
      queueLength: 10,
      queueSize: 10,
    );
    cmdVel = Topic(
      ros: ros,
      name: publishedVelTopicController.text,
      type: 'geometry_msgs/Twist',
    );
    super.initState();
  }

  void initConnectionRos() async {
    ros.url = 'ws://' + widget.url + ':' + rosPortController.text;
    ros.connect();
    await info.subscribe();
    // await cmdVel.advertise();
  }

  void destroyConnectionRos() async {
    await info.unsubscribe();
    // await cmdVel.unadvertise();
    await ros.close();
  }

  @override
  Widget build(BuildContext context) {
    final sideBarColor = Color.fromARGB(0, 0, 0, 0);
    // final sideBarColor = Colors.black;
    final sideBarWidth = (MediaQuery.of(context).size.width -
            MediaQuery.of(context).size.height * 4 / 3) /
        2;
    double linearX, linearY, angularZ;

    return Scaffold(
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // video feedback
            Center(
              child: VideoFeedback(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.height * 4 / 3,
                streamUrl: _streamUrl,
              ),
            ),

            // map view
            Center(
              child: Visibility(
                visible: _mapViewOn,
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.height * 4 / 3,
                ),
              ),
            ),

            // grid overlay
            Center(
              child: Visibility(
                visible: _gridOn,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.height * 4 / 3,
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Divider(color: Colors.white),
                          Divider(color: Colors.white),
                          Divider(color: Colors.white),
                          Divider(color: Colors.white),
                          Divider(color: Colors.white),
                          Divider(color: Colors.white),
                          Divider(color: Colors.white),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          VerticalDivider(color: Colors.white),
                          VerticalDivider(color: Colors.white),
                          VerticalDivider(color: Colors.white),
                          VerticalDivider(color: Colors.white),
                          VerticalDivider(color: Colors.white),
                          VerticalDivider(color: Colors.white),
                          VerticalDivider(color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // left side bar
            Positioned(
              child: Container(
                color: sideBarColor,
                width: sideBarWidth,
                height: double.maxFinite,
                child: Column(
                  children: [
                    Container(
                      // color: Colors.red,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 50,
                            child: RawMaterialButton(
                              onPressed: () {},
                              padding: EdgeInsets.all(10),
                              child: _rosConnected
                                  ? Icon(Icons.wifi)
                                  : Icon(Icons.signal_wifi_off),
                              shape: CircleBorder(
                                side: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: RawMaterialButton(
                              onPressed: () {},
                              padding: EdgeInsets.all(10),
                              child: _videoConnected
                                  ? Icon(Icons.videocam)
                                  : Icon(Icons.videocam_off),
                              shape: CircleBorder(
                                side: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Topic: $_selectedTopic'),
                    SizedBox(height: 10),
                    StreamBuilder(
                      stream: info.subscription,
                      builder: (context, snapshot) {
                        return Text(snapshot.hasData
                            ? '${snapshot.data['msg']}'
                            : 'no data');
                      },
                    ),
                    // SizedBox(height: 30),
                    // Hero(
                    //   tag: 'map',
                    //   child: Container(
                    //     color: Colors.white,
                    //     height: sideBarWidth * 3 / 4 - 40,
                    //     width: sideBarWidth - 40,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // right side bar
            Positioned(
              right: 0,
              child: Container(
                color: sideBarColor,
                width: sideBarWidth,
                height: double.maxFinite,
                child: Column(
                  children: [
                    Container(
                      // color: Colors.blue,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 50,
                            child: RawMaterialButton(
                              onPressed: () => setState(() {
                                _menuVisibility = true;
                              }),
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.menu),
                              shape: CircleBorder(
                                side: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: RawMaterialButton(
                              onPressed: () => setState(() {
                                _settingVisibility = true;
                              }),
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.settings),
                              shape: CircleBorder(
                                side: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('ROS'),
                    StreamBuilder<Object>(
                      stream: ros.statusStream,
                      builder: (context, snapshot) {
                        _rosConnected = snapshot.data == Status.CONNECTED;
                        return ActionChip(
                          label: Container(
                            width: sideBarWidth * 0.65,
                            child: Center(
                              child: Text(
                                  _rosConnected ? 'DISCONNECT' : 'CONNECT'),
                            ),
                          ),
                          backgroundColor: _rosConnected
                              ? Colors.green[300]
                              : Colors.red[300],
                          onPressed: () {
                            if (_rosConnected)
                              destroyConnectionRos();
                            else
                              initConnectionRos();
                            setState(() {
                              _rosConnected = snapshot.data == Status.CONNECTED;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Text('Video'),
                    ActionChip(
                      label: Container(
                        width: sideBarWidth * 0.65,
                        child: Center(
                          child:
                              Text(_videoConnected ? 'DISCONNECT' : 'CONNECT'),
                        ),
                      ),
                      backgroundColor:
                          _videoConnected ? Colors.green[300] : Colors.red[300],
                      onPressed: () {
                        if (_videoConnected)
                          setState(() {
                            _streamUrl = null;
                            _videoConnected = false;
                          });
                        else
                          setState(() {
                            _streamUrl = 'http://' +
                                widget.url +
                                ':' +
                                videoPortController.text +
                                videoPathController.text;
                            _videoConnected = true;
                          });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // left joystick
            Positioned(
              top: MediaQuery.of(context).size.height - 180,
              left: 40,
              child: JoystickView(
                backgroundColor: Colors.grey[900],
                innerCircleColor: Colors.grey[900],
                iconsColor: Colors.grey[500],
                size: 160,
                interval: Duration(milliseconds: 200),
                onDirectionChanged: (degrees, distance) {
                  double radians = _vmath.radians(degrees);
                  linearX = double.parse(
                      (distance * _math.sin(radians)).toStringAsFixed(3));
                  linearY = double.parse(
                      (distance * _math.cos(radians)).toStringAsFixed(3));
                  // print('degrees: $degrees');
                  // print('distance: $distance');
                  // print('x: $linearX');
                  // print('y: $linearY');
                  var msg = {
                    'linear': {
                      'x': !_invertJoystick ? linearX : linearY,
                      'y': !_invertJoystick ? linearY : linearX,
                      'z': 0.0
                    },
                    'angular': {'x': 0.0, 'y': 0.0, 'z': angularZ},
                  };
                  cmdVel.name = publishedVelTopicController.text;
                  cmdVel.publish(msg);
                },
              ),
            ),

            // right joystick
            Positioned(
              top: MediaQuery.of(context).size.height - 180,
              right: 40,
              child: JoystickView(
                backgroundColor: Colors.grey[900],
                innerCircleColor: Colors.grey[900],
                iconsColor: Colors.grey[500],
                size: 160,
                interval: Duration(milliseconds: 200),
                onDirectionChanged: (degrees, distance) {
                  double radians = _vmath.radians(degrees);
                  angularZ = double.parse(
                      (distance * _math.sin(radians)).toStringAsFixed(3));
                  // print('degrees: $degrees');
                  // print('distance: $distance');
                  // print('z: $angularZ');
                  var msg = {
                    'linear': {'x': linearX, 'y': linearY, 'z': 0.0},
                    'angular': {'x': 0.0, 'y': 0.0, 'z': angularZ},
                  };
                  // print(msg);
                  cmdVel.name = publishedVelTopicController.text;
                  cmdVel.publish(msg);
                },
              ),
            ),

            // menu
            Visibility(
              visible: _menuVisibility,
              child: Container(
                color: Color.fromARGB(191, 0, 0, 0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.8,
                    width: 400,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Menu',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: RawMaterialButton(
                                onPressed: () => setState(() {
                                  _menuVisibility = false;
                                }),
                                child: Icon(Icons.close),
                                shape: CircleBorder(
                                  side: BorderSide(color: Colors.grey[900]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: ListView(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Subscribed topic',
                                      style: TextStyle(
                                        color: Theme.of(context).disabledColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _selectedTopic,
                                        items: _topics
                                            .map((value) =>
                                                DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value)))
                                            .toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedTopic = newValue;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                TextField(
                                  controller: publishedVelTopicController,
                                  decoration: const InputDecoration(
                                    labelText: 'Published velocity topic',
                                    hintText: '/cmd_vel',
                                  ),
                                ),
                                SizedBox(height: 20),
                                SwitchListTile(
                                  value: _gridOn,
                                  onChanged: (value) {
                                    setState(() {
                                      _gridOn = value;
                                    });
                                  },
                                  title: Text(
                                    'Show Grid',
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor),
                                  ),
                                  contentPadding: EdgeInsets.all(0),
                                ),
                                SwitchListTile(
                                  value: _invertJoystick,
                                  onChanged: (value) {
                                    setState(() {
                                      _invertJoystick = value;
                                    });
                                  },
                                  title: Text(
                                    'Switch X and Y Joystick',
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor),
                                  ),
                                  contentPadding: EdgeInsets.all(0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // setting
            Visibility(
              visible: _settingVisibility,
              child: Container(
                color: Color.fromARGB(191, 0, 0, 0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.8,
                    width: 400,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Setting',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: RawMaterialButton(
                                onPressed: () => setState(() {
                                  _settingVisibility = false;
                                }),
                                child: Icon(Icons.close),
                                shape: CircleBorder(
                                  side: BorderSide(color: Colors.grey[900]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: ListView(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'IP Address',
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Text('http://' + widget.url,
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                                TextField(
                                  controller: rosPortController,
                                  decoration: const InputDecoration(
                                    labelText: 'ROS port',
                                    hintText: '9090',
                                  ),
                                ),
                                TextField(
                                  controller: videoPortController,
                                  decoration: const InputDecoration(
                                    labelText: 'Video port',
                                    hintText: '8080',
                                  ),
                                ),
                                TextField(
                                  controller: videoPathController,
                                  decoration: const InputDecoration(
                                    labelText: 'Video path',
                                    hintText:
                                        '/stream?topic=/usb_cam/image_raw&type=mjpeg',
                                  ),
                                ),
                                TextField(
                                  controller: mapPathController,
                                  decoration: const InputDecoration(
                                    labelText: 'Map path',
                                    hintText: '',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
