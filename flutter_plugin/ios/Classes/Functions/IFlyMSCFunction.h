//
//  AIUIFunction.h
//  Runner
//
//  Created by law on 2020/8/12.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define APPID_VALUE           @"5cad6c73"

NS_ASSUME_NONNULL_BEGIN

@interface IFlyMSCFunction : NSObject

// 开始
- (void)startRecord;
// 结束
- (void)stopRecord;
@property (nonatomic,copy) void (^resultEventBlock)(NSDictionary *result);

@end

NS_ASSUME_NONNULL_END
