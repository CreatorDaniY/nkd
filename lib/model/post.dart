import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'board_list.dart';

class  FetchPost{
  var title;
  var content;
  var createdAt;
  var thumbnail;
  var updatedAt;
  var boardNo;
  var userName;
  var profileImg;


  FetchPost({required this.title, required this.content, required this.createdAt, required this.thumbnail,
    required this.updatedAt, required this.boardNo, required this.userName, required this.profileImg});


  factory FetchPost.fromJson(Map<String, dynamic> json) {
    return FetchPost(
        userName: json['name'],
        profileImg: json['profile'],
        title: json['title'],
        thumbnail: json['thumbnail'],
        content: json['content'],
        boardNo: json['board_no'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at']
    );
  }
}




class PostDetail{
/*
    private Board board;
    private List<Comment> comments;
    private List<BoardTag> tags;
    private Integer numLike;
 */
  Board board;
  dynamic numLike;
  dynamic comments;

  PostDetail({
    required this.board,
    this.numLike,
    this.comments,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json){
    return PostDetail(
      board: Board.fromJson(json['board']),
      numLike: json['num_like'],
      comments: json['comments'],
    );
  }





}