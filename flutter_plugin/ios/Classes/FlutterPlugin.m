#import "FlutterPlugin.h"

@implementation FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_plugin"
            binaryMessenger:[registrar messenger]];
  FlutterPlugin* instance = [[FlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
    // FlutterEventChannel
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"flutter_plugin/Event" binaryMessenger:registrar.messenger];
    [eventChannel setStreamHandler:instance];
}

- (IFlyMSCFunction*)iFlyMSCFunction{
    if(!_iFlyMSCFunction){
        _iFlyMSCFunction = [[IFlyMSCFunction alloc] init];
    }
    return _iFlyMSCFunction;
}
 
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }
  else if ([@"startWakeup" isEqualToString:call.method]) {
      NSLog(@"flutter_plugin - startWakeup--");
      [self.iFlyMSCFunction startRecord];
  }
  else if ([@"stopWakeup" isEqualToString:call.method]) {
      NSLog(@"flutter_plugin - stopWakeup--");
      [self.iFlyMSCFunction stopRecord];
      
  }
  else {
    result(FlutterMethodNotImplemented);
  }
    
}

#pragma mark - <FlutterStreamHandler>
// // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    NSLog(@"flutter - onListenWithArguments--%@",arguments);
    // arguments flutter给native的参数
    // 回调给flutter， 建议使用实例指向，因为该block可以使用多次
    if (events) {
        self.iFlyMSCFunction.resultEventBlock  = ^(NSDictionary *dic){
            events(dic);
        };

    }
    return nil;
}

/// flutter不再接收
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    // arguments flutter给native的参数
    NSLog(@"flutter - onCancelWithArguments");
    return nil;
}

@end
