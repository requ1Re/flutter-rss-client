import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedViewPage.dart';
import 'package:flutter_rss_client/pages/SettingsPage.dart';
import 'package:flutter_rss_client/types/SavedFeed.dart';
import 'package:flutter_rss_client/utils/ApplicationSettings.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' as Foundation;

class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  ApplicationSettings appSettings = ApplicationSettings();
  bool offlineMode = false;

  List<SavedFeed> feeds = [];
  final _feedAddController = TextEditingController();
  bool _validationFailed = false;

  @override
  void initState() {
    super.initState();

    feedsInit();
  }

  void feedsInit() async {
    refreshSettings();
    appSettings.addListener(() {
      refreshSettings();
    });

    await loadFeedsFromDisk();
    if(!offlineMode){
      updateAllFeeds();
    }
  }

  void refreshSettings(){
    setState(() {
      offlineMode = appSettings.isOfflineModeEnabled();
    });
  }

  Future<void> loadFeedsFromDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String feedsJSON = prefs.getString("rss_feeds") ?? "[]";
    feeds = savedFeedFromJson(feedsJSON);
    if(offlineMode){
      for(int i = 0; i < feeds.length; i++){
        SavedFeed feed = feeds[i];
        if(feed.xml != null){
          feed.loadedFeed = RssFeed.parse(feed.xml!);
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Flutter RSS Client", style: TextStyle(fontSize: 16)),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      if(!offlineMode){
                        await updateAllFeeds();
                      }
                    },
                    icon: Icon(
                      Icons.refresh, 
                      color: Theme.of(context).textTheme.bodyText2?.color
                    )
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    },
                    icon: Icon(
                      Icons.settings, 
                      color: Theme.of(context).textTheme.bodyText2?.color
                    )
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subscriptions", 
                    style: TextStyle(
                      fontSize: 32, 
                      color: Theme.of(context).textTheme.subtitle1?.color
                    )
                  ),
                  Text("Swipe to delete", 
                    style: TextStyle(
                      fontSize: 18
                    )
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: feeds.length,
                itemBuilder: (context, index) {
                  SavedFeed f = feeds[index];
                  return Dismissible(
                      key: f.uniqueKey,
                      background: Container(
                        color: Colors.red
                      ),
                      onDismissed: (direction){
                        setState(() {
                          feeds.removeAt(index);
                        });
                        fixFeedOrder();
                        saveFeeds();

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Feed has been removed")));
                      },
                      child: ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            getLeadingIcon(f),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(f.name, overflow: TextOverflow.clip),
                              ),
                            )
                          ],
                        ),
                        subtitle: Text("Last updated: " + (f.lastUpdate ?? "Unknown"), style: TextStyle(color: Theme.of(context).textTheme.bodyText2?.color)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Badge(
                              badgeContent: Text(f.loadedFeed?.items.length.toString() ?? "0", style: TextStyle(color: Colors.white)),
                              badgeColor: Color(0xFF8185a3),
                            )
                          ],
                        ),
                        onTap: () {
                          if(offlineMode && f.xml == null){
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("This feed is not available in Offline Mode.")
                                )
                            );
                          }else{
                            if (f.loadedFeed != null) {
                              loadFeed(f.loadedFeed!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Feed is still loading. Please wait.")
                                  )
                              );
                            }
                          }
                        },
                      )
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final SavedFeed item = feeds.removeAt(oldIndex);
                    feeds.insert(newIndex, item);
                  });
                  fixFeedOrder();
                  saveFeeds();
                },
              ),
            ),
            // DEV TOOLS
            Foundation.kDebugMode ? Column(
              children: [
                TextButton(
                  onPressed: (){
                    SharedPreferences.getInstance().then((s){
                      s.clear();
                    });
                  },
                  child: Text("[DEV] Clear Data"),
                )
              ],
            ) : Container()
          ],
        ),
      ),
      floatingActionButton: getActionButton(),
    );
  }

  Widget getActionButton(){
    if(offlineMode){
      return Container();
    }else{ 
      return FloatingActionButton(
        backgroundColor: Color(0xFF959abd),
        onPressed: () {
          showMaterialModalBottomSheet(
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)
                )
            ),
            useRootNavigator: true,
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: 10 + MediaQuery.of(context).viewInsets.bottom
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _feedAddController,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.rss_feed),
                                border: OutlineInputBorder(),
                                labelText: "Add Feed",
                                hintText: "Feed URL",
                                errorText: _validationFailed ? "Please enter an URL." : null
                            ),
                            onChanged: (str) {
                              setState(() {
                                _validationFailed = false;
                              });
                            },
                          ),
                        ),
                        IconButton(
                            color: Theme.of(context).primaryColor,
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              bool _success = true;
                              if (_feedAddController.text.length > 0) {
                                if (Uri.parse(_feedAddController.text).isAbsolute) {
                                  setState(() {
                                    SavedFeed _newFeed = new SavedFeed(
                                        id: feeds.length,
                                        url: _feedAddController.text,
                                        name: _feedAddController.text
                                    );
                                    feeds.add(_newFeed);
                                    _feedAddController.clear();
                                  });

                                  await saveFeeds();
                                  await loadFeedsFromDisk();
                                  await updateAllFeeds();
                                } else {
                                  _success = false;
                                }
                              } else {
                                _success = false;
                              }
                              setState(() {
                                _validationFailed = !_success;
                              });
                            }
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      );
    }
  }

  Future<void> saveFeeds() async {
    fixFeedOrder();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("rss_feeds", savedFeedToJson(feeds));
    print("[DEBUG] Saved feeds to disk");
  }

  void fixFeedOrder() {
    for (int i = 0; i < feeds.length; i++) {
      feeds[i].id = i;
    }
    setState(() {});
  }

  Future<void> updateAllFeeds() async {
    for (int i = 0; i < feeds.length; i++) {
      SavedFeed feed = feeds[i];
      await feed.update(context);
      setState(() {});
    }
  }

  void loadFeed(RssFeed feed) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedViewPage(feed: feed)),
    );
  }

  Widget getLeadingIcon(SavedFeed f){
    return (f.xml == null) ? Icon(Icons.cloud_download_outlined, color: Colors.red) : Icon(Icons.cloud_done, color: Colors.green);
  }

  Widget getFeedSubtitle(SavedFeed f){
    if(offlineMode){
      return Text("Last Updated: " + (f.lastUpdate ?? "Unknown"));
    }else{
      return Text(f.url);
    }
  }

  Widget buildFeedListViewItem(SavedFeed feed) {
    return Container(
      key: UniqueKey(),
      height: 50,
      child: Center(child: Text(feed.url)),
    );
  }

  @override
  void dispose() {
    _feedAddController.dispose();
    appSettings.dispose();

    super.dispose();
  }
}
