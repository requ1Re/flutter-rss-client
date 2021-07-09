import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rss_client/pages/ArticleViewPage.dart';
import 'package:jiffy/jiffy.dart';

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
        body: SafeArea(
          child: Column(
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
                            color: Theme.of(context).textTheme.bodyText2.color,
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
                padding: EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Latest news", 
                      style: TextStyle(
                        fontSize: 32, 
                        color: Theme.of(context).textTheme.subtitle1.color
                      )
                    ),
                    Text(widget.feed.title, 
                      style: TextStyle(
                        fontSize: 18,
                      )
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                      for(int i = 0; i < widget.feed.items.length; i++)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ArticleViewPage(item: widget.feed.items[i], feed: widget.feed)),
                              )
                            },
                            contentPadding: EdgeInsets.zero,
                            title: Text(widget.feed.items[i].title),
                            subtitle: widget.feed.items[i].pubDate != null ? Text(Jiffy(widget.feed.items[i].pubDate, "E, dd MMM yyyy HH:mm:ss zzz").yMMMMEEEEdjm) : null,
                            trailing: widget.feed.items[i].content.images.isNotEmpty ? Image.network(widget.feed.items[i].content.images.first, fit: BoxFit.cover, width: 100) : null,
                          ),
                        )
                  ],
                ),
              )
            ],
          ),
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
