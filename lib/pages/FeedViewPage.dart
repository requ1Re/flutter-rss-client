import 'dart:ui';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rss_client/pages/ArticleViewPage.dart';
import 'package:url_launcher/url_launcher.dart';

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
            brightness: Brightness.dark
        ),
        body: ListView.builder(
            itemCount: widget.feed.items.length,
            itemBuilder: (context, index) {
              RssItem item = widget.feed.items[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Card(
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArticleViewPage(item: item, feed: widget.feed)),
                      );
                      //await launch(item.link);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildFeedCard(item),
                      ),
                    ),
                  ),
                ),
              );
            }
        )
    );
  }

  List<Widget> buildFeedCard(RssItem item) {
    List<Widget> _card = [];
    if (item.pubDate != null) {
      _card.add(Text("Published " + item.pubDate, style: TextStyle(color: Theme.of(context).primaryColor)));
    }
    _card.insert(0, Text(item.title, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18)));

    return _card;
  }
}
