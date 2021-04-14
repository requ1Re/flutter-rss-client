// To parse this JSON data, do
//
//     final rssFeed = rssFeedFromJson(jsonString);

import 'dart:convert';

import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

List<SavedFeed> savedFeedFromJson(String str) => List<SavedFeed>.from(json.decode(str).map((x) => SavedFeed.fromJson(x)));

String savedFeedToJson(List<SavedFeed> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SavedFeed {
  SavedFeed({
    this.id,
    this.url,
    this.name,
    this.lastUpdate,
    this.xml
  }){
   if(this.name == null){
     this.name = this.url;
   }
   if(this.lastUpdate == null){
     updateDate();
   }
  }

  int id;
  String url;
  String name;
  RssFeed loadedFeed;
  String lastUpdate;
  String xml;

  Key uniqueKey = UniqueKey();

  factory SavedFeed.fromJson(Map<String, dynamic> json) => SavedFeed(
    id: json["id"],
    url: json["url"],
    name: json["name"],
    lastUpdate: json["lastUpdate"],
    xml: json["xml"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "name": name,
    "lastUpdate": lastUpdate,
    "xml": xml,
  };

  Future<void> update(BuildContext context) async {
    try {
      var response = await http.get(Uri.parse(this.url));
      if (response.statusCode == 200) {
        var rssFeed = RssFeed.parse(response.body);
        this.name = rssFeed.title;
        this.loadedFeed = rssFeed;
        this.xml = response.body;
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error while loading Feed #${this.id}: ' + err.toString(),
                style: TextStyle(color: Colors.white)
            ),
            backgroundColor: Colors.red
          )
      );
    }
    updateDate();
    print("[DEBUG] Feed update() called (" + this.name + ") - context: " + context.widget.toStringShort());
  }

  void updateDate(){
    this.lastUpdate = DateFormat().format(DateTime.now());
  }
}
