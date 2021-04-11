import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/FeedViewPage.dart';
import 'package:flutter_rss_client/types/SavedFeed.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

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

  void loadFeeds(){
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
      appBar: AppBar(
        title: Text("Feeds"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      onChanged: (str){
                        setState(() {
                          _validationFailed = false;
                        });
                      },
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        bool _success = true;
                        if(_feedAddController.text.length > 0) {
                          if(Uri.parse(_feedAddController.text).isAbsolute){
                            setState(() {
                              SavedFeed _newFeed = new SavedFeed(
                                  id: feeds.length,
                                  url: _feedAddController.text
                              );
                              feeds.add(_newFeed);
                              _feedAddController.clear();
                            });

                            saveFeeds();
                          }else{
                            _success = false;
                          }
                        }else{
                          _success = false;
                        }
                        setState(() {
                          _validationFailed = !_success;
                        });
                      }
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text("Feeds", style: TextStyle(fontSize: 32)),
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: feeds.length,
                itemBuilder: (context, index){
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

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Feed has been removed")));
                      },
                      child: ListTile(
                        title: Text(f.loadedFeed?.title ?? 'Feed #$index'),
                        subtitle: Text(f.url),
                        trailing: Icon(Icons.chevron_right),
                        onTap: (){
                          if(f.loadedFeed != null) {
                            _navigateToScreen(FeedViewPage(feed: f.loadedFeed));
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Feed is still loading. Please wait.")));
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
            )
          ],
        ),
      ),
    );
  }

  void saveFeeds() async {
    fixFeedOrder();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("rss_feeds", savedFeedToJson(feeds));
    loadFeedNames();
  }

  void fixFeedOrder(){
    setState(() {
      for(int i = 0; i < feeds.length; i++){
        feeds[i].id = i;
      }
    });
  }

  void loadFeedNames() async {
    for(int i = 0; i < feeds.length; i++){
      SavedFeed feed = feeds[i];

      try {
        if(feed.loadedFeed == null){
          var response = await http.get(feed.url);
          if (response.statusCode == 200) {
            var rssFeed = RssFeed.parse(response.body);
            setState(() {
              feed.loadedFeed = rssFeed;
            });
          }
        }
      }catch(err){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error while loading Feed #$i: ' + err.toString(), style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red
            )
        );
      }
    }
  }

  void _navigateToScreen(Widget screen){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
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