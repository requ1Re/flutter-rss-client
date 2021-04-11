import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedsPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(FlutterRSSClient());
}

class FlutterRSSClient extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: FlutterRSSClientHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class FlutterRSSClientHomePage extends StatefulWidget {
  FlutterRSSClientHomePage({Key key, this.title}) : super(key: key);

  final String title;

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.25),
              spreadRadius: 3,
              blurRadius: 6,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _page,
          onTap: (index){
            this._c.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.list),
              label: 'Feeds',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.cog),
              label: 'Settings',
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _c,
        onPageChanged: (newPage) {
          setState(() {
            this._page = newPage;
            FocusScope.of(context).unfocus();
          });
        },
        children: [
          FeedsPage(),
        ],
      ),
    );
  }
}
