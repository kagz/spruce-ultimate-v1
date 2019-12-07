import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:spruce/widgets/helpers/screensize.dart';

import './staffs_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/job.dart';
import '../../scoped-models/main.dart';

class JobCard extends StatelessWidget {
  final Job job;
  Screen size;
  JobCard(this.job);

  Widget _buildTitleStaffsRow() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            child: TitleDefault(job.title.toUpperCase()),
          ),
          Flexible(
            child: SizedBox(
              width: 12.0,
            ),
          ),
          Flexible(
            child: SizedBox(
              width: 12.0,
            ),
          ),
          Flexible(
            child: StaffsTag(job.staffs.toString()),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.info),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  model.selectJob(job.id);
                  Navigator.pushNamed<bool>(context, '/job/' + job.id)
                      .then((_) => model.selectJob(null));
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 4.0,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      borderOnForeground: true,
      child: Container(
        height: size.getWidthPx(350),
        width: size.getWidthPx(330),
        child: Column(
          children: <Widget>[
            ClipRRect(
              // tag: job.id,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0)),
              child: FadeInImage(
                image: NetworkImage(job.image),
                height: 220,
                width: 389,
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/food.jpg'),
              ),
            ),
            _buildTitleStaffsRow(),
            SizedBox(
              height: 10.0,
            ),
            AddressTag(job.location.address),
            _buildActionButtons(context)
          ],
        ),
      ),
    );
  }
}
