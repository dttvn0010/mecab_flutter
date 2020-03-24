import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mecab_dart/mecab_dart.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  var tagger = new Mecab();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;    
    try {
      platformVersion = await MecabDart.platformVersion;

      // Initialize mecab tagger here 
      //   + 1st parameter : dictionary asset folder
      //   + 2nd parameter : additional mecab options      
      await tagger.init("assets/ipadic", "");

    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text(tagger.parse('にわにわにわにわとりがいる。').trim().replaceAll(' ', '-')),
        ),
      ),
    );
  }
}
