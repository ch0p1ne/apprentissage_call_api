import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Repository_home extends StatefulWidget {
  String login;
  Repository_home({super.key, required this.login});

  @override
  State<Repository_home> createState() => _Repository_homeState();
}

class _Repository_homeState extends State<Repository_home> {
  dynamic dataRepository;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Repository de  ${widget.login}'),
          backgroundColor: Colors.blue,
          actions: [],
        ),
        body: ListView.separated(
            itemBuilder: (context, index) => ListTile(
                  title: Text("${dataRepository[index]['name']}"),
                ),
            separatorBuilder: (context, index) => const Divider(
                  height: 2,
                  color: Colors.green,
                ),
            itemCount: dataRepository == null ? 0 : dataRepository.length));
  }

  Future<void> loadRepository() async {
    Uri url = Uri.https('api.github.com', '/users/${widget.login}/repos', {});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        dataRepository = jsonDecode(response.body) as List<dynamic>;
      });
    } else {
      print('Response failed with code : ${response.statusCode}');
    }
  }
}
