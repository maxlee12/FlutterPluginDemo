//
//  IVWViewController.m
//
//  Created by xlhou on 14-6-26.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ISRDataHelper.h"
#import "PopupView.h"
#import "Definition.h"
#import "IVWViewController.h"

@implementation IVWViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *spaceBtnItem = [[ UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                     target:nil action:nil];
    
    UIBarButtonItem *hideBtnItem = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Hide" style:UIBarButtonItemStylePlain
                                    target:self action:@selector(onKeyBoardDown:)];
    
    [hideBtnItem setTintColor:[UIColor whiteColor]];
    UIToolbar *toolbar = [[ UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray *array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    
    _resultView.inputAccessoryView = toolbar;
    _resultView.layer.borderWidth = 0.5f;
    _resultView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_resultView.layer setCornerRadius:7.0f];
    
    CGFloat posY = _resultView.frame.origin.y+_resultView.frame.size.height/6;
    _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, posY, 0, 0) withParentView:self.view];
    
    self.thresLable.text = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"T_IVW_Thres", nil),(int)self.thresSlider.value];
    
    self.iflyVoiceWakeuper = [IFlyVoiceWakeuper sharedInstance];
    self.iflyVoiceWakeuper.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.iflyVoiceWakeuper stopListening];
    
    [super viewWillDisappear:animated];
}

- (void)onKeyBoardDown:(id) sender
{
    [_resultView resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Handling

/**
 start voice wakeup
 **/
- (IBAction) onBtnStart:(id)sender
{
    _resultView.text = @"";
    
    //set the threshold for keyeword
    //for example, 0:1450;1:1450
    //0:the first keyword，1450:the threshold value of first keyword
    //1:the second keyword，1450:the threshold value of second keyword
    //The order of the keywords must be consistent with the resource file
    NSString *thresStr = [NSString stringWithFormat:@"0:%d",(int)self.thresSlider.value];
    [self.iflyVoiceWakeuper setParameter:thresStr forKey:[IFlySpeechConstant IVW_THRESHOLD]];
    
    //set session type
    [self.iflyVoiceWakeuper setParameter:@"wakeup" forKey:[IFlySpeechConstant IVW_SST]];
    
    //set the path of resource file
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *wordPath = [[NSString alloc] initWithFormat:@"%@/ivw/%@.jet",resPath,APPID_VALUE];
    NSString *ivwResourcePath = [IFlyResourceUtil generateResourcePath:wordPath];
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
        self.startBtn.enabled = NO;
        self.stopBtn.enabled=YES;
    }
}


/**
stop voice wakeup
 **/
- (IBAction) onBtnStop:(id) sender
{
    [self.iflyVoiceWakeuper stopListening];
}

/**
 set the threshold for keyeword
 **/
- (IBAction) onBtnSlider:(id)sender{
    
    self.thresLable.text = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"T_IVW_Thres", nil),(int)self.thresSlider.value];
}

#pragma mark - IFlyVoiceWakeuperDelegate

/**
 Beginning Of Speech
 **/
-(void) onBeginOfSpeech
{
    NSLog(@"%s",__func__);
}

/**
 End Of Speech
 **/
-(void) onEndOfSpeech
{
    NSLog(@"%s",__func__);
    self.stopBtn.enabled=NO;
    self.startBtn.enabled = YES;
    [_resultView resignFirstResponder];
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
        
        [_popUpView setText:[NSString stringWithFormat:@"Error: %d",error.errorCode]];
        [self.view addSubview:_popUpView];
        
        NSLog(@"%s,errorCode:%d",__func__,error.errorCode);
    }
    if (error.errorCode==10102) {
        
        [_popUpView showText: NSLocalizedString(@"M_ILO_File", nil)];
       // [self.view addSubview:_popUpView];
        
        NSLog(@"%s,errorCode:%d",__func__,error.errorCode);
    }
}


/**
volume callback,range from 0 to 30.
 **/
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"%@：%d", NSLocalizedString(@"T_RecVol", nil),volume];
    [_popUpView showText: vol];
}


/**
 result callback of voice wakeup
 resultDic：voice wakeup results
 **/
-(void) onResult:(NSMutableDictionary *)resultDic
{

    NSString *sst = [resultDic objectForKey:@"sst"];
    NSNumber *wakeId = [resultDic objectForKey:@"id"];
    NSString *score = [resultDic objectForKey:@"score"];
    NSString *bos = [resultDic objectForKey:@"bos"];
    NSString *eos = [resultDic objectForKey:@"eos"];
    NSString *keyword = [resultDic objectForKey:@"keyword"];
    
    NSLog(@"【KEYWORD】   %@",keyword);
    NSLog(@"【SST】   %@",sst);
    NSLog(@"【ID】    %@",wakeId);
    NSLog(@"【SCORE】 %@",score);
    NSLog(@"【EOS】   %@",eos);
    NSLog(@"【BOS】   %@",bos);
    
    NSLog(@"");
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\n"];
    
    [result appendFormat:@"【KEYWORD】        %@\n",keyword];
    [result appendFormat:@"【SST】        %@\n",sst];
    [result appendFormat:@"【ID】         %@\n",wakeId];
    [result appendFormat:@"【SCORE】      %@\n",score];
    [result appendFormat:@"【EOS】        %@\n",eos];
    [result appendFormat:@"【BOS】        %@\n",bos];
    
    _result = result;
    self.result = result;
    _resultView.text = [NSString stringWithFormat:@"%@%@", _resultView.text,result];
    self.result=nil;
    [_resultView scrollRangeToVisible:NSMakeRange([_resultView.text length], 0)];

}

@end
