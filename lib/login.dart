import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'adminpanel.dart';
import 'const.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _showEmailError = false;
  bool _showPasswordError = false;
  bool _buttonEnabled = true; // Initialize to true

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final value = _emailController.text;
    setState(() {
      _showEmailError = value.isEmpty ||
          !RegExp(
            r'^[a-z]+[a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          ).hasMatch(value);
      _updateButtonState();
    });
  }

  void _validatePassword() {
    final value = _passwordController.text;
    setState(() {
      _showPasswordError = value.isEmpty || value.length < 7;
      _updateButtonState();
    });
  }

  void _updateButtonState() {
    setState(() {
      _buttonEnabled = !_showEmailError && !_showPasswordError;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool hasErrors = _showEmailError || _showPasswordError;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _emailFocus.unfocus();
          _passwordFocus.unfocus();
        },
        child: Container(
          height: double.maxFinite,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [g1, g2],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(size.height * 0.030),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 25),
                    Image.asset(image1),
                    Text(
                      "Welcome Back!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: kWhiteColor.withOpacity(0.7),
                      ),
                    ),
                    const Text(
                      "Please, Log In.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                        color: kWhiteColor,
                      ),
                    ),
                    SizedBox(height: size.height * 0.024),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: kInputColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                        filled: true,
                        hintText: "Email",
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(userIcon),
                        ),
                        fillColor: kWhiteColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        errorText: _showEmailError || (_emailController.text.isEmpty && hasErrors)
                            ? _emailController.text.isEmpty ? 'Email is required' : 'Enter a valid email'
                            : null,
                        errorStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onChanged: (_) {
                        _validateEmail();
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: true,
                      style: const TextStyle(color: kInputColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                        filled: true,
                        hintText: "Password",
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(keyIcon),
                        ),
                        fillColor: kWhiteColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        errorText: _showPasswordError || (_passwordController.text.isEmpty && hasErrors)
                            ? _passwordController.text.isEmpty ? 'Password is required' : 'Password must be at least 7 characters long'
                            : null,
                        errorStyle: TextStyle(fontWeight: FontWeight.bold),

                      ),
                      onChanged: (_) {
                        _validatePassword();
                      },
                    ),
                    SizedBox(height: 15),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: size.height * 0.080,
                        decoration: BoxDecoration(
                          color: _buttonEnabled ? kButtonColor : kButtonDisabledColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      onPressed: () {
                        // Validate fields
                        _validateFieldsAndSubmit();
                        if (!_showEmailError && !_showPasswordError) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>  admin(),
                          ));
                          // All validations pass, perform login or submit data
                          // Access email and password using _emailController.text and _passwordController.text
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _validateFieldsAndSubmit() {
    // Validate email and password
    _validateEmail();
    _validatePassword();

    // Check if there are no errors
    if (!_showEmailError && !_showPasswordError) {
      // All validations pass, perform login or submit data
      // Access email and password using _emailController.text and _passwordController.text
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
    }
  }

}
