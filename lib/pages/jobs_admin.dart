import 'package:flutter/material.dart';

import './job_edit.dart';
import './job_list.dart';
import '../widgets/ui_elements/logout_list_tile.dart';
import '../scoped-models/main.dart';

class JobsAdminPage extends StatelessWidget {
  final MainModel model;

  JobsAdminPage(this.model);

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Spruce Support'),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('All Jobs'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Divider(),
          LogoutListTile()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text('Manage Jobs'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.list),
                text: 'Posted Jobs',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[JobListPage(model)],
        ),
      ),
    );
  }
}
