import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/db_helper.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfilePage({required this.user, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user['name'];
    if (widget.user['profile_image'] != null) {
      _image = File(widget.user['profile_image']);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _updateProfile() async {
    String name = _nameController.text;

    if (name.isNotEmpty) {
      // 업데이트할 데이터를 설정합니다.
      Map<String, dynamic> updatedUser = {
        'id': widget.user['id'],
        'name': name,
        'email': widget.user['email'],
        'password': widget.user['password'],
        // 프로필 이미지를 파일 경로로 저장합니다.
        'profile_image': _image?.path ?? widget.user['profile_image']
      };

      // 데이터베이스 업데이트를 수행합니다.
      await _dbHelper.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필이 업데이트되었습니다!')),
      );

      // 프로필 업데이트 후 이전 화면으로 돌아갑니다.
      Navigator.pop(context, updatedUser);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이름을 입력해주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : AssetImage('assets/profile_default.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            SizedBox(height: 10),
            Text(
              '이메일: ${widget.user['email']}',
              style: TextStyle(fontSize: 16),
            ),
            // 추가 정보들을 여기에 표시할 수 있습니다.
          ],
        ),
      ),
    );
  }
}
