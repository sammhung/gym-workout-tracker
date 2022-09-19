import 'package:flutter/material.dart';
import 'package:gym_workout_app/Providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

enum AuthMode {
  login,
  signup,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode authMode = AuthMode.signup;
  Map<String, String> userDetails = {
    "fName": "",
    "email": "",
    "password": "",
    "weight": "",
    "height": "",
  };
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    // Returns the input text
    Widget inputText(String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          text,
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 90.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Register / Login headline
                    Text(
                      authMode == AuthMode.login ? 'Login' : 'Register',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    // Spacing
                    const SizedBox(
                      height: 10,
                    ),
                    // First Name input
                    if (authMode == AuthMode.signup) inputText("First Name"),
                    if (authMode == AuthMode.signup)
                      TextFormField(
                        decoration: const InputDecoration(hintText: "John"),
                        onChanged: (value) => userDetails['fName'] = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                      ),
                    // Email input
                    inputText("Email"),
                    TextFormField(
                      decoration:
                          const InputDecoration(hintText: "johndoe@xxx.com"),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => userDetails['email'] = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty";
                        }
                        return null;
                      },
                    ),
                    // Password Input
                    inputText("Password"),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(hintText: "xxxxxxx"),
                      onChanged: (value) => userDetails['password'] = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty";
                        } else if (value.length <= 6) {
                          return "Password must be greater than 6 characters";
                        }
                        return null;
                      },
                    ),
                    // Weight Input
                    if (authMode == AuthMode.signup) inputText("Weight (KG)"),
                    if (authMode == AuthMode.signup)
                      TextFormField(
                        decoration: const InputDecoration(hintText: "60"),
                        onChanged: (value) => userDetails['weight'] = value,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          } else if (double.tryParse(value) == null) {
                            return "Must enter a number";
                          } else if (double.parse(value) >= 300 ||
                              double.parse(value) <= 20) {
                            return "Please enter a reasonable weight";
                          }
                          return null;
                        },
                      ),
                    // Height Input
                    if (authMode == AuthMode.signup) inputText("Height (CM)"),
                    if (authMode == AuthMode.signup)
                      TextFormField(
                        decoration: const InputDecoration(hintText: "183"),
                        onChanged: (value) => userDetails['height'] = value,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          } else if (double.tryParse(value) == null) {
                            return "Must enter a number";
                          } else if (double.parse(value) >= 250 ||
                              double.parse(value) <= 100) {
                            return "Please enter a reasonable height";
                          }
                          return null;
                        },
                      ),
                    // Spacing
                    const SizedBox(
                      height: 20,
                    ),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Register / Login Button
                        ElevatedButton(
                          onPressed: () async {
                            bool isValid = _formKey.currentState!.validate();
                            if (isValid) {
                              try {
                                // Create Account
                                if (authMode == AuthMode.signup) {
                                  await auth.signUp(userDetails);
                                }
                                // Login
                                else {
                                  await auth.login(userDetails['email']!,
                                      userDetails['password']!);
                                }
                                Navigator.of(context).pushReplacementNamed('/');
                              } catch (err) {
                                String message = "";
                                // Account already used
                                if (err.toString().contains(
                                    'The email address is already in use by another account')) {
                                  message =
                                      "Email already in use. Please try logging in.";
                                }
                                // Incorrect Password
                                else if (err.toString().contains(
                                    'The password is invalid or the user does not have a password.')) {
                                  message = "Incorrect account details.";
                                }
                                // User not found
                                else if (err.toString().contains(
                                    'There is no user record corresponding to this identifier')) {
                                  message =
                                      "User not found. Please create an account.";
                                }
                                // Any other error
                                else {
                                  message =
                                      "An error occured. Please try again later";
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(message),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            authMode == AuthMode.login ? "Login" : "Register",
                          ),
                        ),
                        // Change Authmode Button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (authMode == AuthMode.login) {
                                authMode = AuthMode.signup;
                              } else {
                                authMode = AuthMode.login;
                              }
                            });
                          },
                          child: Text(
                            authMode == AuthMode.login
                                ? "Or Sign Up Here"
                                : "Or Login Here",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
