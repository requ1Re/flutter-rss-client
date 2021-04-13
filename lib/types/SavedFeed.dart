// To parse this JSON data, do
//
//     final rssFeed = rssFeedFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webfeed/domain/rss_feed.dart';

List<SavedFeed> savedFeedFromJson(String str) =>
    List<SavedFeed>.from(json.decode(str).map((x) => SavedFeed.fromJson(x)));

String savedFeedToJson(List<SavedFeed> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SavedFeed {
  SavedFeed({
    this.id,
    this.url,
  });

  int id;
  String url;
  RssFeed loadedFeed;
  Key uniqueKey = UniqueKey();

  factory SavedFeed.fromJson(Map<String, dynamic> json) => SavedFeed(
        id: json["id"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
      };
}
