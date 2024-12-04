import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_helper.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfilePage({required this.user, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false; // 수정 모드 여부
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _tempName;
  late String _tempEmail;
  final String? serverIP = dotenv.env['SERVER_IP'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _emailController = TextEditingController(text: widget.user['email']);
    _tempName = widget.user['name'];
    _tempEmail = widget.user['email'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEditMode() async {
    if (_isEditing) {
      if(_nameController.text != _tempName || _emailController.text != _tempEmail) {
        final uri = Uri.http('$serverIP', '/user/profile');
        var request = http.MultipartRequest('PUT', uri);
        request.fields.addAll({
          "id": widget.user['id'].toString(),
          "email": _emailController.text,
          "name": _nameController.text
        });
        try {
          final response = await request.send();
          final responseData = jsonDecode(await response.stream.bytesToString());
          await AuthHelper.saveUserSession(responseData);
          setState(() {
            widget.user['name'] = responseData['name'];
            widget.user['email'] = responseData['email'];
            _isEditing = !_isEditing;
          });
          Navigator.pop(context, responseData);
        } catch(e) {
          print({"error": e});
        }
      }
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('내 정보')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬 설정
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: widget.user['profile_img'] != null
                    ? NetworkImage(widget.user['profile_img'])
                    : AssetImage('assets/profile_default.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            Text('이름', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '이름을 입력하세요',
                    ),
                  )
                : Text(widget.user['name'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('이메일', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            _isEditing
                ? TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '이메일을 입력하세요',
                    ),
                  )
                : Text(widget.user['email'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('업데이트 날짜', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(widget.user['updated_at'], style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: _toggleEditMode,
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            label: Text(_isEditing ? '완료' : '수정'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import '../database/db_helper.dart'; // DBHelper를 통해 데이터베이스 접근

// class ProfilePage extends StatefulWidget {
//   final Map<String, dynamic> user;

//   const ProfilePage({required this.user, Key? key}) : super(key: key);

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   late Map<String, dynamic> user;
//   final TextEditingController _nameController = TextEditingController(); // 이름 입력 필드의 컨트롤러
//   final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 ImagePicker
//   File? _profileImage; // 선택한 프로필 이미지를 저장할 변수
//   final DBHelper _dbHelper = DBHelper(); // DBHelper 인스턴스 생성
//   File? _image; // 선택한 이미지 파일

//   @override
//   void initState() {
//     super.initState();
//     user = Map<String, dynamic>.from(widget.user); // 수정 가능한 Map으로 복사
//     _nameController.text = user['name']; // 초기 이름 설정
//     if (user['profile_image'] != null) {
//       _image = File(user['profile_image']); // 초기 프로필 이미지 설정
//     }
//   }

//   // 이미지 선택 함수
//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _profileImage = File(image.path);
//         _image = _profileImage; // 선택한 이미지를 업데이트
//         user['profile_image'] = image.path; // 이미지 경로를 유저 정보에 저장
//       });

//       // 데이터베이스에 이미지 경로를 저장
//       await _dbHelper.updateProfileImage(user['id'], image.path);
//     }
//   }

//   // 프로필 업데이트 함수
//   void _updateProfile() async {
//     String name = _nameController.text;

//     if (name.isNotEmpty) {
//       // 업데이트할 데이터 설정
//       Map<String, dynamic> updatedUser = {
//         'id': widget.user['id'],
//         'name': name,
//         'email': widget.user['email'], // 이메일은 수정 불가, 기존 값 유지
//         'password': widget.user['password'],
//         'profile_image': _image?.path ?? widget.user['profile_image'], // 프로필 이미지 경로 저장
//       };

//       // 데이터베이스 업데이트 수행
//       await _dbHelper.updateUser(updatedUser);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('프로필이 업데이트되었습니다!')),
//       );

//       // 업데이트된 유저 정보를 반환하고 이전 화면으로 돌아감
//       Navigator.pop(context, updatedUser);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('이름을 입력해주세요')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('내 정보'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: _updateProfile, // 저장 버튼을 눌렀을 때 프로필 업데이트
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             GestureDetector(
//               onTap: _pickImage, // 프로필 사진을 클릭하면 이미지 선택
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.grey,
//                 backgroundImage: _image != null && File(_image!.path).existsSync()
//                     ? FileImage(_image!)
//                     : AssetImage('assets/profile_default.jpg') as ImageProvider,
//               ),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _nameController, // 이름 입력 필드 컨트롤러
//               decoration: InputDecoration(labelText: '이름'),
//             ),
//             SizedBox(height: 10),
//             Text(
//               '이메일: ${widget.user['email']}', // 이메일은 텍스트로만 표시
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
