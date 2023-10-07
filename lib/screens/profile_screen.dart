import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../models/user.dart';
import 'package:car_pool_project/global.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  final formKey = GlobalKey<FormState>();
  User userData = User();
  File? _image;
  bool _isPickerImage = false;

  final FocusNode _focusNodeUsername = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodeFirstName = FocusNode();
  final FocusNode _focusNodeLastName = FocusNode();
  final FocusNode _focusNodeUserRoleName = FocusNode();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userRoleNameController = TextEditingController();

  String sex = "Male";

  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    userInit();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNodeUsername.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    _focusNodeEmail.dispose();
    _focusNodeFirstName.dispose();
    _focusNodeLastName.dispose();
    _focusNodeUserRoleName.dispose();

    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _userRoleNameController.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context); // Close the bottom sheet
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  // Handle the picked image (e.g., save it or display it)
                  _image = File(pickedFile.path);
                  // Do something with imageFile...
                  _cropImage();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context); // Close the bottom sheet
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  // Handle the picked image (e.g., save it or display it)
                  _image = File(pickedFile.path);
                  // Do something with imageFile...
                  _cropImage();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      maxHeight: 1152,
      maxWidth: 1152,
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        // IOSUiSettings(
        //   title: 'Cropper',
        // ),
        // WebUiSettings(
        //   context: context,
        // ),
      ],
    );

    if (croppedFile != null) {
      var tampImage = File(croppedFile.path);
      String? tempData = await User.uploadProfileImage(tampImage);
      if (tempData != null) {
        setState(() {
          _isPickerImage = true;
          _image = tampImage;
          user.img = tempData;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNodeUsername.unfocus();
        _focusNodePassword.unfocus();
        _focusNodeConfirmPassword.unfocus();
        _focusNodeEmail.unfocus();
        _focusNodeFirstName.unfocus();
        _focusNodeLastName.unfocus();
        _focusNodeUserRoleName.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: Colors.pink,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, user);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (user.userRoleID! < 5) {
                        _pickImage(context);
                      }
                    },
                    child: CircleAvatar(
                      radius: 100,
                      child: ClipOval(
                        child: _isPickerImage == false || _image == null
                            ? Image.network(
                                "${globals.protocol}${globals.serverIP}/profiles/${user.img!}",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error_outline);
                                },
                              )
                            : Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error_outline);
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Visibility(
                            visible: user.userRoleID! > 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: user.userRoleID == 5
                                  ? [
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: const Row(
                                            children: [
                                              Icon(Icons.person),
                                              SizedBox(width: 8),
                                              Text("ยืนยันตัวตน"),
                                            ],
                                          )),
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: const Row(
                                            children: [
                                              Icon(Icons.badge),
                                              SizedBox(width: 8),
                                              Text("ยืนยันการขับรถ"),
                                            ],
                                          ))
                                    ]
                                  : [
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: const Row(
                                            children: [
                                              Icon(Icons.badge),
                                              SizedBox(width: 8),
                                              Text("ยืนยันการขับรถ"),
                                            ],
                                          ))
                                    ],
                            )),
                        TextFormField(
                            focusNode: _focusNodeUsername,
                            readOnly: true,
                            controller: _usernameController,
                            onTap: () {
                              _focusNodeUsername.unfocus();
                            },
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: "Please Input Username")
                            ]),
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
                                ))),
                        const SizedBox(height: 15),
                        TextFormField(
                          focusNode: _focusNodeFirstName,
                          controller: _firstNameController,
                          readOnly: !_isEdit,
                          onSaved: (newValue) {
                            userData.firstName = newValue;
                          },
                          onTap: () {
                            if (_isEdit == false) {
                              _focusNodeFirstName.unfocus();
                            }
                          },
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: "Please Input First name.")
                          ]),
                          decoration: InputDecoration(
                              labelText: "First name",
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                // borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.edit_note,
                                color: Colors.pink,
                              )),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          focusNode: _focusNodeLastName,
                          controller: _lastNameController,
                          readOnly: !_isEdit,
                          onSaved: (newValue) {
                            userData.lastName = newValue;
                          },
                          onTap: () {
                            if (_isEdit == false) {
                              _focusNodeLastName.unfocus();
                            }
                          },
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: "Please Input Last name.")
                          ]),
                          decoration: InputDecoration(
                              labelText: "Last name",
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                // borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.edit_note,
                                color: Colors.pink,
                              )),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          focusNode: _focusNodeEmail,
                          controller: _emailController,
                          readOnly: !_isEdit,
                          onSaved: (newValue) {
                            userData.email = newValue;
                          },
                          onTap: () {
                            if (_isEdit == false) {
                              _focusNodeEmail.unfocus();
                            }
                          },
                          validator: MultiValidator([
                            RequiredValidator(errorText: "Please Input Email."),
                            EmailValidator(errorText: "Email is Incorrect !")
                          ]),
                          decoration: InputDecoration(
                              labelText: "Email",
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                // borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.mail,
                                color: Colors.pink,
                              )),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          focusNode: _focusNodeUserRoleName,
                          controller: _userRoleNameController,
                          readOnly: true,
                          onTap: () {
                            _focusNodeUserRoleName.unfocus();
                          },
                          decoration: InputDecoration(
                              labelText: "User role",
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                // borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.badge,
                                color: Colors.pink,
                              )),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                    if (_isEdit) {
                                      setState(() {
                                        sex = value.toString();
                                        userData.sex = sex;
                                      });
                                    }
                                  })),
                            ),
                            const Text("Male"),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 140,
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
                                    if (_isEdit) {
                                      setState(() {
                                        sex = value.toString();
                                        userData.sex = sex;
                                      });
                                    }
                                  })),
                            ),
                            const Text("Famale"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _isEdit
                              ? [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        formKey.currentState!.save();
                                        User? temp =
                                            await User.editProfile(userData);
                                        if (temp != null) {
                                          setState(() {
                                            user = temp;
                                            _isEdit = false;
                                          });
                                          showAlerSuccess();
                                        } else {
                                          showAlerError();
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 15),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_outline),
                                          Text(
                                            "Save",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isEdit = false;
                                      });
                                      sex = user.sex!;
                                      _firstNameController.text =
                                          user.firstName!;
                                      _lastNameController.text = user.lastName!;
                                      _emailController.text = user.email!;
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 3),
                                      child: Row(
                                        children: [
                                          Icon(Icons.cancel_outlined),
                                          Text(
                                            "Cancel",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                              : [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isEdit = true;
                                      });
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          Text(
                                            "Edit",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void userInit() {
    _usernameController.text = user.username!;
    _firstNameController.text = user.firstName!;
    _lastNameController.text = user.lastName!;
    _emailController.text = user.email!;
    _userRoleNameController.text = user.userRoleName!;
    sex = user.sex!;
  }

  void showAlerError() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Error'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("เกิดข้อผิดพลาดโปรดลองใหม่อีกครั้ง"),
                  ],
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
              ],
            ));
  }

  void showAlerSuccess() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Success'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
}
