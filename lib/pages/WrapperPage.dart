import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedsPage.dart';

class WrapperPage extends StatefulWidget {
  @override
  _WrapperPageState createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeedsPage(),
    );
  }

}
