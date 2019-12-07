import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:spruce/widgets/helpers/colors.dart';
import 'package:spruce/widgets/helpers/screensize.dart';
import 'package:spruce/widgets/helpers/upper_curve.dart';

import '../widgets/jobs/jobs.dart';
import '../widgets/ui_elements/logout_list_tile.dart';
import '../scoped-models/main.dart';
import 'job.dart';
import 'job_edit.dart';

Screen size;

class JobsPage extends StatefulWidget {
  final MainModel model;

  JobsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _JobsPageState();
  }
}

class _JobsPageState extends State<JobsPage> {
  PageController _pageController;
  int _page = 0;

  @override
  initState() {
    _pageController = PageController();
    widget.model.fetchJobs();
    super.initState();
  }

  Widget _buildSideDrawer(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Spruce Support'),
          ),
          Divider(),
          LogoutListTile()
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = Center(child: Text('No Jobs Found!'));
        if (model.displayedJobs.length > 0 && !model.isLoading) {
          content = Jobs();
        } else if (model.isLoading) {
          content = Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: model.fetchJobs,
          child: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('Spruce Support'),
        actions: <Widget>[
          ClipPath(
            clipper: UpperClipper(),
            child: Container(
              height: size.getWidthPx(240),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorCurve, colorCurveSecondary],
                ),
              ),
            ),
          ),
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.toggleDisplayMode();
                },
              );
            },
          )
        ],
      ),
      // body: _buildJobsList(),

      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          _buildJobsList(),
          JobEditPage(),
        ],
      ),

      // Set the bottom navigation bar
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(width: 7),
            IconButton(
              icon: Icon(
                Icons.home,
                size: 24.0,
              ),
              color: _page == 0
                  ? Theme.of(context).accentColor
                  : Theme.of(context).textTheme.caption.color,
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                size: 24.0,
                color: Theme.of(context).primaryColor,
              ),
              color: _page == 2
                  ? Theme.of(context).accentColor
                  : Theme.of(context).textTheme.caption.color,
              onPressed: () => _pageController.jumpToPage(0),
            ),
            IconButton(
              icon: Icon(
                Icons.list,
                size: 24.0,
              ),
              color: _page == 4
                  ? Theme.of(context).accentColor
                  : Theme.of(context).textTheme.caption.color,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
            ),
            SizedBox(width: 7),
          ],
        ),
        color: Theme.of(context).primaryColor,
        shape: CircularNotchedRectangle(),
      ),

      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        child: Icon(
          Icons.add,
        ),
        onPressed: () => _pageController.jumpToPage(1),
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
