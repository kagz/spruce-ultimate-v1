import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './job_card.dart';
import '../../models/job.dart';
import '../../scoped-models/main.dart';

class Jobs extends StatelessWidget {
  Widget _buildJobList(List<Job> jobs) {
    Widget jobCards;
    if (jobs.length > 0) {
      jobCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            JobCard(jobs[index]),
        itemCount: jobs.length,
      );
    } else {
      jobCards = Container();
    }
    return jobCards;
  }

  @override
  Widget build(BuildContext context) {
    print('[Jobs Widget] build()');
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model) {
      return  _buildJobList(model.displayedJobs);
    },);
  }
}
