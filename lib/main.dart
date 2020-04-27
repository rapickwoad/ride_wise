import 'package:flutter/material.dart';
import 'mainscreen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ride Wise',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: mainScreen(),
    );
  }
}
