import 'dart:convert';
import 'dart:io';

import 'package:flat_list/flat_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:north_kor_defector/view/pages/post_detail.dart';
import 'package:north_kor_defector/view/pages/profile_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../model/Account.dart';
import '../../model/error.dart';
import '../../model/post.dart';
import '../../provider/post_provider.dart';
import '../../provider/userApi.dart';
import '../../utils/validate.dart';
import '../component/custom_text_field.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = FlutterSecureStorage();
  late final deviceWidth = MediaQuery.of(context).size.width;
  late final deviceHeight = MediaQuery.of(context).size.height;
  final _formKey = GlobalKey<FormState>();
  final _searchKeyword = TextEditingController();
  final MAIN_COLOR = Color.fromRGBO(148, 216, 239, 1.0);
  List<FetchPost> itemList = [];
  var _isGridVeiw = false;
  bool loading_prof = true;
  var profile;
  Account? account;
  late final provider = Provider.of<PostProvider>(context);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    permission();
    _initLoad();
    Future.microtask(() {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: SizedBox(
        height: 50,
        child: extendButton(context),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: (deviceHeight * 6 / 100), left: (deviceWidth * 3 / 100)),
                  child: Center(child: Image(image: AssetImage('images/logo_small.png'), width: 150, height: 50, color: Colors.black,)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: (deviceHeight * 7 / 100), right: (deviceWidth * 5 / 100)),
                  child: Row(
                      children: [
                        // Image(image: AssetImage('images/message.png'), width: 50,),
                        // Image(image: AssetImage('images/message.png'), width: 50,),
                        GestureDetector(
                          child: loading_prof ? const CircularProgressIndicator() : profile == null ? CircleAvatar(
                            radius: deviceWidth / 15,
                            backgroundImage: AssetImage(
                              'images/no_profile_img.png',
                            ),
                          ) : CircleAvatar(
                            radius: deviceWidth / 15,
                            backgroundImage: NetworkImage(
                              '${profile}',
                            ),
                          ),

                          // profile == null ? Image(image: AssetImage('images/no_profile_img.png'), width: 50,) : Image.network(profile, width: 50,),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) => ProfilePage(account: account,),
                              settings: RouteSettings(),
                            ),).then((value){
                              setState(() {
                                _initLoad();
                              });
                            })
                                // .then((value){setState(() {});})
                            ;
                          },
                        ),
                      ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 18),
            child: Text("커뮤니티",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.black
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 10),
          //   child: Row(
          //     children: [
          //       showMenuBtn('도움 페이지'),
          //       showMenuBtn('노하우'),
          //       // showMenuBtn('내 학교'),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Flexible(
                  child: Form(
                    key: _formKey,
                    child: CustomTextFormField(
                      controller: _searchKeyword,
                      hint: "Keyword",
                      funValidator: CheckValidate().validateTitle(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: OutlinedButton(
                    onPressed: () {


                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: MAIN_COLOR,
                      fixedSize: Size(70, 50),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                    ),
                    child: Text("search",
                      style: TextStyle(
                          fontSize: 11,
                          color:Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _postListView(),
          ),
        ],
      ),
    );
  }

  Widget showMenuBtn(String menu){
    return TextButton(
        onPressed: (){

        },
        child: Text(
          menu,
          style: TextStyle(
            fontSize: 16,
          ),
        ));
  }

  void searchBtnClick(){


  }

  void _initLoad() async{
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    var headers = {
      "Content-Type" : "application/json",
      "Accept" : "application/json",
      "norKor_token" : split[2],
    };
    await ApiClient.checkSession(context, split[2]).then((value){
      print('value is ${value?.profile}');
      setState(() {
        account = value;
      });
    });
    var response = await http.get(Uri.parse(baseUrl + '/hello-world'), headers: headers);
    if(response.statusCode == 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      PostResponse postResponse = PostResponse.fromJson(body);
      setState(() {
        profile = postResponse.profile;
        loading_prof = false;
      });
    }
  }

  void _showErrorSnackBar(ErrorMessage error){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message),
          duration: const Duration(seconds: 3),
        )
    );
  }

  FloatingActionButton extendButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/post');
      },
      child: const Icon(
        Icons.post_add,
        size: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

      foregroundColor: Colors.white,
      backgroundColor: MAIN_COLOR,
    );
  }


  _postListView(){
    final loading = provider.loading;
    final hasMore = provider.hasMore;
    final cache = provider.cache;
    final nextToken = provider.nextToken;

    if(loading && cache.length == 0){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    //
    //no loading no cache
    if(!loading && cache.length == 0){
      return Center(
        child: Text('포스트가 없습니다.'),
      );
    }

    return _isGridVeiw ? GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16
      ),
      padding: EdgeInsets.only(top: 10),
      itemCount: cache.length + 1,
      itemBuilder: (context, index){
        if(index < cache.length) {
          return postItemGrid(cache[index]);
        }

        if(!loading && hasMore){
          Future.microtask((){
            provider.fetchPosts(token: provider.nextToken);
          });
        }

        if(provider.hasMore) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        else
          return Center(
            child: Text('더이상 포스트가 없습니다.'),
          );

      },
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
    ) :
    ListView.builder(
      // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //   crossAxisCount: 2,
      //   crossAxisSpacing: 16
      // ),
      padding: EdgeInsets.only(top: 20),
      itemCount: cache.length + 1,
      itemBuilder: (context, index){
        if(index < cache.length) {
      /*    print(cache);
          provider.cache = [];
          provider.nextToken = '';*/
          return postItemList(cache[index]);
        }

        if(!loading && hasMore){
          Future.microtask((){
            provider.fetchPosts(token: provider.nextToken);
          });
        }

        if(provider.hasMore) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        else
          return Center(
            child: Text('더이상 포스트가 없습니다.'),
          );

      },
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
    );
  }

  Widget postItemList(FetchPost post){
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => PostDetailPage(postNo: post.boardNo,),
          ),
        ).then((value){
          setState(() {
            provider.cache = [];
          });
          Future.microtask(() {
            Provider.of<PostProvider>(context, listen: false).fetchPosts();
          });
        });
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
                  'images/logo_login.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  color: Colors.black,
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
              height: 80,
              width: deviceWidth - 152,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${post.title}',
                    maxLines: 2,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        child: post.profileImg == null ?
                        ClipRRect(
                          child: Image.asset(
                            'images/no_profile_img.png',
                            width: 15,
                            fit: BoxFit.cover,
                          ),
                        ) :
                        ClipRRect(
                          child: Image.network(
                            width: 15,
                            '${post.profileImg}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text('${post.userName}')
                    ],
                  )
                ],
              ),
            ),
            Column(
              children: [
                Image.asset('images/logo_login.png',
                  color: MAIN_COLOR,
                  width: 40,
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget postItemGrid(FetchPost post){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: post.thumbnail == null ?
            ClipRRect(
              child: Image.asset(
                'images/logo_login.png',
                width: deviceWidth * 6 / 17,
                height: 150,
                fit: BoxFit.cover,
                color: Colors.black,
              ),
            ) :
            ClipRRect(
              child: Image.network('${post.thumbnail}',
                height: 150,
                width: deviceWidth * 6 / 17,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${post.title}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      child: post.profileImg == null ?
                      ClipRRect(
                        child: Image.asset(
                          'images/no_profile_img.png',
                          width: 15,
                          fit: BoxFit.cover,
                        ),
                      ) :
                      ClipRRect(
                        child: Image.network(
                          width: 15,
                          '${post.profileImg}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text('${post.userName}',
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<bool> permission() async {
    Map<Permission, PermissionStatus> status =
    await [Permission.calendarFullAccess].request(); // [] 권한배열에 권한을 작성

    if (await Permission.calendarFullAccess.isGranted) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }
}



