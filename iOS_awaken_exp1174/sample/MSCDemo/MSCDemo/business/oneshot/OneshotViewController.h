//
//  ABNFViewController.h
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFlyMSC/IFlyMSC.h"

//forward declare
@class PopupView;
@class IFlySpeechRecognizer;

/**
 demo of oneshot
 */
@interface OneshotViewController : UIViewController<IFlyVoiceWakeuperDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer * iflySpeechRecognizer;
@property (nonatomic,strong)  IFlyVoiceWakeuper    * iflyVoiceWakeuper;

@property (nonatomic, weak)   IBOutlet UITextView  * resultView;
@property (nonatomic, strong) PopupView            * popUpView;
@property (nonatomic, weak)   IBOutlet UIButton    * startBtn;
@property (nonatomic, weak)   IBOutlet UIButton    * stopBtn;
@property (nonatomic, weak)   IBOutlet UIButton    * uploadBtn;
@property (nonatomic, weak)   IBOutlet UIButton    * engineBtn;

@property (nonatomic, strong) NSMutableString      * curResult;//the results of current session
@property (nonatomic)         BOOL                  isCanceled;

@property (nonatomic, strong)         NSString             * engineType;//the engine type
@property (nonatomic, strong)         NSString             * grammarType;//the type of grammar recognition

@property (nonatomic, strong)         NSString             * cloudGrammerid;//cloud grammarID
@property (nonatomic, strong)         NSString             * localgrammerId;//local grammarID
@property (nonatomic, strong)         NSString             * grammBuildPath;
@property (nonatomic, strong)         NSString             * aitalkResourcePath;
@property (nonatomic, strong)         NSString             * bnfFilePath;
@property (nonatomic, strong)         NSString             * abnfFilePath;
@property (nonatomic, strong)         NSString             * wakupEnginPath;


@property (nonatomic, strong) NSArray              * engineTypesArray;

@property (nonatomic,strong)  NSDictionary         * wakeupWordsDictionary;

-(void)setViewSize:(BOOL)movedUp Notification:(NSNotification*) notification;
@end
