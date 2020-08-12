//
//  RecognizerFactory.h
//  MSCDemo
//
//  Created by iflytek on 13-6-9.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

//#import <Foundation/Foundation.h>

@interface RecognizerFactory : NSObject

/*
 Instantiate IFlySpeechRecognizer singleton
 */
+(id) CreateRecognizer:(id)delegate Domain:(NSString*) domain;

@end
