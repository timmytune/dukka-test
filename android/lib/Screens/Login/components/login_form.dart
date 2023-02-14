import 'package:flutter/material.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Signup/signup_screen.dart';
import '../../tracker/tracker_screen.dart';
import 'package:untitled/helpers.dart' as helpers;

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String _username = '';
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
              _username = username;
            },
            decoration: const InputDecoration(
              hintText: "Your username",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              onChanged: (password) {
                _password = password;
              },
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () {
                if (_password == '' || _username == '') {
                  showDialog(
                      context: context,
                      builder: (ctxt) => AlertDialog(
                            title: Text(
                                "You have to provide a username, email and password "),
                          ));
                  return;
                } else {
                  helpers.httpHelper('POST', '/api/token/', {
                    'username': _username,
                    'password': _password
                  }, {}, {}).then((res) => {
                        if (res == null)
                          {
                            showDialog(
                                context: context,
                                builder: (ctxt) => AlertDialog(
                                      title:
                                          Text('invalid data returned: $res'),
                                    ))
                          }
                        else if (res['access'] != null)
                          {
                            helpers.storageHelperSet(
                                'auth', 'token', res['access']),
                            helpers.storageHelperSet(
                                'auth', 'refresh', res['refresh']),
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const TrackerScreen();
                                },
                              ),
                            ),
                          }
                        else
                          {
                            print('GOT HERE'),
                            print(res),
                            showDialog(
                                context: context,
                                builder: (ctxt) => AlertDialog(
                                      title:
                                          Text('invalid username or password'),
                                    ))
                          }
                      });
                }
              },
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
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
