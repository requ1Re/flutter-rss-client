import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleViewPage extends StatefulWidget {
  final RssItem item;
  final RssFeed feed;
  const ArticleViewPage({ Key key, this.item, this.feed }) : super(key: key);

  @override
  _ArticleViewPageState createState() => _ArticleViewPageState();
}

class _ArticleViewPageState extends State<ArticleViewPage> {
  final double horizontalPadding = 16;
  final double verticalPadding = 16;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF2e2f36),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding / 2),
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
                              Text(widget.feed.title, style: TextStyle(fontSize: 16))
                            ],
                          ),
                          onTap: () => {
                            Navigator.pop(context)
                          },
                        ),
                      ],
                    ),
                  ),
                  widget.item.content.images.isNotEmpty ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x54000000),
                            spreadRadius: 4,
                            blurRadius: 20,
                          ),
                        ]
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(widget.item.content.images.first),
                      ),
                    ),
                  ): Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                    child: _createChips(widget.item.categories),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: widget.item.pubDate != null ? Text(Jiffy(widget.item.pubDate, "E, dd MMM yyyy HH:mm:ss zzz").yMMMMEEEEdjm.toUpperCase()) : null,
                  ),
                  Divider(indent: horizontalPadding, endIndent: horizontalPadding, thickness: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Text(widget.item.title, style: TextStyle(fontSize: 26, color: Theme.of(context).textTheme.bodyText1.color, decoration: TextDecoration.none)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: verticalPadding, left: horizontalPadding, right: horizontalPadding),
                    child: Html(
                      style: {
                        "*": Style(
                          color: Theme.of(context).textTheme.bodyText2.color, 
                          fontSize: FontSize.large, 
                          padding: EdgeInsets.symmetric(vertical: verticalPadding / 2), 
                          margin: EdgeInsets.zero
                        ),
                        "a": Style(color: Theme.of(context).textTheme.subtitle1.color)
                      },
                      data: widget.item.description,
                      onLinkTap: (link) async {
                        await launch(link);
                      }
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      primary: Color(0xFF8185a3),
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await launch(widget.item.link);
                    }, 
                    icon: Icon(Icons.open_in_browser), 
                    label: Text("OPEN ARTICLE IN BROWSER")
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }

  Widget _createChips(List<RssCategory> categories) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8, 
          children: categories.map((e) => new Chip(label: Text(e.value, style: TextStyle(color: Colors.white)), 
          backgroundColor: Color(0xFF8185a3))).toList()
        ),
      );
  }
}