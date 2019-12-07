import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './job_edit.dart';
import '../scoped-models/main.dart';

//solo man jobs
class JobListPage extends StatefulWidget {
  final MainModel model;

  JobListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _JobListPageState();
  }
}

class _JobListPageState extends State<JobListPage> {
  @override
  initState() {
    widget.model.fetchJobs(onlyForUser: true, clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectJob(model.allJobs[index].id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return JobEditPage();
            },
          ),
        ).then((_) {
          model.selectJob(null);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.allJobs[index].title),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectJob(model.allJobs[index].id);
                  model.deleteJob();
                } else if (direction == DismissDirection.startToEnd) {
                  print('Swiped start to end');
                } else {
                  print('Other swiping');
                }
              },
              background: Container(color: Colors.red),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allJobs[index].image),
                    ),
                    title: Text(model.allJobs[index].title),
                    subtitle:
                        Text('\$${model.allJobs[index].staffs.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider()
                ],
              ),
            );
          },
          itemCount: model.allJobs.length,
        );
      },
    );
  }
}
