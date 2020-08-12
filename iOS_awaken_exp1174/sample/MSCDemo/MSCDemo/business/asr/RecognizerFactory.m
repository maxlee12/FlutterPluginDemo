//
//  RecognizerFactory.m
//  MSCDemo
//
//  Created by iflytek on 13-6-9.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "RecognizerFactory.h"
#import "IFlyMSC/IFlyMSC.h"

@implementation RecognizerFactory

/**
 Instantiate IFlySpeechRecognizer singleton
*/
+(id) CreateRecognizer:(id)delegate Domain:(NSString*) domain
{
    IFlySpeechRecognizer * iflySpeechRecognizer = nil;
    
    // recognition singleton without view
    iflySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    
    iflySpeechRecognizer.delegate = delegate;
    
    [iflySpeechRecognizer setParameter:domain forKey:[IFlySpeechConstant IFLY_DOMAIN]];

    [iflySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_SCH]];
    
    [iflySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //Set microphone as audio source
    [iflySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    return iflySpeechRecognizer;
}
@end
