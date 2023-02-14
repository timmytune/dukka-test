import 'package:flutter/material.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import 'package:untitled/helpers.dart' as helpers;
import '../../Login/login_screen.dart';
import '../../tracker/tracker_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  String _username = '';
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onChanged: (username) {
              setState(() {
                _username = username;
              });
            },
            decoration: const InputDecoration(
              hintText: "Your Username",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.account_balance_wallet_rounded),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onChanged: (email) {
              setState(() {
                _email = email;
              });
            },
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            textInputAction: TextInputAction.done,
            obscureText: true,
            cursorColor: kPrimaryColor,
            onChanged: (password) {
              setState(() {
                _password = password;
              });
            },
            decoration: const InputDecoration(
              hintText: "Your password",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          ElevatedButton(
            onPressed: () {
              if (_email == '' || _password == '' || _username == '') {
                showDialog(
                    context: context,
                    builder: (ctxt) => AlertDialog(
                          title: Text(
                              "You have to provide a username, email and password "),
                        ));
                return;
              } else {
                helpers.httpHelper('POST', '/api/register/', {
                  'username': _username,
                  'email': _email,
                  'password': _password
                }, {}, {}).then((res) {
                  if (res == null) {
                    showDialog(
                        context: context,
                        builder: (ctxt) => AlertDialog(
                              title: Text('invalid data returned: $res'),
                            ));
                  } else if (res['access'] != null) {
                    helpers.storageHelperSet('auth', 'token', res['access']);
                    helpers.storageHelperSet('auth', 'refresh', res['refresh']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TrackerScreen();
                        },
                      ),
                    );
                  } else {
                    showDialog(
                        context: context,
                        builder: (ctxt) => AlertDialog(
                              title: Text(
                                  'email or username already exist, please proceed to login'),
                            ));
                  }
                });
              }
            },
            child: Text("Sign Up".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
