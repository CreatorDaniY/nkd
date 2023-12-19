import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:north_kor_defector/provider/post_provider.dart';
import 'package:north_kor_defector/provider/userApi.dart';
import 'package:north_kor_defector/view/pages/home.dart';
import 'package:north_kor_defector/view/pages/login.dart';
import 'package:north_kor_defector/view/pages/post_detail.dart';
import 'package:north_kor_defector/view/pages/write_post.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'view/pages/SignUp.dart';

void main() async {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.top,
    ],
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PostProvider>(create: (_) => PostProvider())
      ],
      child: MaterialApp(
        initialRoute: '/init',
        routes: {
          '/init' : (context) => MyApp(),
          '/login' : (context) => LoginPage(),
          '/sign-up' : (context) => SignUpPage(),
          '/home' : (context) => HomePage(),
          '/post' : (context) => WritePage(),
        },
      ),
    ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();


  @override
  Widget build(BuildContext context) {
    final MAIN_COLOR = Color.fromRGBO(148, 216, 239, 1.0);
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MAIN_COLOR,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(top: (deviceHeight * 18 / 100)),
            child: Center(child: Image(image: AssetImage('images/logo_login.png'), width: deviceWidth / 1.4, height: deviceHeight / 3, color: Colors.white,) ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: (deviceHeight * 17 / 100)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(deviceWidth * 6 / 10, deviceHeight/16),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text("Login",
                        style: TextStyle(
                            fontSize: 25,
                            color: MAIN_COLOR
                        )
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-up');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: Size(deviceWidth * 6 / 10, deviceHeight/16),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                  ),
                  child: Text("Sign Up",
                    style: TextStyle(
                        fontSize: 25,
                        color: MAIN_COLOR
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // storage.delete(key: "session");
    _asyncMethod();
  }

  _asyncMethod() async {
    //read 함수를 통하여 key값에 맞는 정보를 불러오게 됩니다. 이때 불러오는 결과의 타입은 String 타입임을 기억해야 합니다.
    //(데이터가 없을때는 null을 반환을 합니다.)
    String? session = await storage.read(key: "session");
    if(session != null){
      List<String> split = session!.split(',,');
      print(split);
      ApiClient.checkSession(context, split[2]);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }

    // //user의 정보가 있다면 바로 로그아웃 페이지로 넝어가게 합니다.
    // if (userInfo != null) {
    //   Navigator.pushReplacement(
    //       context,
    //       CupertinoPageRoute(
    //           builder: (context) => LogOutPage(
    //             id: userInfo.split(" ")[1],
    //             pass: userInfo.split(" ")[3],
    //           )));
    // }
  }


}
