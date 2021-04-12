import 'dart:ui';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
        elevation: 10,
        brightness: Brightness.dark,
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: ListView.builder(
          itemCount: widget.feed.items.length,
          itemBuilder: (context, index){
            RssItem item = widget.feed.items[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Card(
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25))
                ),
                elevation: 5,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  onTap: () async {
                    await launch(item.link);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18)),
                        Divider(),
                        Text(item.description),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("Published at " + DateFormat().format(item.pubDate.toLocal()), style: TextStyle(color: Theme.of(context).primaryColor)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      )
    );
  }
}
