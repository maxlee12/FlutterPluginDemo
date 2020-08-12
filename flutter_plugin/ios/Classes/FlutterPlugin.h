#import <Flutter/Flutter.h>
#import "IFlyMSCFunction.h"

@interface FlutterPlugin : NSObject<FlutterPlugin,FlutterStreamHandler>
@property (nonatomic, strong)IFlyMSCFunction *iFlyMSCFunction;
@end
