import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';
// import 'package:flutter/rendering.dart';

import './pages/auth.dart';
import './pages/jobs_admin.dart';
import './pages/jobs.dart';
import './pages/job.dart';
import './scoped-models/main.dart';
import './models/job.dart';
import './widgets/helpers/custom_route.dart';
import './shared/global_config.dart';

void main() {
  MapView.setApiKey(API_KEY);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('building main page');
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple),

        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : JobsPage(_model),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : JobsAdminPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => AuthPage(),
            );
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'job') {
            final String jobId = pathElements[2];
            final Job job =
                _model.allJobs.firstWhere((Job job) {
              return job.id == jobId;
            });
            return CustomRoute<bool>(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : JobPage(job),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : JobsPage(_model));
        },
      ),
    );
  }
}
