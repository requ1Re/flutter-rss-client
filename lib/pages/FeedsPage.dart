import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedViewPage.dart';
import 'package:flutter_rss_client/types/SavedFeed.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as Foundation;

class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  List<SavedFeed> feeds = [];
  final _feedAddController = TextEditingController();
  bool _validationFailed = false;

  @override
  void initState() {
    loadFeeds();

    super.initState();
  }

  void loadFeeds() {
    SharedPreferences.getInstance().then((prefs) {
      String feedsJSON = prefs.getString("rss_feeds") ?? "[]";
      setState(() {
        feeds = savedFeedFromJson(feedsJSON);
      });
      loadFeedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ) : Container(),
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Subscriptions",
                            style: TextStyle(
                                fontSize: 32, color: Theme.of(context).primaryColor
                            )
                        ),
                        IconButton(
                          onPressed: (){
                            loadFeeds();
                            loadFeedData();
                          },
                          icon: Icon(Icons.refresh),
                          color: Theme.of(context).primaryColor,
                        )
                      ],
                    ),
                    Text("Swipe left to delete, swipe right to download.")
                  ],
                )
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: feeds.length,
                itemBuilder: (context, index) {
                  SavedFeed f = feeds[index];
                  return Dismissible(
                      key: f.uniqueKey,
                      background: slideRightBackground(),
                      secondaryBackground: slideLeftBackground(),
                      confirmDismiss: (direction) {
                        if(direction == DismissDirection.endToStart){
                          return Future.value(true);
                        }else{
                          setState(() {
                            f.offlineAvailability = !f.offlineAvailability;
                          });
                          saveFeeds();

                          return Future.value(false);
                        }
                      },
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
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(f.name, overflow: TextOverflow.clip),
                            )
                          ],
                        ),
                        subtitle: f.loadedFeed == null ? null : Text(f.url),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Badge(
                              badgeContent: Text(f.loadedFeed?.items?.length?.toString() ?? "0", style: TextStyle(color: Colors.white)),
                              badgeColor: Theme.of(context).primaryColor,
                            )
                          ],
                        ),
                        onTap: () {
                          if (f.loadedFeed != null) {
                            loadFeed(f.loadedFeed);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Feed is still loading. Please wait.")
                                )
                            );
                          }
                        },
                      ));
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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

                                  saveFeeds();
                                  loadFeedData();
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
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.download_sharp,
              color: Colors.white,
            ),
            Text(
              " Download",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  void saveFeeds() async {
    fixFeedOrder();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("rss_feeds", savedFeedToJson(feeds));
  }

  void fixFeedOrder() {
    setState(() {
      for (int i = 0; i < feeds.length; i++) {
        feeds[i].id = i;
      }
    });
  }

  void loadFeedData() async {
    for (int i = 0; i < feeds.length; i++) {
      SavedFeed feed = feeds[i];

      try {
        var response = await http.get(Uri.parse(feed.url));
        if (response.statusCode == 200) {
          var rssFeed = RssFeed.parse(response.body);
          setState(() {
            feed.name = rssFeed.title;
            feed.loadedFeed = rssFeed;
          });
        }
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error while loading Feed #$i: ' + err.toString(),
                style: TextStyle(color: Colors.white)
            ),
            backgroundColor: Colors.red)
        );
      }
    }
    saveFeeds();
  }

  void loadFeed(RssFeed feed) {
    showMaterialModalBottomSheet(
      shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)
          )
      ),
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FeedViewPage(feed: feed);
          },
        );
      },
    );
  }

  Widget getLeadingIcon(SavedFeed f){
    return f.offlineAvailability ? Icon(Icons.cloud_done, color: Colors.green) : Icon(Icons.cloud_download_outlined, color: Colors.red);
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
    super.dispose();
  }
}
