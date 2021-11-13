import 'package:flutter/material.dart';

import 'package:pda_scan/pda_scan.dart';
import 'package:pda_scan_example/test.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result = " 没有显示内容";

  PdaScan pdaScan;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: <Widget>[
              SearchEdit(controller: TextEditingController(),
                  hintText: '输入', scanCallback: ([r, e]) {
                    print('返回结果${r.toString()}|| ${e.toString()}');
                  }),

            ],
          )
      ),
    );
  }

}
