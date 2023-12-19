import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;


import 'package:flutter/src/widgets/text.dart' as Text;

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/presigned_url.dart';
import '../../provider/userApi.dart';
import '../../utils/validate.dart';
import '../component/custom_radio_button.dart';
import '../component/custom_text_field.dart';
import 'custom_image_tap.dart';

class WritePage extends StatefulWidget {
  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  late List<bool> _isChecked;

  final storage = FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _content = TextEditingController();
  // final QuillController _controller = QuillController.basic();
  final MAIN_COLOR = Color.fromRGBO(148, 216, 239, 1.0);

  QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  Timer? _selectAllTimer;

  bool _possComment = true;
  // bool  = true;
  // bool _isPublic = true;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    //PostController p = Get.find();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () async{
                String? session = await storage.read(key: "session");
                List<String> split = session!.split(',,');
                var headers = {
                  "Content-Type" : "application/json",
                  "Accept" : "application/json",
                  "norKor_token" : split[2],
                };
                if(_formKey.currentState!.validate()){
                  print(json.encode(_controller.document.toDelta().toJson()));
                  var post = await http.post(Uri.parse(baseUrl+'/board'),
                      body: json.encode({
                        'title': _title.text,
                        'content': json.encode(_controller.document.toDelta().toJson()).toString(),
                        'comment_disabled': (!_possComment).toString(),
                      }),
                    headers: headers,
                  );
                  if(post.statusCode == 200){
                    print(_controller.document.toDelta().toJson());
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text.Text("post",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 18.0, bottom: 20, right: 18),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: CustomTextFormField(
                controller: _title,
                hint: "Title",
                funValidator: CheckValidate().validateTitle(),
              ),
            ),
            QuillToolbar.basic(
              showLink: false,
              showQuote: false,
              showBackgroundColorButton: false,
              showInlineCode: false,
              showClearFormat: false,
              showSubscript: false,
              showSuperscript: false,
              showRedo: false,
              showUndo: false,
              showFontSize: false,
              showFontFamily: false,
              showBoldButton: false,
              showItalicButton: false,
              showUnderLineButton: false,
              showStrikeThrough: false,
              showColorButton: false,
              showCodeBlock: false,
              showIndent: false,
              showSearchButton: false,
              controller: _controller,
              embedButtons: FlutterQuillEmbeds.buttons(
                showVideoButton: false,
                showCameraButton: false,
                onImagePickCallback: _onImagePickCallback,
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      child:
                      _buildWelcomeEditor(context),
                      height: 478,
                    ),
                  ),
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                children: [
                  // _selectPostType(),
                  // Container( height:1.0,
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   color:Colors.black54,),
                  // _tagSelections(),
                  // Container( height:1.0,
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   color:Colors.black54,),
                  // _publicOrPrivate(),
                  Container( height:1.0,
                    width: MediaQuery.of(context).size.width * 0.9,
                    color:Colors.black54,),
                  _settingPost()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile = await file.copy('${appDocDir.path}/${basename(file.path)}');
    return uploadFile(copiedFile);
  }

  Future<String> _onImagePaste(Uint8List imageBytes) async {
    // Saves the image to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = await File(
        '${appDocDir.path}/${basename('${DateTime.now().millisecondsSinceEpoch}.png')}')
        .writeAsBytes(imageBytes, flush: true);
    return file.path.toString();
  }



  Widget _buildWelcomeEditor(BuildContext context) {
    Widget quillEditor = QuillEditor(
      controller: _controller!,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: _focusNode,
      autoFocus: false,
      readOnly: false,
      placeholder: 'Add content',
      enableSelectionToolbar: true,
      expands: false,
      padding: EdgeInsets.zero,
      onImagePaste: _onImagePaste,
      // onTapUp: (details, p1) {
      //   return _onTripleClickSelection();
      // },
      customStyles: DefaultStyles(
        h1: DefaultTextBlockStyle(
            const TextStyle(
              fontSize: 32,
              color: Colors.black,
              height: 1.15,
              fontWeight: FontWeight.w300,
            ),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null),
        sizeSmall: const TextStyle(fontSize: 9),
        subscript: const TextStyle(
          fontFamily: 'SF-UI-Display',
          fontFeatures: [FontFeature.subscripts()],
        ),
        superscript: const TextStyle(
          fontFamily: 'SF-UI-Display',
          fontFeatures: [FontFeature.superscripts()],
        ),
      ),
      embedBuilders: [
        ImageEmbedBuilder(),
        // TimeStampEmbedBuilderWidget()
      ],
    );

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 15,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: quillEditor,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> uploadFile(File file) async {
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    var headers = {
      "Content-Type" : "application/json",
      "Accept" : "application/json",
      "norKor_token" : split[2],
    };
    var response = await http.post(Uri.parse(baseUrl + '/generate-presigned'),
      body: jsonEncode({
        "filename" : file.path.split('/').last,
      }),
      headers: headers,
    );
    var presignedUrl = PresignedUrl.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    var response2 = await http.put(Uri.parse(presignedUrl.url), body: file.readAsBytesSync()).then((value){print(value.bodyBytes);});
    return presignedUrl.url.split('?x-')[0];
  }

  Widget _publicOrPrivate(){
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text.Text('공개',
                style: TextStyle(
                  fontSize: 15
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text.Text('나의 학교 소속 사람들에게만 이 글을 공개합니다.',
                  style: TextStyle(
                      fontSize: 11
                  ),
                ),
              )
            ],
          ),
          // Container(
          //   padding: EdgeInsets.only(right: 174, top: 5),
          //   child: CustomRadioButton(
          //       width: 110,
          //       height: 20,
          //       padding: 0,
          //       defaultSelected: _isPublic,
          //       buttonLables: ['전체공개', '내 학교 공개'],
          //       buttonValues: [true, false],
          //       radioButtonValue: (val){
          //         setState(() {
          //           _isPublic = val;
          //         });
          //       },
          //       unSelectedColor: Colors.white,
          //       selectedColor: MAIN_COLOR
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _settingPost(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.Text('글쓰기 설정',
          style: TextStyle(
            fontSize: 15
            ,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.Text('댓글 허용',
              style: TextStyle(
                  fontSize: 12,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5),
              child: CustomRadioButton(
                  width: 90,
                  height: 20,
                  padding: 0,
                  defaultSelected: _possComment,
                  buttonLables: ['허용', '허용안함'],
                  buttonValues: [true, false],
                  radioButtonValue: (val){
                    setState(() {
                      _possComment = val;
                    });
                  },
                  unSelectedColor: Colors.white,
                  selectedColor: MAIN_COLOR
              ),
            )
          ],
        ),

      ],
    );
  }

  Widget _selectPostType(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text.Text('게시글 설정',
                style: TextStyle(
                    fontSize: 15
                ),
              ),
            ],
          ),
          // Container(
          //   padding: EdgeInsets.only(right: 174, top: 5),
          //   child: CustomRadioButton(
          //       width: 110,
          //       height: 20,
          //       padding: 0,
          //       defaultSelected: _postType,
          //       buttonLables: ['도움글', '노하우'],
          //       buttonValues: ['assist', 'know_how'],
          //       radioButtonValue: (val){
          //         setState(() {
          //           _postType = val;
          //         });
          //       },
          //       unSelectedColor: Colors.white,
          //       selectedColor: MAIN_COLOR
          //   ),
          // )
        ],
      ),
    );
  }

}



