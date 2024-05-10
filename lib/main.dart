
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:apprentissage_call_api/pages/repository_home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
      appBar: const MyAppBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Click icon to go user pages'),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const UsersPage();
                  }));
                },
                icon: const Icon(
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
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  Icon currentIconForPass = const Icon(Icons.visibility);
  bool showPass = true;
  String query = "";
  dynamic data;
  int currentPage = 0;
  int totalPages = 0;
  int pageSize = 20;
  List<dynamic> items = [];
  ScrollController scrollController = ScrollController();

  TextEditingController queryTEContoller = TextEditingController();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(() {
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if(currentPage < totalPages) {
          setState(() {
            ++currentPage;
            _search(query);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'AppBar : $query : $currentPage / $totalPages',
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              margin: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Container(
                    height: 40,
                    margin: const EdgeInsets.only(left: 30, right: 45),
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
                                   currentIconForPass = const Icon(Icons.visibility_off);
                                   showPass = false;
                                 }
                                 else {
                                   currentIconForPass = const Icon(Icons.visibility);
                                    showPass = true;
                                 }

                               });
                              },
                              icon: currentIconForPass,
                          ),
                          hintText: 'Nom utilisateur',
                          contentPadding: const EdgeInsets.all(10),
                          border: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)))),
                    ),
                  )),
                  Container(
                      // search button
                      height: 40,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: const BoxDecoration(),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            items = [];
                            currentPage = 0;
                            query = queryTEContoller.text;
                            _search(query);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(5)),
                        child: const Icon(
                          Icons.search,
                          size: 25,
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(height: 20, color: Colors.amber,),
                padding: const EdgeInsets.only(left: 15, right: 15),
                  controller: scrollController,
                  itemCount: (data == null)? 0 : items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Repository_home(login: items[index]['login'])
                            )
                        );
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(items[index]['avatar_url']),
                                radius: 25,
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Text('${items[index]['login']}')
                            ],
                          ),
                          CircleAvatar(
                            child: Text("${items[index]['score']}"),
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
        items.addAll(data['items']);
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
  @override
  Size get preferredSize => const Size.fromHeight(50);
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: const Text(
        'AppBar',
      ),
      centerTitle: true,
    );
  }
}
