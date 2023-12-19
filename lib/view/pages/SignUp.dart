import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../../model/Account.dart';
import '../../model/error.dart';
import '../../provider/userApi.dart';
import '../../utils/validate.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FocusNode _emailFocus = new FocusNode();
  FocusNode _passwordFocus = new FocusNode();
  FocusNode _rePasswordFocus = new FocusNode();
  FocusNode _nameFocus = new FocusNode();
  FocusNode _codeFocus = new FocusNode();
  FocusNode _yearFocus = new FocusNode();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final MAIN_COLOR = Color.fromRGBO(148, 216, 239, 1.0);
  late final deviceWidth = MediaQuery.of(context).size.width;
  late final deviceHeight = MediaQuery.of(context).size.height;
  bool _visibility = false;
  bool _isVerified = false;
  bool _isDone = true;
  bool _isAgree = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKey_email = GlobalKey<FormState>();

  int time = 180;
  late String _timer = secToTimer(time);
  Timer? timer;



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
            child: Center(child: Image(image: AssetImage('images/logo_login.png'), width: deviceWidth / 7, color: Colors.white,)),
          ),
          Column(
            children: [
              Form(
                key: formKey_email,
                child: Column(
                  children: [
                    _showEmailInput(),
                  ],
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    _showNickNameInput(),
                    _showPasswordInput(),
                    _showRePasswordInput(),
                    _showAgreement(),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    bool email = formKey_email.currentState!.validate();
                    bool other = formKey.currentState!.validate();
                    print('$_isVerified');
                    if(email && other && _isVerified){
                      AccountModel user = AccountModel(email: _emailController.text, admin_name: _nameController.text, password: _passwordController.text,);
                      var response = await http.post(Uri.parse(baseUrl + '/joinus'),
                        body: json.encode(user.toJson()),
                      );
                      var statusCode = response.statusCode;
                      var body = json.decode(utf8.decode(response.bodyBytes));
                      if(statusCode != 200){
                        ErrorMessage error = ErrorMessage.fromJson(body);
                        _showErrorSnackBar(error);
                        setState(() {
                          _isVerified = false;
                          _visibility = false;
                        });
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

  Widget _showEmailInput(){
    return Column(
      children: [
        Padding(padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
            child: Row(
              children: [
                SizedBox(
                  width: deviceWidth / 1.9,
                  child: TextFormField(
                    enabled: !_isVerified,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    decoration: _textFormDecoration('이메일', '이메일을 입력해주세요'),
                    controller: _emailController,
                    validator: (value) => CheckValidate().validateEmail(_emailFocus, value!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: !_isVerified ? OutlinedButton(
                    onPressed: _isDone ? () async {
                      var validate = formKey_email.currentState!.validate();
                      if(validate){
                        if(_visibility){
                          resetCountDown();
                        }
                        _sendEmailVerification();
                      }
                    } : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isDone ? Colors.white : Colors.grey,
                      fixedSize: Size(deviceWidth * 1.8 / 10, deviceHeight/26),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                    ),
                    child: Text(_visibility ? "resend code" : "send code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: MAIN_COLOR,
                      ),
                    ),
                  ) : Container(
                    child: Text("verified!",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white
                      ),
                    ),),),
              ],
            )),
        Visibility(
          visible: _visibility && !_isVerified,
          child: Padding(padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: deviceWidth / 1.9,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      focusNode: _codeFocus,
                      decoration: _textFormDecoration('인증 코드', '인증 코드를 입력해주세요'),
                      controller: _verificationCodeController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: OutlinedButton(
                      onPressed: _isVerified || time == 0 ? null : () async {
                        var response = await http.put(Uri.parse(baseUrl + "/confirm/email-validation"),
                          body: {
                            'email' : _emailController.text,
                            'code' : _verificationCodeController.text,
                          },
                        );
                        var statusCode = response.statusCode;
                        if(statusCode != 200){
                          var body = json.decode(utf8.decode(response.bodyBytes));
                          ErrorMessage error = ErrorMessage.fromJson(body);
                          _showErrorSnackBar(error);
                        }else{
                          show();
                          stopCountDown();
                          setState(() {
                            _isVerified = true;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _isVerified || time == 0 ? Colors.grey : Colors.white,
                        fixedSize: Size(deviceWidth * 1.8 / 10, deviceHeight/26),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      ),
                      child: Text(_timer,
                        style: TextStyle(
                            fontSize: 15,
                            color: MAIN_COLOR
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ],
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

  Widget _showAgreement(){
    return FormField<bool>(
      builder: (state) {
        return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isAgree, //처음엔 false
                  onChanged: (value) { //value가 false -> 클릭하면 true로 변경됨(두개 중 하나니까)
                    setState(() {
                      _isAgree = value!; //true가 들어감.
                    });
                  },
                ),
                Text('(필수)개인정보 수집 및 이용 동의  '),
                GestureDetector(
                  onTap: (){
                    showDialog(context: context, builder: (context){
                      return InAppWebView(
                        initialUrlRequest: URLRequest(
                            url: Uri.parse('https://plip.kr/pcc/6872ba32-1606-43da-a4b0-30db1724d6d4/consent/1.html')
                        ),
                      );
                    });
                  },
                  child: Text('동의서 보기',
                    style: TextStyle(
                        color: Colors.grey
                    ),
                  ),
                )
              ],
            );
//display error in matching theme
      },
//output from validation will be displayed in state.errorText (above)
      validator: (value) {
        if (!_isAgree) {
          return 'You need to accept terms';
        } else {
          return null;
        }
      },
    );
  }


  InputDecoration _textFormDecoration(hintText, helperText){
    return new InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      hintText: hintText,
      helperText: helperText,
    );
  }

  void hide(){
    setState(() {
      _visibility = false;
    });
  }
  void show(){
    setState(() {
      _visibility = true;
    });
  }

  void countDown(){
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(time > 0){
        setState(() {
          time--;
          _timer = secToTimer(time);
        });
      }
    });
  }

  void resetCountDown(){
    setState(() {
      time = 180;
      _timer = secToTimer(time);
    });
  }

  void stopCountDown(){
    timer?.cancel();
  }

  void _showErrorSnackBar(ErrorMessage error){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message),
          duration: const Duration(seconds: 3),
        )
    );
  }

  String secToTimer(int sec){
    int min = (sec / 60).toInt();
    sec = sec % 60;
    return '$min : ${sec.toString().padLeft(2, "0")}';
  }

  void _sendEmailVerification() async {
    setState(() {
      _isDone = false;
    });
    print(_emailController.text);
    var response = await http.put(Uri.parse(baseUrl + "/request/email-validation"),
      body: {
        'email' : _emailController.text
      },
    );
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
      _showErrorSnackBar(error);
    }else{
      show();
      countDown();
    }
    setState(() {
      _isDone = true;
    });
  }

}
