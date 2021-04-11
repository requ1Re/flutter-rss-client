import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rss_client/types/SavedFeed.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  List<SavedFeed> feeds = [];
  final _feedAddController = TextEditingController();

  @override
  void initState() {
    loadFeeds();

    super.initState();
  }

  void loadFeeds(){
    SharedPreferences.getInstance().then((prefs) {
      String feedsJSON = prefs.getString("rss_feeds") ?? "[]";
      feeds = savedFeedFromJson(feedsJSON);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feeds"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _feedAddController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.rss_feed),
                        border: OutlineInputBorder(),
                        hintText: "Feed URL"
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      if(_feedAddController.text.length > 0) {
                        setState(() {
                          SavedFeed _newFeed = new SavedFeed(
                            id: feeds.length,
                            url: _feedAddController.text
                          );
                          feeds.add(_newFeed);
                          _feedAddController.clear();
                        });

                        saveFeeds();
                      }
                    }
                )
              ],
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: feeds.length,
                itemBuilder: (context, index){
                  SavedFeed f = feeds[index];
                  return Dismissible(
                      key: Key('${f.id}-${f.url}'),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) {
                        setState(() {
                          feeds.removeAt(index);
                        });
                        fixFeedOrder();
                        saveFeeds();

                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("Feed has been removed")));
                      },
                      child: ListTile(
                        title: Text('[#${f.id}] ' + f.url),
                        leading: Icon(Icons.rss_feed),
                        trailing: IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed: (){
                            // TODO: Navigate to Feed
                          },
                        ),
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
            )
          ],
        ),
      ),
    );
  }

  void saveFeeds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("rss_feeds", savedFeedToJson(feeds));
  }

  void fixFeedOrder(){
    setState(() {
      for(int i = 0; i < feeds.length; i++){
        feeds[i].id = i;
      }
    });
  }

  @override
  void dispose() {
    _feedAddController.dispose();
    super.dispose();
  }

  Widget buildFeedListViewItem(SavedFeed feed){
    return Container(
      key: UniqueKey(),
      height: 50,
      child: Center(child: Text(feed.url)),
    );
  }
}