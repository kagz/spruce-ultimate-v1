import 'package:scoped_model/scoped_model.dart';

import './connected_jobs.dart';

class MainModel extends Model with ConnectedJobsModel, UserModel, JobsModel, UtilityModel {
}
