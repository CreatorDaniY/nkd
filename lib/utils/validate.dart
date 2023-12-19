import 'package:flutter/material.dart';

class CheckValidate{
  String? validateEmail(FocusNode focusNode, String value){
    if(value.isEmpty){
      focusNode.requestFocus();
      return '이메일을 입력하세요.';
    }else {
      RegExp regExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if(!regExp.hasMatch(value)){
        focusNode.requestFocus();	//포커스를 해당 textformfield에 맞춘다.
        return '잘못된 이메일 형식입니다.';
      }else{
        return null;
      }
    }
  }

  String? validatePassword(FocusNode focusNode, String value){
    if(value.isEmpty){
      focusNode.requestFocus();
      return '비밀번호를 입력하세요.';
    }else {
      Pattern pattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$';
      RegExp regExp = new RegExp(pattern.toString());
      if(!regExp.hasMatch(value)){
        focusNode.requestFocus();
        return '특수문자, 대소문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.';
      }else{
        return null;
      }
    }
  }

  String? validateRePassword(FocusNode focusNode, String value, String password){
    if(value.isEmpty){
      focusNode.requestFocus();
      return '비밀번호를 입력하세요.';
    }else {
      if(password != value){
        focusNode.requestFocus();
        return '패스워드와 일치하지 않습니다.';
      }
    }
    return null;
  }

  String? validateName(FocusNode focusNode, String value){
    if(value.isEmpty){
      focusNode.requestFocus();
      return '닉네임을 입력하세요.';
    }else {
      Pattern pattern = r'^[가-힣a-zA-Z0-9]{2,10}$';
      RegExp regExp = new RegExp(pattern.toString());
      if(!regExp.hasMatch(value)){
        focusNode.requestFocus();
        return '2자 이상 10자 이내로 입력하세요.(공백/특수문자 입력 불가능)';
      }else{
        return null;
      }
    }
  }

  String? validateYear(FocusNode focusNode, String value){
    if(value.isEmpty){
      focusNode.requestFocus();
      return '졸업예정 연도를 입력하세요.';
    }else {
      Pattern pattern = r'^[0-9]{4}$';
      RegExp regExp = new RegExp(pattern.toString());
      if(!regExp.hasMatch(value)){
        focusNode.requestFocus();
        return '졸업연도 4자리를 입력하세요';
      }else{
        return null;
      }
    }
  }

  String? validateVeriCode(FocusNode focusNode, String value){
    if(value.isEmpty){
      focusNode.requestFocus();
      return '인증 코드를 입력하세요.';
    }else {

    }
    return null;
  }

  Function validateTitle() {
    return (String? value) {
      if (value!.isEmpty) {
        return "제목은 공백이 될 수 없습니다.";
      } else if (value.length > 30) {
        return "제목의 길이를 초과하였습니다.";
      } else {
        return null;
      }
    };
  }

  Function validateContent() {
    return (String? value) {
      if (value!.isEmpty) {
        return "내용은 공백이 들어갈 수 없습니다.";
      } else if (value.length > 500) {
        return "내용의 길이를 초과하였습니다.";
      } else {
        return null;
      }
    };
  }

}