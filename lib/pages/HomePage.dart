import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedsPage.dart';
import 'package:flutter_rss_client/utils/ApplicationSettings.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApplicationSettings appSettings = ApplicationSettings();
  bool darkTheme = false;
  bool offlineMode = false;

  @override
  void initState() {
    super.initState();
  }

  void refreshSettings(){
    setState(() {
      darkTheme = appSettings.isDarkThemeEnabled();
      offlineMode = appSettings.isOfflineModeEnabled();
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshSettings();

    appSettings.addListener(() {
      refreshSettings();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter RSS Client"),
        elevation: 10,
        brightness: Brightness.dark,
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: (){
                showMaterialModalBottomSheet(
                  context: context,
                  builder: (context){
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text("Settings",
                                  style: TextStyle(
                                      fontSize: 16, color: Theme.of(context).primaryColor
                                  )
                              ),
                            ),
                            ListTile(
                              title: Text("Dark Theme"),
                              trailing: Switch(
                                  value: darkTheme,
                                  onChanged: (val){
                                    appSettings.setEnableDarkMode(val);
                                  }
                              ),
                            ),
                            ListTile(
                              title: Text("Offline Mode"),
                              trailing: Switch(
                                  value: offlineMode,
                                  onChanged: (val){
                                    appSettings.setEnableOfflineMode(val);
                                  }
                              ),
                            )
                          ],
                        );
                      }
                    );
                  },
                );
              }
          )
        ],
      ),
      body: FeedsPage(),
    );
  }
}
