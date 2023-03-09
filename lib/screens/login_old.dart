import 'package:car_pool_project/screens/post_screen.dart';
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
  bool _isLogin = true;
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
                        ));
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 80.0,
              ),
              child: Container(
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _isLogin
                                ? null
                                : () {
                                    setState(() {
                                      _isLogin = true;
                                    });
                                  },
                            child: const Text("Login"),
                            // style: TextButton.styleFrom(),
                          ),
                          SizedBox(
                            width: 30.0,
                          ),
                          TextButton(
                              onPressed: _isLogin
                                  ? () {
                                      setState(() {
                                        _isLogin = false;
                                      });
                                    }
                                  : null,
                              child: const Text("Sign Up")),
                        ],
                      ),
                    ]),
              ),
            ),
            _isLogin
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 30.0,
                    ),
                    child: Container(
                      // width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                              onChanged: (value) {
                                username = value;
                              },
                              autofocus: true,
                              validator: (String? string) {},
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  hintText: "Username",
                                  // hintStyle: TextStyle(),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.red.shade600,
                                  ))),
                          const SizedBox(height: 20.0),
                          TextFormField(
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
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PostScreen(
                                                user: u,
                                              )),
                                    );
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
                  
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 30.0,
                    ),
                    child: Container(
                      // width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                              onChanged: (value) {
                                username = value;
                              },
                              autofocus: true,
                              validator: (String? string) {},
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  hintText: "Username",
                                  // hintStyle: TextStyle(),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.red.shade600,
                                  ))),
                          const SizedBox(height: 20.0),
                          TextFormField(
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
                          const SizedBox(height: 20.0),
                          TextFormField(
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
                                  hintText: "Confirm Password",
                                  // hintStyle: TextStyle(),
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: Colors.red.shade600,
                                  ))),
                          //  for get passowod
                          const SizedBox(height: 25),
                          // login button
                          Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                ),
                                onPressed: () async {},
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Text(
                                    "Singup",
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
          ],
        ),
      ),
    );
  }
}
