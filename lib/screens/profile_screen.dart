import 'dart:io';
import 'package:flutter/material.dart';
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

  File? _image;
  bool _isPickerImage = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
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
      // maxHeight: 1152,
      // maxWidth: 1152,
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
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
      setState(() {
        _isPickerImage = true;
        _image = File(croppedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  _pickImage(
                      context); // Call the _pickImage function when tapped
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
            Row()
          ],
        ),
      ),
    );
  }
}
