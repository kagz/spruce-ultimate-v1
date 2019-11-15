import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:spruce/models/auth.dart';
import 'package:spruce/scoped-models/main.dart';
import 'package:spruce/widgets/helpers/boxfield.dart';
import 'package:spruce/widgets/helpers/colors.dart';
import 'package:spruce/widgets/helpers/screensize.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passFocusNode = FocusNode();
  AuthMode _authMode = AuthMode.Signup;
  FocusNode _confirmPassFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Screen size;

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: true,
        body: Stack(children: <Widget>[
          ClipPath(
              clipper: BottomShapeClipper(),
              child: Container(
                color: colorCurve,
              )),
          SingleChildScrollView(
            child: SafeArea(
              top: true,
              bottom: false,
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: size.getWidthPx(20),
                    vertical: size.getWidthPx(20)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: colorCurve,
                            ),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          SizedBox(width: size.getWidthPx(10)),
                          _signUpGradientText(),
                        ],
                      ),
                      SizedBox(height: size.getWidthPx(10)),
                      _textAccount(),
                      SizedBox(height: size.getWidthPx(30)),
                      registerFields()
                    ]),
              ),
            ),
          )
        ]));
  }

  RichText _textAccount() {
    return RichText(
      text: TextSpan(
          text: "registed already? ",
          children: [
            TextSpan(
              style: TextStyle(color: Colors.deepOrange),
              text: 'Login here',
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.pop(context),
            )
          ],
          style: TextStyle(
              fontFamily: 'Exo2', color: Colors.black87, fontSize: 16)),
    );
  }

  GradientText _signUpGradientText() {
    return GradientText('Register',
        gradient: LinearGradient(colors: [
          Color.fromRGBO(97, 6, 165, 1.0),
          Color.fromRGBO(45, 160, 240, 1.0)
        ]),
        style: TextStyle(
            fontFamily: 'Exo2', fontSize: 36, fontWeight: FontWeight.bold));
  }

  BoxField _emailWidget() {
    return BoxField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        hintText: "Enter email",
        lableText: "Email",
        obscureText: false,
        onSaved: (String value) {
          _formData['email'] = value;
        },
        onFieldSubmitted: (String value) {
          FocusScope.of(context).requestFocus(_passFocusNode);
        },
        icon: Icons.email,
        iconColor: colorCurve);
  }

  BoxField _passwordWidget() {
    return BoxField(
        controller: _passwordController,
        focusNode: _passFocusNode,
        hintText: "Enter Password",
        lableText: "Password",
        obscureText: true,
        icon: Icons.lock_outline,
        onSaved: (String value) {
          _formData['password'] = value;
        },
        iconColor: colorCurve);
  }

  BoxField _confirmPasswordWidget() {
    return BoxField(

        ///controller: _confirmPasswordController,
        focusNode: _confirmPassFocusNode,
        hintText: "Enter Confirm Password",
        lableText: "Confirm Password",
        obscureText: true,
        icon: Icons.lock_outline,
        validator: (String value) {
          if (_passwordController.text != value &&
              _authMode == AuthMode.Signup) {
            return 'Passwords do not match.';
          }
        },
        iconColor: colorCurve);
  }

  GestureDetector socialCircleAvatar(String assetIcon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        maxRadius: size.getWidthPx(20),
        backgroundColor: Colors.white,
        child: Image.asset(assetIcon),
      ),
    );
  }

  ///
  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;
    successInformation = await authenticate(
        _formData['email'], _formData['password'], _authMode);
    if (successInformation['success']) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An Error Occurred!'),
            content: Text(successInformation['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  ///
  registerFields() => Container(
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // _nameWidget(),
                _emailWidget(),
                _passwordWidget(),
                _confirmPasswordWidget(),

                ScopedModelDescendant<MainModel>(
                  builder:
                      (BuildContext context, Widget child, MainModel model) {
                    return model.isLoading
                        ? CircularProgressIndicator()
                        : Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.getWidthPx(20),
                                horizontal: size.getWidthPx(16)),
                            width: size.getWidthPx(200),
                            child: RaisedButton(
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              padding: EdgeInsets.all(size.getWidthPx(12)),
                              child: Text(
                                "SIGNUP",
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    color: Colors.white,
                                    fontSize: 20.0),
                              ),
                              color: colorCurve,
                              onPressed: () => _submitForm(model.authenticate),
                            ),
                          );
                  },
                ),
              ],
            )),
      );
}
