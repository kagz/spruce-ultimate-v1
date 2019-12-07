import 'package:flutter/material.dart';

import './location_data.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final int staffs;
  final String image;
   final String date;
  final String imagePath;
  final bool isFavorite;
  final String clientname;
  final String userId;
  final LocationData location;

  Job(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.staffs,
      @required this.image,
       @required this.date,
      @required this.clientname,
      @required this.userId,
      @required this.location,
      @required this.imagePath,
      this.isFavorite = false});
}
