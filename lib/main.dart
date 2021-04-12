import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedsPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(FlutterRSSClient());
}

class FlutterRSSClient extends StatelessWidget {

  final ThemeData customTheme = ThemeData(
    textTheme: GoogleFonts.montserratTextTheme(),
    brightness: Brightness.light,
    canvasColor: Color.fromRGBO(242, 243, 248, 1),
    primaryColor: Color.fromRGBO(72, 52, 212, 1)
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RSS Client',
      theme: customTheme,
      home: FlutterRSSClientHomePage(),
    );
  }
}

class FlutterRSSClientHomePage extends StatefulWidget {
  @override
  _FlutterRSSClientHomePageState createState() => _FlutterRSSClientHomePageState();
}

class _FlutterRSSClientHomePageState extends State<FlutterRSSClientHomePage> {
  int _page = 0;
  PageController _c;

  @override
  void initState(){
    _c =  new PageController(
      initialPage: _page,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter RSS"),
        elevation: 10,
        brightness: Brightness.dark,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25)
          )
        ),
      ),
      body: FeedsPage(),
    );
  }
}
