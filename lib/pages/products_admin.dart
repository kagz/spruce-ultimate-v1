import 'package:flutter/material.dart';

import './product_edit.dart';
import './product_list.dart';
import '../widgets/ui_elements/logout_list_tile.dart';
import '../scoped-models/main.dart';

class ProductsAdminPage extends StatelessWidget {
  final MainModel model;

  ProductsAdminPage(this.model);

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
          children: <Widget>[ProductListPage(model)],
        ),
      ),
    );
  }
}
