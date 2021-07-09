import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/WrapperPage.dart';
import 'package:flutter_rss_client/utils/ApplicationSettings.dart';
import 'package:flutter/foundation.dart' as Foundation;

void main() {
  runApp(FlutterRSSClient());
}

class FlutterRSSClient extends StatefulWidget {
  @override
  _FlutterRSSClientState createState() => _FlutterRSSClientState();
}

class _FlutterRSSClientState extends State<FlutterRSSClient> {
  ApplicationSettings appSettings = ApplicationSettings();

  @override
  void initState() {
    super.initState();
    appSettings.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RSS Client',
      theme: appSettings.currentTheme(),
      home: WrapperPage(),
    );
  }
}
