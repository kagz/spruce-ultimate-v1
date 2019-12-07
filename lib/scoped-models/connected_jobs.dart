import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:spruce/shared/global_config.dart';

import '../models/job.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/location_data.dart';

class ConnectedJobsModel extends Model {
  List<Job> _jobs = [];
  String _selJobId;
  User _authenticatedUser;
  bool _isLoading = false;
}

class JobsModel extends ConnectedJobsModel {
  bool _showFavorites = false;

  List<Job> get allJobs {
    return List.from(_jobs);
  }

  List<Job> get displayedJobs {
    if (_showFavorites) {
      return _jobs.where((Job job) => job.isFavorite).toList();
    }
    return List.from(_jobs);
  }

  int get selectedJobIndex {
    return _jobs.indexWhere((Job job) {
      return job.id == _selJobId;
    });
  }

  String get selectedJobId {
    return _selJobId;
  }

  Job get selectedJob {
    if (selectedJobId == null) {
      return null;
    }

    return _jobs.firstWhere((Job job) {
      return job.id == _selJobId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-kamagera-aa372.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addJob(String title, String date,String description,  String clientname,File image,
      int staffs, LocationData locData) async {
    _isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);

    if (uploadData == null) {
      print('Upload failed!');
      return false;
    }

    final Map<String, dynamic> jobData = {
      'title': title,
      'description': description,
      'staffs': staffs,
      'date':date,
      'clientname': clientname,
      'userId': _authenticatedUser.id,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      // 'loc_lat': locData.latitude,
      // 'loc_lng': locData.longitude,
      'location': locData.address
    };
    try {
      final http.Response response = await http.post(
          '$CRUD_ENDPOINT/jobs.json?auth=${_authenticatedUser.token}',
          body: json.encode(jobData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Job newJob = Job(
          id: responseData['name'],
          title: title,
          date:date,
          description: description,
          image: uploadData['imageUrl'],
          imagePath: uploadData['imagePath'],
          staffs: staffs,
          location: locData,
          clientname: clientname,
          userId: _authenticatedUser.id);
      _jobs.add(newJob);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateJob(String title, String description, String clientname,File image,
      int staffs, LocationData locData) async {
    _isLoading = true;
    notifyListeners();
    String imageUrl = selectedJob.image;
    String imagePath = selectedJob.imagePath;
    if (image != null) {
      final uploadData = await uploadImage(image);

      if (uploadData == null) {
        print('Upload failed!');
        return false;
      }

      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'staffs': staffs,
      // 'loc_lat': locData.latitude,
      // 'loc_lng': locData.longitude,
      'location': locData.address,
      'clientName': clientname,
      'userId': selectedJob.userId
    };
    try {
      await http.put(
          '$CRUD_ENDPOINT/jobs/${selectedJob.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));
      _isLoading = false;
      final Job updatedJob = Job(
          id: selectedJob.id,
          title: title,
          description: description,
          image: imageUrl,
          imagePath: imagePath,
          staffs: staffs,
          location: locData,
          clientname: clientname,
          userId: selectedJob.userId);
      _jobs[selectedJobIndex] = updatedJob;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteJob() {
    _isLoading = true;
    final deletedJobId = selectedJob.id;
    _jobs.removeAt(selectedJobIndex);
    _selJobId = null;
    notifyListeners();
    return http
        .delete(
            '$CRUD_ENDPOINT/jobs/$deletedJobId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchJobs({onlyForUser = false, clearExisting = false}) {
    _isLoading = true;
    if (clearExisting) {
      _jobs = [];
    }

    notifyListeners();
    return http
        .get('$CRUD_ENDPOINT/jobs.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Job> fetchedJobList = [];
      final Map<String, dynamic> jobListData = json.decode(response.body);
       print('hapa tumebeba jobzz $jobListData'); 
      if (jobListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      jobListData.forEach((String jobId, dynamic jobData) {
        final Job job = Job(
            id: jobId,
            date:jobData['date'],
            title: jobData['title'],
            description: jobData['description'],
            image: jobData['imageUrl'],
            imagePath: jobData['imagePath'],
            staffs: jobData['staffs'],
            location: LocationData(
                address: jobData['location'],
                // latitude: jobData['loc_lat'],
                // longitude: jobData['loc_lng']
                
                ),
            clientname: jobData['clientname'],
            userId: jobData['userId'],
            isFavorite: jobData['wishlistUsers'] == null
                ? false
                : (jobData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));

                 print('hapa tumebeba jobs $jobData');     
        fetchedJobList.add(job);
      });
      _jobs = onlyForUser
          ? fetchedJobList.where((Job job) {
              return job.userId == _authenticatedUser.id;
            }).toList()
          : fetchedJobList;
      _isLoading = false;
      notifyListeners();
      _selJobId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleJobFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedJob.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Job updatedJob = Job(
        id: selectedJob.id,
        title: selectedJob.title,
         date: selectedJob.date,
        description: selectedJob.description,
        staffs: selectedJob.staffs,
        image: selectedJob.image,
        imagePath: selectedJob.imagePath,
        location: selectedJob.location,
        clientname: selectedJob.clientname,
        userId: selectedJob.userId,
        isFavorite: newFavoriteStatus);
    _jobs[selectedJobIndex] = updatedJob;
    notifyListeners();
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          '$CRUD_ENDPOINT/jobs/${selectedJob.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          '$CRUD_ENDPOINT/jobs/${selectedJob.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Job updatedJob = Job(
          id: selectedJob.id,
          title: selectedJob.title,
           date: selectedJob.date,
          description: selectedJob.description,
          staffs: selectedJob.staffs,
          image: selectedJob.image,
          imagePath: selectedJob.imagePath,
          location: selectedJob.location,
          clientname: selectedJob.clientname,
          userId: selectedJob.userId,
          isFavorite: !newFavoriteStatus);
      _jobs[selectedJobIndex] = updatedJob;
      notifyListeners();
    }
    _selJobId = null;
  }

  void selectJob(String jobId) {
    _selJobId = jobId;
    if (jobId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedJobsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        //https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCa2VuBK_54uSIygqegmguYVJiaCk9gliU',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      //https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCa2VuBK_54uSIygqegmguYVJiaCk9gliU',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    //  print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('clientname', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String clientName = prefs.getString('clientName');
      final String userId = prefs.getString('userId');
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: clientName, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    _selJobId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('clientname');
    prefs.remove('userId');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

class UtilityModel extends ConnectedJobsModel {
  bool get isLoading {
    return _isLoading;
  }
}
