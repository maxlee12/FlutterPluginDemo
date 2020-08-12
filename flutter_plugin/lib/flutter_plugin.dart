
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_plugin');


  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // 创建事件通道
  static final EventChannel _eventChannel = EventChannel(
      "flutter_plugin/Event", const StandardMethodCodec());

  // 开始事件通道监听
  static startEventListen(Function _onEvent) async {
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError:(err){} );
  }

  // 开始服务
  static startWakeup(){
     _channel.invokeMethod("startWakeup");
  }
  // 停止服务
  static  stopWakeup() {
    _channel.invokeMapMethod("stopWakeup");
  }


}
