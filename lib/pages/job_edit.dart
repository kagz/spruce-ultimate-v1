import 'dart:io';

import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../widgets/helpers/ensure_visible.dart';
import '../widgets/form_inputs/location.dart';
import '../widgets/form_inputs/image.dart';
import '../models/job.dart';
import '../scoped-models/main.dart';
import '../models/location_data.dart';

class JobEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _JobEditPageState();
  }
}

class _JobEditPageState extends State<JobEditPage> {
  PageController _pageController;
  int _page = 0;

  @override
  initState() {
    _pageController = PageController();
    // widget.model.fetchJobs();
    super.initState();
  }

  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'staffs': null,
    'image': null,
     'clientname': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
   final _dateFocusNode = FocusNode();
   final _clientnameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _staffsFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
   final _dateTextController = TextEditingController();
  final _clientnameTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _staffsTextController = TextEditingController();

  Widget _buildTitleTextField(Job job) {
    if (job == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (job != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = job.title;
    } else if (job != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (job == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else {
      _titleTextController.text = '';
    }
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Job Title'),
        controller: _titleTextController,
        // initialValue: job == null ? '' : job.title,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 5) {
            return 'Title is required and should be 5+ characters long.';
          }
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Job job) {
    if (job == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (job != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = job.description;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        focusNode: _descriptionFocusNode,
        maxLines: 4,
        decoration: InputDecoration(labelText: 'Job Description'),
        // initialValue: job == null ? '' : job.description,
        controller: _descriptionTextController,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 10) {
            return 'Description is required and should be 10+ characters long.';
          }
        },
        onSaved: (String value) {
          _formData['description'] = value;
        },
      ),
    );
  }


  Widget _buildStaffsTextField(Job job) {
    if (job == null && _staffsTextController.text.trim() == '') {
      _staffsTextController.text = '';
    } else if (job != null && _staffsTextController.text.trim() == '') {
      _staffsTextController.text = job.staffs.toString();
    }
    return EnsureVisibleWhenFocused(
      focusNode: _staffsFocusNode,
      child: TextFormField(
        focusNode: _staffsFocusNode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Job Staffs'),
        controller: _staffsTextController,
        // initialValue: job == null ? '' : job.staffs.toString(),
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
            return 'Staffs is required and should be a number.';
          }
        },
      ),
    );
  }
  
  Widget _buildClientNameTextField(Job job) {

    if (job == null && _clientnameTextController.text.trim() == '') {
      _clientnameTextController.text = '';
    } else if (job != null &&
        _clientnameTextController.text.trim() == '') {
      _clientnameTextController.text = job.clientname;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _clientnameFocusNode,
      child: TextFormField(
        focusNode: _clientnameFocusNode,
        decoration: InputDecoration(labelText: 'Job Clientname'),
        // initialValue: job == null ? '' : job.description,
        controller: _clientnameTextController,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty ) {
            return 'clientname is required and should be 10+ characters long.';
          }
        },
        onSaved: (String value) {
          _formData['clientname'] = value;
        },
      ),
    );




  }


  Widget _buildDateTextField(Job job) {

    if (job == null && _dateTextController.text.trim() == '') {
      _dateTextController.text = '';
    } else if (job != null &&
        _clientnameTextController.text.trim() == '') {
      _clientnameTextController.text = job.date;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _clientnameFocusNode,
      child: TextFormField(
        focusNode: _dateFocusNode,
        decoration: InputDecoration(labelText: 'Job date'),
        // initialValue: job == null ? '' : job.description,
        controller: _dateTextController,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty ) {
            return 'date is required and should be 10+ characters long.';
          }
        },
        onSaved: (String value) {
          _formData['date'] = value;
        },
      ),
    );




  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () => _submitForm(
                    model.addJob,
                    model.updateJob,
                    model.selectJob,
                    model.selectedJobIndex),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Job job) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(job),
              _buildDescriptionTextField(job),
              _buildStaffsTextField(job),
               _buildDateTextField(job),
               _buildClientNameTextField(job),
              SizedBox(
                height: 10.0,
              ),
              LocationInput(_setLocation, job),
              SizedBox(height: 10.0),
              ImageInput(_setImage, job),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _setLocation(LocationData locData) {
    _formData['location'] = locData;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void _submitForm(
      Function addJob, Function updateJob, Function setSelectedJob,
      [int selectedJobIndex]) {
    if (!_formKey.currentState.validate() ||
        (_formData['image'] == null && selectedJobIndex == -1)) {
      return;
    }
    _formKey.currentState.save();
    if (selectedJobIndex == -1) {
      addJob(
         _dateTextController.text,
         _clientnameTextController.text,
              _titleTextController.text,
              _descriptionTextController.text,
              _formData['image'],
              int.parse(
                  _staffsTextController.text.replaceFirst(RegExp(r','), '.')),
              _formData['location'])
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/jobs')
              .then((_) => setSelectedJob(null));
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong'),
                  content: Text('Please try again!'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Okay'),
                    )
                  ],
                );
              });
        }
      });
    } else {
      updateJob(
         _dateTextController.text,
          _clientnameTextController.text,
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        int.parse(_staffsTextController.text.replaceFirst(RegExp(r','), '.')),
        _formData['location'],
      ).then((_) => Navigator.pushReplacementNamed(context, '/jobs')
          .then((_) => setSelectedJob(null)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedJob);
        return model.selectedJobIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Job'),
                ),
                body: pageContent,

                //bottom nav
              );
      },
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
