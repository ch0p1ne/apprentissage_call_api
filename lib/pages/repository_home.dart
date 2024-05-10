import 'package:flutter/material.dart';


class Repository_home extends StatelessWidget {
  String login;
  Repository_home({required this.login});


  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repository de  $login'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Repository de  $login'),
      ),
    );
    ;
  }
}