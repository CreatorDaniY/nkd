import 'dart:convert';

import 'package:crypto/crypto.dart';

class  PresignedUrl{
  var bucket;
  var fileKey;
  var url;
  var filename;



  PresignedUrl({required this.bucket, required this.fileKey,
    required this.url, required this.filename,});


  factory PresignedUrl.fromJson(Map<String, dynamic> json) {
    return PresignedUrl(
      bucket: json['bucket'],
      fileKey: json['file_key'],
      url: json['url'],
      filename: json['filename'],
    );
  }
/*
"is_for_school": true,
            "board_type": "1",
            "updated_at": "2023-09-11T09:00:32",
            "school": "gmail",
            "author_no": 54,
            "board_no": 4,
            "created_at": "2023-09-11T08:23:30",
            "title": "test13",
            "content": "content test123",
            "comment_disabled": true
 */
}