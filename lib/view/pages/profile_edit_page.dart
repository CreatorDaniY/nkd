import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../../model/Account.dart';
import '../../model/error.dart';
import '../../provider/userApi.dart';
import '../../utils/validate.dart';

class EditProfilePage extends StatefulWidget {

  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  FocusNode _passwordFocus = new FocusNode();
  FocusNode _rePasswordFocus = new FocusNode();
  FocusNode _nameFocus = new FocusNode();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final MAIN_COLOR = Color.fromRGBO(148, 216, 239, 1.0);
  late final deviceWidth = MediaQuery.of(context).size.width;
  late final deviceHeight = MediaQuery.of(context).size.height;
  bool _isDone = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKey_email = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {

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
          Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    _showNickNameInput(),
                    _showPasswordInput(),
                    _showRePasswordInput(),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: (deviceHeight * 10 / 100)),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    bool email = formKey_email.currentState!.validate();
                    bool other = formKey.currentState!.validate();
                    if(email && other){
                      AccountModel user = AccountModel(email: _emailController.text, admin_name: _nameController.text, password: _passwordController.text,);
                      var response = await http.post(Uri.parse(baseUrl + '/joinus'),
                        body: json.encode(user.toJson()),
                      );
                      var statusCode = response.statusCode;
                      var body = json.decode(utf8.decode(response.bodyBytes));
                      if(statusCode != 200){
                        ErrorMessage error = ErrorMessage.fromJson(body);
                        _showErrorSnackBar(error);

                      }else{
                        //todo 회원가입버튼을 눌렀을때 가입성공시 로그인 페이지로 이동
                        Navigator.pushNamed(context, '/login');
                      }
                    }else if(email && other){
                      _showErrorSnackBar(ErrorMessage(code: '', message: '이메일 인증후 회원가입이 가능합니다.', status: ''));
                    }

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
                  validator: (value) => CheckValidate().validatePassword(_passwordFocus, value!),
                )),
          ],
        ));
  }

  Widget _showRePasswordInput(){
    return Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: TextFormField(
                  focusNode: _rePasswordFocus,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: _textFormDecoration('비밀번호', '패스워드와 일치하게 입력하세요.'),
                  validator: (value) => CheckValidate().validateRePassword(_rePasswordFocus, value!, _passwordController.text),
                )),
          ],
        ));
  }

  Widget _showNickNameInput(){
    return Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: TextFormField(
                  focusNode: _nameFocus,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  decoration: _textFormDecoration('닉네임', '한글 또는 영어 2자 이상 10자 이내로 입력하세요.'),
                  controller: _nameController,
                  validator: (value) => CheckValidate().validateName(_nameFocus, value!),
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

  void _initProfile() async {

  }

}
