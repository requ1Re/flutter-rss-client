import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedsPage.dart';
import 'package:flutter_rss_client/utils/AppTheme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(FlutterRSSClient());
}

class FlutterRSSClient extends StatefulWidget {
  @override
  _FlutterRSSClientState createState() => _FlutterRSSClientState();
}

class _FlutterRSSClientState extends State<FlutterRSSClient> {
  AppTheme theme = AppTheme();

  @override
  void initState() {
    super.initState();
    theme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RSS Client',
      theme: theme.currentTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter RSS Client"),
          elevation: 10,
          brightness: Brightness.dark,
          actions: [
            IconButton(
                icon: theme.isDark()
                    ? FaIcon(FontAwesomeIcons.solidSun)
                    : FaIcon(FontAwesomeIcons.solidMoon),
                onPressed: () => theme.switchTheme()
            )
          ],
        ),
        body: FeedsPage(),
      ),
    );
  }
}
