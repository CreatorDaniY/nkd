
import 'package:north_kor_defector/model/post.dart';

class BoardList{
  String nextToken;
  List<dynamic> items;
  int total;


  BoardList({
    required this.nextToken,
    required this.items,
    required this.total,
  });

  factory BoardList.fromJson(Map<String, dynamic> json) {
    return BoardList(
      nextToken: json["next_token"],
      items: json["items"],
      total: json["total"],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'next_token' : nextToken,
      'items' : items,
      'total' : total,
    };
  }

  String toString(){
    return 'next_token : $nextToken \n itmes: $items \n total : $total';
  }

}


class Board{
  var boardNo;
  var authorNo;
  var title;
  var content;
  var commDisabled;
  var createdAt;
  var updatedAt;
  dynamic author;

  Board({
    required this.boardNo,
    required this.authorNo,
    required this.title,
    required this.content,
    required this.commDisabled,
    required this.createdAt,
    required this.updatedAt,
    this.author
  });

  factory Board.fromJson(Map<String, dynamic> json){
    return Board(
        boardNo: json['board_no'],
        authorNo: json['author_no'],
        title: json['title'],
        content: json['content'],
        commDisabled: json['comm_disabled'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        author: FetchPost.fromJson(json['author'])
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'title' : this.title,
      'content' : this.content,
    };
  }



}