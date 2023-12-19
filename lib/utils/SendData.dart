import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../model/object/ResponseData.dart';
import '../provider/userApi.dart';
import 'KEYS.dart';

class SendData {
  static var storage = FlutterSecureStorage();

  static Future<Options> _abstractHeader(Map<String, String>? headers) async {
    var sessAuthKey = (await storage.read(key: "session"))!;
    // todo: Should be deleted.
    var options = Options(
      headers: Map()
    );
    options.headers![KEYS.NONAMED_TOKEN] = sessAuthKey;
    options.contentType = 'application/json';
    options.receiveDataWhenStatusError = true;
    return options;
  }

  static Map isBody(body){
    if(body == null) body = Map();
    return body;
  }

  static Map<String, String> isQueryString(queryString){
    if(queryString == null) queryString = Map<String, String>();
    return queryString;
  }

  static Future<ResponseData> doGet(BuildContext context, String url, {Map<String, String>? headers, Map<String, String>? queryString}) async {
    try{
      var options = await _abstractHeader(headers);
      print('done1');
      Response response = await Dio().get('$baseUrl' + url, options: options, queryParameters: isQueryString(queryString));
      print('done2');
      return ResponseData(response: response);
    }on DioError catch(e){
      print(e.stackTrace);
      deleteSharedPreferences(context, e);
      return ResponseData(e: e);
    }
  }

  static Future<ResponseData> doHead(BuildContext context, String url, {Map<String, String>? headers, Map<String, String>? queryString}) async {
    var options = await _abstractHeader(headers);
    try{
      Response resopnse = await Dio().head('$baseUrl' + url, options: options, queryParameters: isQueryString(queryString));
      return ResponseData(response: resopnse);
    }on DioError catch(e){
      deleteSharedPreferences(context, e);
      return ResponseData(e: e);
    }
  }

  static Future<ResponseData> doDelete(BuildContext context, String url, {Map<String, String>? headers, Map? queryString}) async {
    var options = await _abstractHeader(headers);
    try{
      Response resopnse = await Dio().delete('$baseUrl' + url, options: options, queryParameters: isQueryString(queryString));
      return ResponseData(
          response: resopnse
      );
    }on DioError catch(e){
      deleteSharedPreferences(context, e);
      return ResponseData(e: e);
    }
  }

  static Future<ResponseData> doPost(BuildContext context, String url, {Map<String, String>? headers, Map? data, Map? queryString}) async {
    var options = await _abstractHeader(headers);
    try{
      Response resopnse = await Dio().post('$baseUrl/$url', options: options, queryParameters: isQueryString(queryString), data: isBody(data));
      return ResponseData(
        response: resopnse
      );
    }on DioError catch(e){
      deleteSharedPreferences(context, e);
      return ResponseData(e: e);
    }
  }

  static Future<ResponseData> doPatch(BuildContext context, String url, {Map<String, String>? headers, Map? data, Map? queryString}) async {
    var options = await _abstractHeader(headers);
    try{
      Response resopnse = await Dio().patch('$baseUrl' + url, options: options, queryParameters: isQueryString(queryString), data: isBody(data));
      return ResponseData(
          response: resopnse
      );
    }on DioError catch(e){
      deleteSharedPreferences(context, e);
      return ResponseData(e: e);
    }
  }

  static Future<ResponseData> doPut(BuildContext context, String url, {Map<String, String>? headers, Map? data, Map? queryString}) async {
    var options = await _abstractHeader(headers);
    try{
      Response response = await Dio().put('$baseUrl' + url, options: options, queryParameters: isQueryString(queryString), data: isBody(data));
      return ResponseData(
          response: response
      );
    }on DioError catch(e){
      deleteSharedPreferences(context, e);
      return ResponseData(e: e);
    }
  }

  static deleteSharedPreferences(BuildContext context, DioError? response) async {
    if(response != null && response.response != null && response.response!.statusCode == HttpStatus.unauthorized){
      // SessionStore sessionStores = Provider.of(context, listen: false);
      // sessionStores.logout();
      storage.delete(key: 'session');
      Navigator.pushNamedAndRemoveUntil(context, '/init', (route) => false);
    }else if(response != null && response.response != null && response.response != null && response.response!.statusCode == HttpStatus.upgradeRequired){
      // Navigator.of(context).push(PageRouteBuilder(
      //   pageBuilder: (context, animation, secondaryAnimation) => AppUpdateScreen(),
      //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //     return child;
      //   },
      // ));
    }
  }

  static Future<ResponseData> sendFile(BuildContext context, String url, {
    Map<String, String>? headers, Map? data, Map? queryString, List<int>? file
  }) async {
    var len = file!.length;
    try{
      Response response = await Dio().put(url,
          data: Stream.fromIterable(file.map((e) => [e])),
          options: Options(
              contentType: "multiple/form-data",
              headers: {
                Headers.contentLengthHeader: len
              }
          )
      );
      return ResponseData(
        response: response
      );
    }on DioError catch(e){
      deleteSharedPreferences(context, e);
      return ResponseData(e: e);
    }

  }

}