import 'package:flutter/material.dart';

class StaffsTag extends StatelessWidget {
  final String staffs;

  StaffsTag(this.staffs);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(5.0)),
      child: Text(
        '\$$staffs',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
