import 'dart:ui';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:intl/intl.dart';

class FeedViewPage extends StatefulWidget {
  final RssFeed feed;

  const FeedViewPage({Key key, this.feed}) : super(key: key);

  @override
  _FeedViewPageState createState() => _FeedViewPageState();
}

class _FeedViewPageState extends State<FeedViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feed.title),
      ),
      body: ListView.builder(
        itemCount: widget.feed.items.length,
        itemBuilder: (context, index){
            RssItem item = widget.feed.items[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Card(
                elevation: 20,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  title: Text(item.title),
                  subtitle: Column(
                    children: [
                      Text(item.description),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text("Published at " + DateFormat().format(item.pubDate.toLocal())),
                      ),
                    ],
                  ),
                ),
              ),
            );
        }
      ),
    );
  }
}
