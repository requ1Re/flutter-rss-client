import 'dart:ui';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
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
                      borderRadius: BorderRadius.all(Radius.circular(25))),
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

    bool hasOnlyTitle = true;
    if (item.description != null) {
      _card.add(Divider());
      _card.add(Html(
          data: item.description,
          onLinkTap: (link) async {
            await launch(link);
          }));
      hasOnlyTitle = false;
    }
    if (item.pubDate != null) {
      _card.add(Divider());
      _card.add(Text("Published " + DateFormat().format(DateTime.parse(item.pubDate)), style: TextStyle(color: Theme.of(context).primaryColor)));
      hasOnlyTitle = false;
    }
    _card.insert(0, Text(item.title, style: hasOnlyTitle ? null : TextStyle(color: Theme.of(context).primaryColor, fontSize: 18)));

    return _card;
  }
}
