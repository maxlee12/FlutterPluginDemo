import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin/flutter_plugin.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Map _wakeUpResult = {"result":"'Unknown'"};
  @override
  void initState() {
    super.initState();
    initPlatformState();
    FlutterPlugin.startEventListen(onEventCallBack);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // 开始服务
  startWakeup(){
    FlutterPlugin.startWakeup();
  }

  // 关闭服务
   stopWakeup(){
    FlutterPlugin.stopWakeup();
  }

  // 服务的事件回调
  onEventCallBack(dynamic event){

    print("handleEventListenResult  ${event}");
    if(event['result'] != null){
      setState(() {
        _wakeUpResult = event['result'];
      });
      stopWakeup();

    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('SDK WakeUp Result: $_wakeUpResult\n'),
              RaisedButton(onPressed:startWakeup,child: Text("开启唤醒功能"),),
              RaisedButton(onPressed:stopWakeup,child: Text("关闭唤醒功能"),),
            ],
          ),
        )
      ),
    );
  }
}
