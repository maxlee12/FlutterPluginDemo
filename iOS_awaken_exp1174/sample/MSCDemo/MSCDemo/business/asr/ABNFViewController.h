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
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

/**
 demo of Grammar Recognition (ASR)
 
 Five steps to integrating Grammar Recognition as follows:
 1.Instantiate IFlySpeechRecognizer singleton and IFlyDataUploader;
 2.Upload grammar file and acquire grammarID. Please refer to the inteface of buildGrammer in ABNFViewController.m for specific implementation;
 3.Set recognition params, especially obtained grammarID above;
 4.Add IFlySpeechRecognizerDelegate methods selectively;
 5.Start recognition;
 */
@interface ABNFViewController : UIViewController<IFlySpeechRecognizerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;//Recognition conrol
@property (nonatomic, strong) NSString             * cloudGrammerid;//cloud grammarID
@property (nonatomic, strong) NSString             * localgrammerId;//local grammarID
@property (nonatomic, weak)   IBOutlet UITextView  * resultView;
@property (nonatomic, strong) PopupView            * popUpView;
@property (nonatomic, weak)   IBOutlet UIButton    * startBtn;
@property (nonatomic, weak)   IBOutlet UIButton    * stopBtn;
@property (nonatomic, weak)   IBOutlet UIButton    * cancelBtn;
@property (nonatomic, weak)   IBOutlet UIButton    * uploadBtn;
@property (nonatomic, weak)   IBOutlet UIButton    * engineBtn;
@property (nonatomic, strong) IFlyDataUploader     * uploader;
@property (nonatomic, strong) NSMutableString      * curResult;//the results of current session
@property (nonatomic)         BOOL                  isCanceled;

@property (nonatomic)         NSString             * engineType;//the engine type of grammar recognition
@property (nonatomic)         NSString             * grammarType;//the type of grammar recognition
@property (nonatomic, strong) NSArray              * engineTypes;

-(void)setViewSize:(BOOL)movedUp Notification:(NSNotification*) notification;
@end
