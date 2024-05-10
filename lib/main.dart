
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home page',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Click icon to go user pages'),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return UsersPage();
                  }));
                },
                icon: Icon(
                  Icons.face,
                  color: Colors.green,
                  size: 35,
                ))
          ],
        ),
      ),
    );
  }
}

class UsersPage extends StatefulWidget {
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  Icon currentIconForPass = Icon(Icons.visibility);
  bool showPass = true;
  String query = "";
  dynamic data;
  int currentPage = 0;
  int totalPages = 0;
  int pageSize = 20;

  TextEditingController queryTEContoller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'AppBar : ${query} : ${currentPage} / ${totalPages}',
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              margin: EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Container(
                    height: 40,
                    margin: EdgeInsets.only(left: 30, right: 45),
                    child: TextField(
                      obscureText: !showPass,
                      onChanged: (text){
                        setState(() {});
                      },
                      textAlign: TextAlign.center,
                      controller: queryTEContoller,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: (){
                               setState(() {
                                 // alternativly algorithm : showPass = !showPass  AND   Icon( showPass ? Icons.Visibility : Icons.Visibility_off);
                                 if(showPass) {
                                   this.currentIconForPass = Icon(Icons.visibility_off);
                                   this.showPass = false;
                                 }
                                 else {
                                   this.currentIconForPass = Icon(Icons.visibility);
                                    this.showPass = true;
                                 }

                               });
                              },
                              icon: this.currentIconForPass,
                          ),
                          hintText: 'Nom utilisateur',
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)))),
                    ),
                  )),
                  Container(
                      // search button
                      height: 40,
                      margin: EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            this.query = queryTEContoller.text;
                            _search(query);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(5)),
                        child: Icon(
                          Icons.search,
                          size: 25,
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(left: 15, right: 15),
                  itemCount: (data == null)? 0 : data['items'].length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(data['items'][index]['avatar_url']),
                                radius: 25,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text('${data['items'][index]['login']}')
                            ],
                          ),
                          CircleAvatar(
                            child: Text("${data['items'][index]['score']}"),
                          )
                        ],
                      )
                    );
                  }
                  ),
            )
          ],
        ));
  }

  Future<void> _search(String query) async {
    Uri url = Uri.https('api.github.com', '/search/users', {'q': query, 'per_page' : '$pageSize', 'page' : '$currentPage'});
    print(url);

    var response = await http.get(url);
    if(response.statusCode == 200 ) {
      setState(() {
        data = jsonDecode(response.body) as Map<String, dynamic>;
        print(data);
        if(data['total_count'] % pageSize == 0){
          totalPages = data['total_count']~/pageSize;
        }
        else {
          totalPages = (data['total_count']/pageSize).floor() + 1;

        }


      });
    } else {
      print('Request failed with status : ${response.statusCode}');
    }

  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => new Size.fromHeight(50);
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Text(
        'AppBar',
      ),
      centerTitle: true,
    );
  }
}
