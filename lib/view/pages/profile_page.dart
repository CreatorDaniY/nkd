import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:north_kor_defector/view/pages/post_detail.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../model/Account.dart';
import '../../model/board_list.dart';
import '../../model/error.dart';
import '../../model/post.dart';
import '../../model/presigned_url.dart';
import '../../provider/userApi.dart';

class ProfilePage extends StatefulWidget {
  Account? account;
  ProfilePage({super.key, required this.account});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum MenuEnum {
  editInfo('edit', 'edit profile'),
  editPw('changePW', 'change password'),
  logOut('log out', 'log out');

  const MenuEnum(this.code, this.displayName);
  final String code;
  final String displayName;

  // factory MenuEnum.getByCode(String code){
  //   return MenuEnum.values.firstWhere((value) => value.code == code,
  //       orElse: () => MenuEnum.undefined);
  // }
}

class _ProfilePageState extends State<ProfilePage> {
  late final deviceWidth = MediaQuery.of(context).size.width;
  late final deviceHeight = MediaQuery.of(context).size.height;
  List<FetchPost> list = [];

  late String sessionKey;
  final storage = FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  bool _loading = true;
  late String? profile = widget.account?.profile;
  late String? name = widget.account?.name;
  final MAIN_COLOR = Color.fromRGBO(148, 216, 239, 1.0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMyPosts();
    initMyInfo();
  }

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
          actions: [
            PopupMenuButton<MenuEnum>(
              icon: Icon(Icons.settings),
              onSelected: (MenuEnum result) {
                if(result == MenuEnum.logOut){
                  logOut();
                }else{
                  // Navigator.push(context, route);
                }
              },
              itemBuilder: (BuildContext context) => MenuEnum.values
                  .map((value) => PopupMenuItem(
                value: value,
                child: Text(value.displayName),
              ))
                  .toList(),
            ),


          ],
        ),
        body: Container(
          child: _loading ? Center(child: const CircularProgressIndicator()) :
          Column(
            children: [
              Container(
                color: Colors.white,
                width: deviceWidth,
                height: deviceHeight / 5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          getImage(ImageSource.gallery);
                        },
                        child: Container(
                          child: profile == null ?
                          CircleAvatar(
                            radius: deviceWidth / 10,
                            backgroundImage: AssetImage(
                              'images/no_profile_img.png',
                            ),
                          ) :
                          CircleAvatar(
                            radius: deviceWidth / 10,
                            backgroundImage: NetworkImage(
                              '${profile}',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          height: deviceWidth /4,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text('${name}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: deviceWidth / 12
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: list.length,
                itemBuilder: (context, index){
                  return postItemList(list[index]);
                },
                shrinkWrap: true,
              ),
            ],
          ),
        )
    );
  }


  void initMyPosts() async{
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    var response = await http.get(Uri.parse(baseUrl + '/my-board-list'), headers: {
      'norKor_token' : split[2]
    });
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
      print(error.message);
    }else {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      var boardList = BoardList.fromJson(body);
      print('list : $list');
      list = boardList.items.map((e) => FetchPost.fromJson(e)).toList();
      setState(() {
        _loading = false;
      });
    }
  }



  Widget postItemList(FetchPost post){
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => PostDetailPage(postNo : post.boardNo),
          ),
        );

      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 10, 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: post.thumbnail == null ?
              ClipRRect(
                child: Image.asset(
                  'images/no_image_post.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ) :
              ClipRRect(
                child: Image.network(
                  width: 80,
                  height: 80,
                  '${post.thumbnail}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width:  deviceWidth - 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${post.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void logOut(){
    storage.delete(key: 'session');
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyApp()), (route) => false);
  }

  void initMyInfo() async {

  }

  Future<String> uploadFile(File file) async {
    print('${file.path}');
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
    print('${presignedUrl.url}');
    var response2 = await http.put(Uri.parse(presignedUrl.url), body: file.readAsBytesSync()).then((value){print(value.bodyBytes);});
    return presignedUrl.url.split('?x-')[0];
  }


  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      uploadFile(File(pickedFile.path)).then((value) async{
        String? session = await storage.read(key: "session");
        List<String> split = session!.split(',,');
        var headers = {
          "Content-Type" : "application/json",
          "Accept" : "application/json",
          "norKor_token" : split[2],
        };
        var response = await http.put(Uri.parse(baseUrl + '/change-profile'),
          body: jsonEncode({
            "profile" : value,
          }),
          headers: headers,
        );
        if(response.statusCode == 200){
          setState(() {
            profile = value;
          });
        }else{
          print('error occurred');
        }
      }); //가져온 이미지를 _image에 저장
    }

  }


}
