import 'package:car_pool_project/screens/post_screen.dart';
import 'package:car_pool_project/services/config_system.dart';
import 'package:flutter/material.dart';
import 'package:car_pool_project/global.dart' as globals;
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import '../constants.dart';
import '../models/user.dart';

// login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  String ip = '';
  String username = "";
  String password = "";
  String confirmPassword = "";
  User userSignUp = User();

  bool _isFocusPassword = false;
  bool _isShowPassword = false;

  bool _isFocusConfirmPassword = false;
  bool _isShowConfirmPassword = false;
  bool _isSignIn = false;
  bool _isSingUp = false;

  FocusNode _focusNodeUsername = FocusNode();
  FocusNode _focusNodePassword = FocusNode();
  FocusNode _focusNodeSingUpUsername = FocusNode();
  FocusNode _focusNodeSingUpPassword = FocusNode();
  FocusNode _focusNodeSingUpConfirmPassword = FocusNode();
  FocusNode _focusNodeSingUpEmail = FocusNode();
  FocusNode _focusNodeSingUpFirstName = FocusNode();
  FocusNode _focusNodeSingUpLastName = FocusNode();

  TextEditingController _passwordController = TextEditingController();

  String sex = "Male";

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(vsync: this, length: 2);
    //loading posts
  }

  @override
  void dispose() {
    super.dispose();
    _focusNodeUsername.dispose();
    _focusNodePassword.dispose();
    _focusNodeSingUpUsername.dispose();
    _focusNodeSingUpPassword.dispose();
    _focusNodeSingUpConfirmPassword.dispose();
    _focusNodeSingUpEmail.dispose();
    _focusNodeSingUpFirstName.dispose();
    _focusNodeSingUpLastName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNodeUsername.unfocus();
        _focusNodePassword.unfocus();
        _focusNodeSingUpUsername.unfocus();
        _focusNodeSingUpPassword.unfocus();
        _focusNodeSingUpConfirmPassword.unfocus();
        _focusNodeSingUpEmail.unfocus();
        _focusNodeSingUpFirstName.unfocus();
        _focusNodeSingUpLastName.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ride Sharing v1.0.0'),
          backgroundColor: Colors.pink,
          actions: [
            // config Ip
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  if (globals.serverIP == '') {
                    globals.serverIP = await ConfigSystem.getServer();
                  }
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text('Config Server IP'),
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
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  globals.serverIP = ip;
                                  Navigator.pop(context);
                                },
                                child: const Text('Save'),
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blueGrey,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Close')),
                            ],
                          ));
                }),
            // about dev
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('About developer'),
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
                            const Icon(
                              Icons.email,
                              color: Colors.pink,
                              size: 50.0,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Expanded(
                              child: Text("nontakorn.ko@ku.th"),
                            )
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.blueGrey,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.8,
                child: Image.asset("assets/icons/android-chrome-512x512.png"),
              ),
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
                        height: MediaQuery.of(context).size.height - 100,
                        // padding: EdgeInsets.only(top: 30),
                        child: TabBarView(
                            // controller: ,
                            children: [
                              // tab login
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                    key: formKey1,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          focusNode: _focusNodeUsername,
                                          onChanged: (value) {
                                            username = value;
                                          },
                                          autofocus: true,
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
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        TextFormField(
                                          focusNode: _focusNodePassword,
                                          obscureText: true,
                                          controller: _passwordController,
                                          onChanged: (value) {
                                            password = value;
                                          },
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
                                              )),
                                        ),
                                        // forget pass bt
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                179.7, 0, 0, 0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                    onPressed: () {},
                                                    child: Text(
                                                      "Forget your password ?",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .red.shade900,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                        //  login button
                                        _isSignIn
                                            ? _loadingSingin()
                                            : Container(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.pink,
                                                  ),
                                                  onPressed: () async {
                                                    setState(() {
                                                      _isSignIn = true;
                                                    });
                                                    // check login
                                                    User? u =
                                                        await User.checkLogin(
                                                            username, password);

                                                    setState(() {
                                                      _isSignIn = false;
                                                    });
                                                    // if success
                                                    if (u != null) {
                                                      final prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      await prefs.setString(
                                                          'jwt',
                                                          u.jwt.toString());
                                                      await prefs.setInt(
                                                          "user_id", u.id ?? 0);
                                                      await prefs.setInt(
                                                          "start_province_id",
                                                          prefs.getInt(
                                                                  'start_province_id') ??
                                                              1);

                                                      _passwordController
                                                          .clear();
                                                      // ignore: use_build_context_synchronously
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    PostScreen(
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
                                                      // ignore: use_build_context_synchronously
                                                      await showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'Error'),
                                                          content: const Text(
                                                              'Incorrect username or password'),
                                                          actions: [
                                                            TextButton(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blueGrey,
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: const Text(
                                                                    'Close')),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 18),
                                                    child: Text(
                                                      "Sign in",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                  ),
                                                )),
                                      ],
                                    )),
                              ),

                              // tap SignUp
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                  key: formKey2,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        focusNode: _focusNodeSingUpUsername,
                                        onSaved: (newValue) {
                                          userSignUp.username = newValue;
                                        },
                                        autofocus: true,
                                        validator: MultiValidator([
                                          RequiredValidator(
                                              errorText:
                                                  "Please Input Username")
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
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      Focus(
                                        onFocusChange: (bool focus) {
                                          setState(() {
                                            _isFocusPassword =
                                                !_isFocusPassword;
                                            _isShowPassword = false;
                                          });
                                        },
                                        child: TextFormField(
                                          focusNode: _focusNodeSingUpPassword,
                                          obscureText: !_isShowPassword,
                                          onChanged: (value) {
                                            password = value;
                                          },
                                          onSaved: (newValue) {
                                            password = newValue!;
                                          },
                                          validator: (String? str) {
                                            if (str!.isEmpty) {
                                              return "Please Input Password";
                                            }
                                            if (password != confirmPassword) {
                                              return "Password and Confirm Password is not match";
                                            }
                                            return null;
                                          },
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
                                                    ? visibility(
                                                        _isShowPassword)
                                                    : const Icon(null)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
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
                                          focusNode:
                                              _focusNodeSingUpConfirmPassword,
                                          obscureText: !_isShowConfirmPassword,
                                          onChanged: (value) {
                                            confirmPassword = value;
                                          },
                                          validator: (String? str) {
                                            if (str!.isEmpty) {
                                              return "Please Input Confirm Password";
                                            }
                                            if (password != confirmPassword) {
                                              return "Password and Confirm Password is not match";
                                            }
                                            return null;
                                          },
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
                                                onPressed:
                                                    _isFocusConfirmPassword
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
                                                    : const Icon(null)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      TextFormField(
                                        focusNode: _focusNodeSingUpEmail,
                                        validator: MultiValidator([
                                          RequiredValidator(
                                              errorText: "Please Input Email."),
                                          EmailValidator(
                                              errorText: "Email is Incorrect !")
                                        ]),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        // onChanged: (value) {
                                        //   email = value;
                                        // },
                                        onSaved: (newValue) {
                                          userSignUp.email = newValue;
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
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      TextFormField(
                                        focusNode: _focusNodeSingUpFirstName,
                                        // onChanged: (value) {
                                        //   username = value;
                                        // },
                                        onSaved: (newValue) {
                                          userSignUp.firstName = newValue;
                                        },
                                        validator: MultiValidator([
                                          RequiredValidator(
                                              errorText:
                                                  "Please Input First name.")
                                        ]),
                                        decoration: InputDecoration(
                                            labelText: "First name",
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              // borderSide: BorderSide.none,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.edit_note,
                                              color: Colors.pink,
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      TextFormField(
                                        focusNode: _focusNodeSingUpLastName,
                                        // onChanged: (value) {
                                        //   username = value;
                                        // },
                                        onSaved: (newValue) {
                                          userSignUp.lastName = newValue;
                                        },
                                        validator: MultiValidator([
                                          RequiredValidator(
                                              errorText:
                                                  "Please Input Last name.")
                                        ]),
                                        decoration: InputDecoration(
                                            labelText: "Last name",
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              // borderSide: BorderSide.none,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.edit_note,
                                              color: Colors.pink,
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Text("Sex"),
                                          const Icon(
                                            Icons.man,
                                            color: Colors.blue,
                                            size: 35,
                                          ),
                                          SizedBox(
                                            width: 30,
                                            child: RadioListTile(
                                                value: "Male",
                                                groupValue: sex,
                                                onChanged: ((value) {
                                                  setState(() {
                                                    sex = value.toString();
                                                    userSignUp.sex = sex;
                                                  });
                                                })),
                                          ),
                                          const Text("Male"),
                                          SizedBox(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) -
                                                140,
                                          ),
                                          const Icon(
                                            Icons.woman,
                                            color: Colors.pink,
                                            size: 35,
                                          ),
                                          SizedBox(
                                            width: 30,
                                            child: RadioListTile(
                                                value: "Famale",
                                                groupValue: sex,
                                                onChanged: ((value) {
                                                  setState(() {
                                                    sex = value.toString();
                                                    userSignUp.sex = sex;
                                                  });
                                                })),
                                          ),
                                          const Text("Famale"),
                                        ],
                                      ),
                                      //  register button
                                      _isSingUp
                                          ? _loadingSingin()
                                          : Container(
                                              padding: const EdgeInsets.only(
                                                  top: 30.0),
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.pink,
                                                ),
                                                onPressed: () async {
                                                  userSignUp.sex = sex;
                                                  if (formKey2.currentState!
                                                          .validate() &&
                                                      password ==
                                                          confirmPassword) {
                                                    formKey2.currentState!
                                                        .save();

                                                    setState(() {
                                                      _isSingUp = true;
                                                    });
                                                    User? u = await User.signUp(
                                                        userSignUp, password);
                                                    setState(() {
                                                      _isSingUp = false;
                                                    });
                                                    if (u != null) {
                                                      showAlerRegisterSuccess();
                                                    } else {
                                                      showAlerRegisterFail();
                                                    }
                                                  }
                                                  formKey2.currentState?.reset;
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 18),
                                                  child: Text(
                                                    "Sign up",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      // TextButton(
                                      //     onPressed: () {}, child: Text("gggg"))
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
      ),
    );
  }

  void showAlerRegisterSuccess() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Success'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("ดำเดินการสำเร็จ"),
                  ],
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
              ],
            ));
  }

  void showAlerRegisterFail() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Fail'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("เกิดข้อพิพลาด"),
                  ],
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
              ],
            ));
  }

  Widget visibility(bool check) {
    if (check) {
      return const Icon(Icons.visibility);
    } else {
      return const Icon(
        Icons.visibility_off,
        color: Colors.grey,
      );
    }
  }

  Widget _loadingSingin() {
    return SkeletonLoader(
      builder: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 3, color: Colors.white),
          ),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
            ),
            onPressed: null,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                "Please wait",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
            ),
          )),
      items: 1,
      period: const Duration(seconds: 2),
      highlightColor: Colors.pink,
      // baseColor: Colors.pink,
      direction: SkeletonDirection.ltr,
    );
  }
}
