// To parse this JSON data, do
//
//     final rssFeed = rssFeedFromJson(jsonString);

import 'dart:convert';

import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/cupertino.dart';

List<SavedFeed> savedFeedFromJson(String str) => List<SavedFeed>.from(json.decode(str).map((x) => SavedFeed.fromJson(x)));

String savedFeedToJson(List<SavedFeed> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SavedFeed {
  SavedFeed({
    this.id,
    this.url,
    this.name,
    this.offlineAvailability = false
  }){
   if(this.name == null){
     this.name = this.url;
   }
  }

  int id;
  String url;
  String name;
  RssFeed loadedFeed;
  bool offlineAvailability;
  Key uniqueKey = UniqueKey();

  factory SavedFeed.fromJson(Map<String, dynamic> json) => SavedFeed(
    id: json["id"],
    url: json["url"],
    name: json["name"],
    offlineAvailability: json["offlineAvailability"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "name": name,
    "offlineAvailability": offlineAvailability,
  };
}
