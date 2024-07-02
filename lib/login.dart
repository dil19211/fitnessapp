import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart'hide EmailAuthProvider;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'adminpanel.dart';
import 'const.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final ValueNotifier<bool> _obscureText = ValueNotifier(true);


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
    _obscureText.dispose();
    super.dispose();
  }
  void _showNoInternetToast() {
    Fluttertoast.showToast(
      msg: "No internet connection available",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _login() async {
    bool isConnected = await _isConnected();
    if (!isConnected) {
      _showNoInternetToast();
      return;
    }
  }
  Future<bool> _isConnected() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      return false;
    }

    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 4));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error checking internet connection: $e');
    }
    return false;
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
    //  backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [g1, g1], // Replace with your gradient colors

            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back to previous screen
              },
            ),
          ),
        ),
      ),
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 25.0),
                        filled: true,
                        hintText: "Email",
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(userIcon),
                        ),
                        fillColor: kWhiteColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
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
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscureText,
                      builder: (context, obscureText, child) {
                        return TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          obscureText: obscureText,
                          style: const TextStyle(color: kInputColor),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 25.0),
                            filled: true,
                            hintText: "Password",
                            prefixIcon: IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(keyIcon),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureText ? Icons.visibility : Icons.visibility_off,
                                color: kInputColor,
                              ),
                              onPressed: () {
                                _obscureText.value = !obscureText;
                              },
                            ),
                            fillColor: kWhiteColor,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorText: _showPasswordError || (_passwordController.text.isEmpty && hasErrors)
                                ? _passwordController.text.isEmpty ? 'Password is required' : 'Password must be at least 7 characters long'
                                : null,
                            errorStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onChanged: (_) {
                            _validatePassword();
                          },
                        );
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
                      onPressed: () async {
                        sendMail(recipientEmail: _emailController.text.toString(), mailMessage: 'Admin is sucessfuly logged in');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (BuildContext context) => admin(),
                          ),
                        );

                        // Validate fields
                        _login();
                        _validateFieldsAndSubmit();
                        if (!_showEmailError && !_showPasswordError) {
                          Future<User?> loginUsingEmailPassword(
                              { required String email,
                                required String password,
                                required BuildContext context}) async {
                            FirebaseAuth auth = FirebaseAuth.instance;
                            User? user;
                            try {
                              UserCredential userCredential = await auth.signInWithEmailAndPassword(
                                  email: email, password: password);
                              user = userCredential.user;
                              // sendMail(recipientEmail: _emailController.text.toString(),mailMessage: 'u are using gritfit!!!');

                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('selectedPage', 'login');

                            } on FirebaseAuthException catch (e) {


                              if (e.code == "user-not-found") {
                                Fluttertoast.showToast(msg: "No user found for that email");


                              }
                              else if(e.code == "wrong password"){
                                Fluttertoast.showToast(msg: "Invalid email or password");
                              }else{
                                Fluttertoast.showToast(msg: "Error! Invalid email or password ",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: Colors.redAccent,
                                    textColor: Colors.white,
                                    fontSize: 15
                                );
                              }
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    LoginPage(), ));
                              return user;
                            }
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  admin(),
                            ));
                            return user;
                          }
                          User? user=await loginUsingEmailPassword(
                              email: _emailController.text, password: _passwordController.text, context: context);
                          print(user);
                          // Access email and password using _emailController.text and _passwordController.text
                        }
                      },
                    ), SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async {

                        if (_emailController.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Please enter your email first",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.redAccent,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          // Handle forgot password action
                          print("Forgot Password button pressed");
                          sendMail(recipientEmail: _emailController.text.toString(), mailMessage: 'Your  psssword is [ agritfit123 ]');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: kWhiteColor, backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: kWhiteColor, width: 2),
                      ),
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(
                          color: kWhiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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




  // All validations pass, perform login or submit data
  // Access email and password using _emailController.text and _passwordController.text
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
  void sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    // change your email here
    String username = _emailController.text.toString();
    // change your password here
    String password = 'pzkzsdlrwxuisqye';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail '
      ..text = 'Message: $mailMessage';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail is sent on your account.'),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        print('error in sending email');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong ,cant send email'),
          ),
        );
      }
    }
  }
}