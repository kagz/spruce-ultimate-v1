import 'dart:async';

import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';

import '../widgets/ui_elements/title_default.dart';
import '../widgets/jobs/job_fab.dart';
import '../models/job.dart';

class JobPage extends StatelessWidget {
  final Job job;

  JobPage(this.job);

  void _showMap() {
    final List<Marker> markers = <Marker>[
      Marker('position', 'Position', job.location.latitude,
          job.location.longitude)
    ];
    final cameraPosition = CameraPosition(
        Location(job.location.latitude, job.location.longitude), 14.0);
    final mapView = MapView();
    mapView.show(
        MapOptions(
            initialCameraPosition: cameraPosition,
            mapViewType: MapViewType.normal,
            title: 'Job Location'),
        toolbarActions: [
          ToolbarAction('Close', 1),
        ]);
    mapView.onToolbarAction.listen((int id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
    mapView.onMapReady.listen((_) {
      mapView.setMarkers(markers);
    });
  }

  Widget _buildAddressStaffsRow(String address, int staffs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: _showMap,
          child: Text(
            address,
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          '\$' + staffs.toString(),
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Back button pressed!');
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(job.title),
        // ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 256.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(job.title),
                background: Hero(
                  tag: job.id,
                  child: FadeInImage(
                    image: NetworkImage(job.image),
                    height: 300.0,
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/food.jpg'),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    child: TitleDefault(job.title),
                  ),
                  _buildAddressStaffsRow(
                      job.location.address, job.staffs),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      job.description,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        floatingActionButton: JobFAB(job),
      ),
    );
  }
}
