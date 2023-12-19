import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../model/Account.dart';
import '../../model/error.dart';
import '../../provider/userApi.dart';
import '../../utils/validate.dart';
import 'package:http/http.dart' as http;


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode _emailFocus = new FocusNode();
  FocusNode _passwordFocus = new FocusNode();

  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  final storage = FlutterSecureStorage();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final MAIN_COLOR = Color.fromRGBO(148, 216, 239, 1.0);
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MAIN_COLOR,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, size: 30,),
          color: Colors.white,

        ),
      ),
      backgroundColor: MAIN_COLOR,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(top: (deviceHeight * 2 / 100)),
            child: Center(child: Image(image: AssetImage('images/logo_login.png'), width: 60, color: Colors.white,)),
          ),
          new Form(
            key: formKey,
            child: Column(
              children: [
                _showEmailInput(),
                _showPasswordInput(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: (deviceHeight * 10 / 100)),
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
                    onPressed: () async {
                      bool validate = formKey.currentState!.validate();
                      if(validate){
                        var response = await http.post(Uri.parse(baseUrl + "/login"),
                          body: {
                            'email' : _emailController.text,
                            'password': sha256.convert(utf8.encode(_passwordController.text)).toString()
                          },
                        );
                        var statusCode = response.statusCode;
                        if(statusCode != 200){
                          var body = json.decode(utf8.decode(response.bodyBytes));
                          ErrorMessage error = ErrorMessage.fromJson(body);
                          _showErrorSnackBar(error);
                        }else{
                          var body = json.decode(utf8.decode(response.bodyBytes));
                          PostResponse postResponse = PostResponse.fromJson(body);
                          await storage.write(key: 'session', value:postResponse.toString());
                          Navigator.pushNamed(context, '/home');
                        }
                      }
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

  Widget _showEmailInput(){
    return Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  focusNode: _emailFocus,
                  decoration: _textFormDecoration('이메일', '이메일을 입력해주세요'),
                  controller: _emailController,
                  validator: (value) => CheckValidate().validateEmail(_emailFocus, value!),
                )),
          ],
        ));
  }

  Widget _showPasswordInput(){
    return Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: TextFormField(
                  focusNode: _passwordFocus,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: _textFormDecoration('비밀번호', '특수문자, 대소문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.'),
                  controller: _passwordController,
                  validator: (value) => null,
                )),
          ],
        ));
  }


  InputDecoration _textFormDecoration(hintText, helperText){
    return new InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      hintText: hintText,
      helperText: helperText,
    );
  }

  void _showErrorSnackBar(ErrorMessage error){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message),
          duration: const Duration(seconds: 3),
        )
    );
  }

}
