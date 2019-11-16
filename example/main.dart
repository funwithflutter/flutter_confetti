import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() => runApp(ConfettiSample());

class ConfettiSample extends StatelessWidget {
  const ConfettiSample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: true,
        title: 'Confetti',
        home: Scaffold(
          backgroundColor: Colors.grey[900],
          body: MyApp(),
        ));
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ConfettiController _controllerCenterRight;
  ConfettiController _controllerCenterLeft;
  ConfettiController _controllerTopCenter;
  ConfettiController _controllerBottonCenter;

  @override
  void initState() {
    _controllerCenterRight =
        ConfettiController(duration: Duration(seconds: 10));
    _controllerCenterLeft = ConfettiController(duration: Duration(seconds: 10));
    _controllerTopCenter = ConfettiController(duration: Duration(seconds: 10));
    _controllerBottonCenter =
        ConfettiController(duration: Duration(seconds: 10));
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenterRight.dispose();
    _controllerCenterLeft.dispose();
    _controllerTopCenter.dispose();
    _controllerBottonCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //CENTER RIGHT -- Emit left
        Align(
          alignment: Alignment.centerRight,
          child: ConfettiWidget(
            confettiController: _controllerCenterRight,
            blastDirection: pi, // radial value - LEFT
            emissionFrequency: 0.05,
            numberOfParticles: 10,
            shouldLoop: false,
            colors: [Colors.green, Colors.blue, Colors.pink], // manually specify the colors to be used
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
              onPressed: () {
                _controllerCenterRight.play();
              },
              child: _display('pump left')),
        ),
        //CENTER LEFT
        Align(
          alignment: Alignment.centerLeft,
          child: ConfettiWidget(
            confettiController: _controllerCenterLeft,
            blastDirection: 0, // radial value - RIGHT
            emissionFrequency: 0.6,
            minimumSize: const Size(10,10), // set the minimum potential size for the confetti (width, height)
            maximumSize: const Size(50,50), // set the maximum potential size for the confetti (width, height)
            numberOfParticles: 1,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FlatButton(
              onPressed: () {
                _controllerCenterLeft.play();
              },
              child: _display('single shooter')),
        ),
        //TOP CENTER
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controllerTopCenter,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: FlatButton(
              onPressed: () {
                _controllerTopCenter.play();
              },
              child: _display('goliath')),
        ),
        //BOTTOM CENTER
        Align(
          alignment: Alignment.bottomCenter,
          child: ConfettiWidget(
            confettiController: _controllerBottonCenter,
            blastDirection: -pi / 2,
            emissionFrequency: 0.01,
            numberOfParticles: 20,
            maxBlastForce: 100,
            minBlastForce: 80,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FlatButton(
              onPressed: () {
                _controllerBottonCenter.play();
              },
              child: _display('hard and infrequent')),
        ),
      ],
    );
  }

  Text _display(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 20),
    );
  }
}
