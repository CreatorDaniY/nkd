import 'Account.dart';

class Comment{
  dynamic commentNo;
  dynamic upCommNo;
  dynamic author;
  dynamic comment;

  Comment({required this.commentNo, required this.upCommNo, required this.author, required this.comment});

  factory Comment.fromJson(Map<String, dynamic> json){
    return Comment(
        commentNo: json['comment_no'],
        upCommNo: json['up_comm_no'],
        author: Account.fromJson(json['author']),
        comment: json['comment']
    );
  }

}