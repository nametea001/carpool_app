import 'package:car_pool_project/screens/post_screen.dart';
import 'package:car_pool_project/services/config_system.dart';
import 'package:flutter/material.dart';
import 'package:car_pool_project/global.dart' as globals;
import 'package:form_field_validator/form_field_validator.dart';
import '../constants.dart';
import '../models/user.dart';

// login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String ip = '';
  String username = "";
  String password = "";
  String confirmPassword = "";
  String email = "";

  bool _isFocusPassword = false;
  bool _isShowPassword = false;

  bool _isFocusConfirmPassword = false;
  bool _isShowConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Sharing v1.0.0'),
        backgroundColor: Colors.pink,
        actions: [
          // config Ip
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                if (globals.serverIP == '') {
                  globals.serverIP = await ConfigSystem.getServer();
                }
                await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Config Server IP'),
                          content: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.important_devices,
                                color: Colors.pink,
                                size: 50.0,
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: globals.serverIP,
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    //Do something with the user input.
                                    ip = value;
                                  },
                                  decoration: kTextFieldDecoration.copyWith(
                                      hintText: "Enter Server IP"),
                                ),
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Save'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                globals.serverIP = ip;
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                                child: Text('Close'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blueGrey,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        ));
              }),
          // about dev
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('About developer'),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.account_box,
                            color: Colors.pink,
                            size: 50.0,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Text("Nontakorn Konakin"),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.email,
                            color: Colors.pink,
                            size: 50.0,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Text("nontakorn.ko@ku.th"),
                          )
                        ],
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: Text('Close'),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.blueGrey,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        Tab(
                          text: 'Sign in',
                        ),
                        Tab(
                          text: 'Sing up',
                        ),
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - 200,
                      // padding: EdgeInsets.only(top: 30),
                      child: TabBarView(children: [
                        // tab login
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                              child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  username = value;
                                },
                                autofocus: true,
                                decoration: InputDecoration(
                                    labelText: "Username",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      // borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: Colors.pink,
                                    )),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                obscureText: true,
                                onChanged: (value) {
                                  password = value;
                                },
                                decoration: InputDecoration(
                                    labelText: "Password",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      // borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.vpn_key,
                                      color: Colors.pink,
                                    )),
                              ),
                              // forget pass bt
                              Container(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(179.7, 0, 0, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            "Forget your password ?",
                                            style: TextStyle(
                                                color: Colors.red.shade900,
                                                decoration:
                                                    TextDecoration.underline,
                                                fontStyle: FontStyle.italic),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                              //  login button
                              Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                    ),
                                    onPressed: () async {
                                      // check login
                                      User? u = await User.checkLogin(
                                          username, password);
                                      // if success
                                      if (u != null) {
                                        // ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PostScreen(
                                                    user: u,
                                                  )),
                                        );
                                        // Navigator.pushReplacement(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) => PostScreen(
                                        //         user: u,
                                        //       ),
                                        //     ));
                                      } else {
                                        print("Login Fail");
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'Incorrect username or password'),
                                            actions: [
                                              TextButton(
                                                  child: Text('Close'),
                                                  style: TextButton.styleFrom(
                                                    primary: Colors.white,
                                                    backgroundColor:
                                                        Colors.blueGrey,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  }),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 18),
                                      child: Text(
                                        "Sign in",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ))
                            ],
                          )),
                        ),

                        // tap SignUp
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  onChanged: (value) {
                                    username = value;
                                  },
                                  autofocus: true,
                                  validator: MultiValidator([
                                    RequiredValidator(
                                        errorText: "Please Input Username.")
                                  ]),
                                  decoration: InputDecoration(
                                      labelText: "Username",
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        // borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.person,
                                        color: Colors.pink,
                                      )),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Focus(
                                  onFocusChange: (bool focus) {
                                    setState(() {
                                      _isFocusPassword = !_isFocusPassword;
                                      _isShowPassword = false;
                                    });
                                  },
                                  child: TextFormField(
                                    obscureText: !_isShowPassword,
                                    onChanged: (value) {
                                      password = value;
                                    },
                                    validator: ((String? str) {
                                      if (str!.isEmpty) {
                                        return "Please Input Password";
                                      }
                                      if (password != confirmPassword) {
                                        return "Password and Confirm Password is not match";
                                      }
                                      return null;
                                    }),
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        // borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.vpn_key,
                                        color: Colors.pink,
                                      ),
                                      suffixIcon: IconButton(
                                          onPressed: _isFocusPassword
                                              ? () {
                                                  setState(() {
                                                    _isShowPassword =
                                                        !_isShowPassword;
                                                  });
                                                }
                                              : null,
                                          icon: _isFocusPassword
                                              ? visibility(_isShowPassword)
                                              : Icon(null)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Focus(
                                  onFocusChange: (bool focus) {
                                    setState(() {
                                      _isFocusConfirmPassword =
                                          !_isFocusConfirmPassword;
                                      _isShowConfirmPassword = false;
                                    });
                                  },
                                  child: TextFormField(
                                    obscureText: !_isShowConfirmPassword,
                                    onChanged: (value) {
                                      confirmPassword = value;
                                    },
                                    validator: ((String? str) {
                                      if (str!.isEmpty) {
                                        return "Please Input Password";
                                      }
                                      if (password != confirmPassword) {
                                        return "Password and Confirm Password is not match";
                                      }
                                      return null;
                                    }),
                                    // validator: MultiValidator([
                                    //   RequiredValidator(
                                    //       errorText:
                                    //           "Please Input Confirm Password."),
                                    // ]),
                                    decoration: InputDecoration(
                                      labelText: "Confirm Password",
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        // borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.vpn_key,
                                        color: Colors.pink,
                                      ),
                                      suffixIcon: IconButton(
                                          onPressed: _isFocusConfirmPassword
                                              ? () {
                                                  setState(() {
                                                    _isShowConfirmPassword =
                                                        !_isShowConfirmPassword;
                                                  });
                                                }
                                              : null,
                                          icon: _isFocusConfirmPassword
                                              ? visibility(
                                                  _isShowConfirmPassword)
                                              : Icon(null)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                TextFormField(
                                  validator: MultiValidator([
                                    RequiredValidator(
                                        errorText: "Please Input Email."),
                                    EmailValidator(
                                        errorText: "Email is Incorrect !")
                                  ]),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    email = value;
                                  },
                                  decoration: InputDecoration(
                                      labelText: "Email",
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        // borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.email,
                                        color: Colors.pink,
                                      )),
                                ),
                                //  register button
                                Container(
                                  padding: EdgeInsets.only(top: 30.0),
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                    ),
                                    onPressed: () async {
                                      formKey.currentState!.validate();
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 18),
                                      child: Text(
                                        "Sign in",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic matchPassword(String str) {
    if (str.isEmpty) {
      return "Please Input Password";
    }
    if (password != confirmPassword) {
      return "Password and Confirm Password is Incorrect";
    }
    return null;
  }

  Widget visibility(bool check) {
    if (check) {
      return Icon(Icons.visibility);
    } else {
      return Icon(
        Icons.visibility_off,
        color: Colors.grey,
      );
    }
  }
}
