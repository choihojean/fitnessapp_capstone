import 'package:flutter/material.dart';
import 'package:knufit/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth/signup_page.dart';
import 'auth/login_page.dart';
import 'auth/auth_helper.dart';
import 'home_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: FitnessApp(),
    ),
  );
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Fitness App',
          theme: themeNotifier.currentTheme,
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/signup': (context) => SignupPage(),
            '/login': (context) => LoginPage(),
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // 사용자 세션 정보 확인
    var user = await AuthHelper.getUserSession();
    if (user != null) {
      // 세션이 존재하면 HomeScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(user: user),
        ),
      );
    } else {
      // 세션이 없으면 WelcomePage로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // 배경 이미지 경로
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // 반투명 검정색 오버레이
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Fitness App에 오신 것을 환영합니다',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        '로그인',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: BorderSide(color: Colors.white),
                      ),
                      child: Text(
                        '회원가입',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Fitness App과 함께 운동 습관을 만들어요',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
