import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../model/board_list.dart';
import '../../model/comment.dart';
import '../../model/error.dart';
import '../../model/post.dart';
import '../../provider/userApi.dart';

typedef DemoContentBuilder = Widget Function(
    BuildContext context, quill.QuillController? controller);

class PostDetailPage extends StatefulWidget {
  final int postNo;
  const PostDetailPage({super.key, required this.postNo});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late quill.QuillController _controller;
  bool isLoading = true;
  late var boardNo;
  late Board board;
  late int numComms;
  final FocusNode _focusNode = FocusNode();
  List<Comment> comments = [];
  TextEditingController _commentController = TextEditingController();
  String? session;
  FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initBoardView();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    // initBoardView();

    return Scaffold(
      body: isLoading
          ? const Center(child: const CircularProgressIndicator(color: Colors.blue,))
          :
      Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 60, 8, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(board.author),
              Container( height:1.0,
                width: MediaQuery.of(context).size.width * 1,
                color:Colors.black54,),
              _content(),
              Container( height:1.0,
                width: MediaQuery.of(context).size.width * 1,
                color:Colors.black54,),
              commentWidget(),
            ]
          ),
        )
      ),
      bottomNavigationBar:
      BottomAppBar(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: deviceWidth - 70,
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Input',
                  ),
                ),
              ),
              IconButton(
                iconSize: 20,
                icon: Icon(Icons.send),
                onPressed: () async {
                  session = session == null ? await storage.read(key: "session") : session;
                  List<String> split = session!.split(',,');
                  var headers = {
                    "norKor_token" : split[2],
                  };
                  var response = await http.post(Uri.parse(baseUrl + '/comment'),
                    headers: headers,
                    body: {
                      'comment' : _commentController.text,
                      'board_no' : board.boardNo.toString()
                    }
                  );
                  if(response.statusCode != 200){
                    var body = json.decode(utf8.decode(response.bodyBytes));
                    ErrorMessage error = ErrorMessage.fromJson(body);
                    _showErrorSnackBar(error);
                  }
                  setState(() {
                    _commentController = TextEditingController();
                    initBoardView();
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void initBoardView() async{
    Map<String, String> queryString = Map();
    queryString['board_no'] = '${widget.postNo}';
    session = session == null ? await storage.read(key: "session") : session;
    List<String> split = session!.split(',,');
    var headers = {
      "Content-Type" : "application/json",
      "Accept" : "application/json",
      "norKor_token" : split[2],
    };
    var response = await http.get(Uri.parse(baseUrl + '/board').replace(queryParameters: queryString),
      headers: headers,
    );
    // ResponseData response = await SendData.doGet(context, '/board', queryString: queryString);
    var body = json.decode(utf8.decode(response.bodyBytes));
    PostDetail post = PostDetail.fromJson(body);
    print('${post.board.createdAt}');
    _controller = quill.QuillController(
          document: quill.Document.fromJson(jsonDecode(post.board.toJson()['content'])),
          selection: const TextSelection.collapsed(offset: 0)
    );
    setState(() {
      List<Comment> temp = [];
      if(post.comments.length > 0) {
        print('${post.comments[0]}');
        for(int i = 0; i < post.comments.length; i++){
          temp.add(Comment.fromJson(post.comments[i]));
        }
        // comments = List.from(comments.reversed);
      }
      comments = temp;
      board = post.board;
      isLoading = false;
    });
  }

  Widget _title(FetchPost post){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.chevron_left, size: 30,)),
            Text('${board.title}',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 38.0),
          child: Row(
            children: [
              Container(
                child: post.profileImg == null ?
                ClipRRect(
                  child: Image.asset(
                    'images/no_profile_img.png',
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                  ),
                ) :
                ClipRRect(
                  child: Image.network(
                    width: 35,
                    height: 35,
                    '${post.profileImg}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${post.userName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text('${DateTime.parse(board.createdAt)}')
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _content(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0, top: 10),
      child: quill.QuillEditor(
        controller: _controller,
        focusNode: _focusNode,
        embedBuilders: FlutterQuillEmbeds.builders(),
        scrollController: ScrollController(),
        scrollable: true,
        padding: EdgeInsets.zero,
        autoFocus: false,
        readOnly: true,
        expands: false,
      ),
    );
  }

  Widget commentWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('댓글 (${comments.length})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        GestureDetector(
          child: Container(
            height: 40,
            color: Color.fromRGBO(227, 226, 226, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('댓글 전체보기',
                  style: TextStyle(
                    fontSize: 15
                  ),
                ),
                Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 15,)
              ],
            ),
          ),
          onTap: (){

          },
        ),
        ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 10, bottom: 5),
          shrinkWrap: true,
          children: getCommentsTop10(),
        )
      ],
    );
  }

  Widget _commentView(Comment comm){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              comm.upCommNo != null ?
              Icon(Icons.subdirectory_arrow_right_rounded, size: 15, color: Colors.grey,) : Container(),
              Container(
                child: comm.author.profile == null ?
                ClipRRect(
                  child: Image.asset(
                    'images/no_profile_img.png',
                    width: 25,
                    height: 25,
                    fit: BoxFit.cover,
                  ),
                ) :
                ClipRRect(
                  child: Image.network(
                    width: 25,
                    height: 25,
                    '${comm.author.profile}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${comm.author.name}',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text('${DateTime.parse(board.createdAt).year}.${DateTime.parse(board.createdAt).month}.${DateTime.parse(board.createdAt).day}',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: (comm.upCommNo != null ? 18.0 : 0.0)),
            child: Text('${comm.comment}',
              style: TextStyle(
                fontSize: 15
              ),
            ),
          ),
          Container( height:1.0,
            width: MediaQuery.of(context).size.width * 1,
            color:Colors.black54,),
        ],
      ),
    );
  }

  List<Widget> getCommentsTop10(){
    List<Widget> commentWidget = [];
    for(int i = 0; i< comments.length; i++){
      if(i < 10){
        commentWidget.add(
          _commentView(comments[i])
        );
      }
    }
    commentWidget = List.from(commentWidget.reversed);
    return commentWidget;
  }

  void _showErrorSnackBar(ErrorMessage error){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message),
          duration: const Duration(seconds: 3),
        )
    );
  }
}
