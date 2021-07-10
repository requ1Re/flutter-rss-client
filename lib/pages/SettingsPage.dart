import 'package:flutter/material.dart';
import 'package:flutter_rss_client/utils/ApplicationSettings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({ Key? key }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ApplicationSettings appSettings = ApplicationSettings();
  bool darkTheme = false;
  bool offlineMode = false;

  @override
  void initState() {
    super.initState();

    refreshSettings();

    appSettings.addListener(() {
      refreshSettings();
    });
  }

  void refreshSettings(){
    setState(() {
      darkTheme = appSettings.isDarkThemeEnabled();
      offlineMode = appSettings.isOfflineModeEnabled();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    appSettings = ApplicationSettings();

    return Material(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            Icons.chevron_left,
                            size: 32,
                            color: Theme.of(context).textTheme.bodyText2?.color,
                          ),
                          Text("Dashboard", style: TextStyle(fontSize: 16))
                        ],
                      ),
                      onTap: () => {
                        Navigator.pop(context)
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text("Settings", 
                  style: TextStyle(
                    fontSize: 32, 
                    color: Theme.of(context).textTheme.subtitle1?.color
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
          ),
        ),
    );
  }
}