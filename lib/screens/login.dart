import 'package:car_pool_project/services/config_system.dart';
import 'package:flutter/material.dart';
import 'package:car_pool_project/global.dart' as globals;

import '../constants.dart';
import '../models/user.dart';

// login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String ip = '';
  String username = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Sharing v1.0.0'),
        backgroundColor: Colors.pink,
        actions: <Widget>[
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
                        ));
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.grey.shade200,
            Colors.grey.shade200,
            Colors.grey.shade200,
          ], begin: Alignment.topLeft, end: Alignment.centerRight)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Head
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 100.0, horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 65,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Enter username and password for login",
                        style: TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
              ),
              // login input
              Expanded(
                flex: 4, // 5 defuel
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    // const EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextField(
                            onChanged: (value) {
                              username = value;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                hintText: "Username",
                                // hintStyle: TextStyle(),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.red.shade600,
                                ))),
                        const SizedBox(height: 20.0),
                        TextField(
                            obscureText: true,
                            onChanged: (value) {
                              password = value;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                hintText: "Password",
                                // hintStyle: TextStyle(),
                                prefixIcon: Icon(
                                  Icons.vpn_key,
                                  color: Colors.red.shade600,
                                ))),
                        //  for get passowod
                        Container(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(179.7, 0, 0, 0),
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
                                        decoration: TextDecoration.underline,
                                        fontStyle: FontStyle.italic),
                                  ))
                            ],
                          ),
                        )),
                        const SizedBox(height: 25),
                        // login button
                        Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                              ),
                              onPressed: () async {
                                // check login
                                User? u =
                                    await User.checkLogin(username, password);
                                // if success
                                if (u != null) {
                                  print("Go");
                                } else {
                                  print("Login Fail");
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text(
                                        'Error',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: const Text(
                                          'Incorrect username or password'),
                                      actions: <Widget>[
                                        TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.blueGrey,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Close',
                                            )),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
