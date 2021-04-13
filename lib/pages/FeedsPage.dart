import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedViewPage.dart';
import 'package:flutter_rss_client/types/SavedFeed.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
      loadFeedNames();
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
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
                child: Text("Subscriptions",
                    style: TextStyle(
                        fontSize: 32, color: Theme.of(context).primaryColor)
                )
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: feeds.length,
                itemBuilder: (context, index) {
                  SavedFeed f = feeds[index];
                  return Dismissible(
                      key: f.uniqueKey,
                      background: Container(color: Colors.red),
                      onDismissed: (direction) {
                        setState(() {
                          feeds.removeAt(index);
                        });
                        fixFeedOrder();
                        saveFeeds();

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Feed has been removed"))
                        );
                      },
                      child: ListTile(
                        title: Text(f.loadedFeed?.title ?? 'Feed #$index'),
                        subtitle: Text(f.url),
                        trailing: Badge(
                          badgeContent: Text(f.loadedFeed?.items?.length?.toString() ?? "0",
                              style: TextStyle(color: Colors.white)
                          ),
                          badgeColor: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          if (f.loadedFeed != null) {
                            loadFeed(f.loadedFeed);
                            /*
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => screen),
                            );
                             */
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
                                errorText: _validationFailed
                                    ? "Please enter an URL."
                                    : null),
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
                                if (Uri.parse(_feedAddController.text)
                                    .isAbsolute) {
                                  setState(() {
                                    SavedFeed _newFeed = new SavedFeed(
                                        id: feeds.length,
                                        url: _feedAddController.text);
                                    feeds.add(_newFeed);
                                    _feedAddController.clear();
                                  });

                                  saveFeeds();
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

  void saveFeeds() async {
    fixFeedOrder();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("rss_feeds", savedFeedToJson(feeds));
    loadFeedNames();
  }

  void fixFeedOrder() {
    setState(() {
      for (int i = 0; i < feeds.length; i++) {
        feeds[i].id = i;
      }
    });
  }

  void loadFeedNames() async {
    for (int i = 0; i < feeds.length; i++) {
      SavedFeed feed = feeds[i];

      try {
        if (feed.loadedFeed == null) {
          var response = await http.get(Uri.parse(feed.url));
          if (response.statusCode == 200) {
            var rssFeed = RssFeed.parse(response.body);
            setState(() {
              feed.loadedFeed = rssFeed;
            });
          }
        }
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error while loading Feed #$i: ' + err.toString(),
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red));
      }
    }
  }

  void loadFeed(RssFeed feed) {
    showMaterialModalBottomSheet(
      shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
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

  @override
  void dispose() {
    _feedAddController.dispose();
    super.dispose();
  }

  Widget buildFeedListViewItem(SavedFeed feed) {
    return Container(
      key: UniqueKey(),
      height: 50,
      child: Center(child: Text(feed.url)),
    );
  }
}
