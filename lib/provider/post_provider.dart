import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:north_kor_defector/model/post.dart';
import 'package:north_kor_defector/provider/userApi.dart';

import '../model/board_list.dart';
import '../model/error.dart';


class PostProvider extends ChangeNotifier {
  List<FetchPost> cache = [];

  final storage = FlutterSecureStorage();

  bool loading = false;
  bool hasMore = true;

  String nextToken = '';

  _makeRequest({
    required String nextToken
  }) async {
    assert(nextToken != null);
    //await 조회하기
    List<FetchPost> list = [];
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    var response = await http.put(Uri.parse(baseUrl + '/board-list'), body: {
      "is_for_school" : true.toString(),
      "board_type" : "know_how",
      "next_token" : nextToken,
    }, headers: {
      'norKor_token' : split[2]
    });
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
    }else {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      var boardList = BoardList.fromJson(body);
      print('next token is ${nextToken}');
      this.nextToken = boardList.nextToken;
      print('next token is ${this.nextToken}');
      if(nextToken == 'D'){
        hasMore = false;
      }
      list = boardList.items.map((e) => FetchPost.fromJson(e)).toList();
    }
    return list;
  }

  fetchPosts({
    String? token
  }) async {
    token ??= '';
    loading = true;
    notifyListeners();
    final items = await _makeRequest(nextToken: token);
    this.cache = [
      ...cache,
      ...items
    ];
    loading = false;
    notifyListeners();

  }


}