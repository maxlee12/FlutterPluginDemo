//
//  IFlyMSCFunction.m
//  Runner
//
//  Created by law on 2020/8/12.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "IFlyMSCFunction.h"
#import "IFlyMSC/IFlyMSC.h"

@interface IFlyMSCFunction ()<IFlyVoiceWakeuperDelegate>

// 地理位置请求对象
//@property (nonatomic, strong) IFlyAIUILocationRequest* mLocationRequest;
@property (nonatomic, strong)IFlyVoiceWakeuper *iflyVoiceWakeuper;
@property (nonatomic, copy) NSString *globalSid;
@property (nonatomic, readwrite) int aiuiState;
@property (nonatomic, readwrite) BOOL autoTTS;

@end


@implementation IFlyMSCFunction

- (instancetype)init{
    
    if (self = [super init]) {
        
        [IFlySetting setLogFile:LVL_NORMAL];
        //Set APPID
        NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID_VALUE];
        //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
        [IFlySpeechUtility createUtility:initString];
        //
        self.iflyVoiceWakeuper = [IFlyVoiceWakeuper sharedInstance];
        self.iflyVoiceWakeuper.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        
             
    }
    
    return self;
}



- (void)applicationWillResignActive:(NSNotification *)notification{
    
    [self stopRecord];
}

#pragma mark method

- (void)startRecord{
    NSLog(@"startRecord");
    //set the threshold for keyeword
    //for example, 0:1450;1:1450
    //0:the first keyword，1450:the threshold value of first keyword
    //1:the second keyword，1450:the threshold value of second keyword
    //The order of the keywords must be consistent with the resource file
    NSString *thresStr = [NSString stringWithFormat:@"0:%d",1450];
    [self.iflyVoiceWakeuper setParameter:thresStr forKey:[IFlySpeechConstant IVW_THRESHOLD]];
    
    //set session type
    [self.iflyVoiceWakeuper setParameter:@"wakeup" forKey:[IFlySpeechConstant IVW_SST]];
    
    //set the path of resource file
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *wordPath = [[NSString alloc] initWithFormat:@"%@/%@.jet",resPath,APPID_VALUE];
    NSString *ivwResourcePath = [IFlyResourceUtil generateResourcePath:wordPath];
    
    NSLog(@"ivwResourcePath:%@",ivwResourcePath);
    //
    [self.iflyVoiceWakeuper setParameter:ivwResourcePath forKey:@"ivw_res_path"];
    
    //set session continuation state after the service is successful.
    //0: the session ends after one wakeup; 1: the session continues after wakeup
    [self.iflyVoiceWakeuper setParameter:@"1" forKey:[IFlySpeechConstant KEEP_ALIVE]];
    
    //set audio source
    [self.iflyVoiceWakeuper setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //set the audio path saved by recorder
    [self.iflyVoiceWakeuper setParameter:@"ivw.pcm" forKey:@"ivw_audio_path"];

    BOOL ret = [self.iflyVoiceWakeuper startListening];
    if(ret)
    {
        if(self.resultEventBlock){
            self.resultEventBlock(@{@"start":@"startListening success"});
        }
    }else{
        
        if(self.resultEventBlock){
            self.resultEventBlock(@{@"start":@"startListening fail"});
        }
    }
    
}


//停止录音
- (void)stopRecord{
    NSLog(@"stopRecord");
    [self.iflyVoiceWakeuper stopListening];
}



#pragma mark - IFlyVoiceWakeuperDelegate

/**
 Beginning Of Speech
 **/
-(void) onBeginOfSpeech
{
    NSLog(@"onBeginOfSpeech");
    
}

/**
 End Of Speech
 **/
-(void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
}

/**
 voice wakeup session completion.
 error.errorCode =
 0     success
 other fail
 **/
-(void) onCompleted:(IFlySpeechError *)error
{
    if (error.errorCode!=0) {
        
        NSLog(@"%s,errorCode:%d",__func__,error.errorCode);
    }
    if (error.errorCode==10102) {
        
        NSLog(@"%s,errorCode:%d",__func__,error.errorCode);
    }
}


/**
volume callback,range from 0 to 30.
 **/
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"%@：%d", NSLocalizedString(@"T_RecVol", nil),volume];
    NSLog(@"onVolumeChanged:%@",vol);
}

/**
 result callback of voice wakeup
 resultDic：voice wakeup results
 **/
-(void) onResult:(NSMutableDictionary *)resultDic
{
    if(self.resultEventBlock){
        self.resultEventBlock(@{@"result":resultDic
                               });
    }
}


@end
