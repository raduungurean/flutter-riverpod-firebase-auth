import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spendbuddy/features/auth/data/user_model.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';

class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key});

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  String? imageUrl;

  late File _userImageFile;
  Uint8List _bytes = Uint8List(0);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
  }

  bool isValidDisplayName(String displayName) {
    // Allow only lowercase letters and numbers
    final regex = RegExp(r'^[a-z0-9]+$');
    return regex.hasMatch(displayName);
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxWidth: 700,
        maxHeight: 700,
        compressFormat: ImageCompressFormat.png,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: const CroppieViewPort(
              width: 480,
              height: 480,
              type: 'circle',
            ),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        _userImageFile = File(croppedFile.path);
        _bytes = await croppedFile.readAsBytes();
        ref
            .read(authControllerProvider.notifier)
            .updateUserPhoto(_userImageFile, _bytes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);
    if (authController is AsyncData<UserModel?> &&
        authController.value != null) {
      final user = authController.value!;
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _usernameController.text = user.displayName ?? '';
      imageUrl = user.photoURL;
    }

    final inputBorder = Theme.of(context).inputDecorationTheme.filled
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide.none,
          )
        : null;
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor;
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: inputBorder?.borderRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  GFAvatar(
                    backgroundImage: NetworkImage(imageUrl!),
                    size: 50.0,
                  ),
                const SizedBox(width: 10),
                Text("Profile Image"),
                IconButton(
                  icon: const Icon(Icons.photo_camera),
                  onPressed: _pickAndUploadImage,
                  tooltip: 'Pick an image',
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: 'First Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: 'Last Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              if (!isValidDisplayName(value)) {
                return 'Invalid format for username';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final firstName = _firstNameController.text;
                final lastName = _lastNameController.text;
                final displayName = _usernameController.text;
                ref.read(authControllerProvider.notifier).updateUser(
                      firstName,
                      lastName,
                      displayName,
                    );
              }
            },
            child: const Text('Update Profile'),
          ),
        ],
      ),
    );
  }
}
