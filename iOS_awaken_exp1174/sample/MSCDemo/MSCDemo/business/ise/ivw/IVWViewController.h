//
//  ISRViewController.h
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyMSC.h"

//forward declare
@class PopupView;

/**
 demo of Voice Wakeup (IVW)
 
 Four steps to integrating Voice Wakeup as follows:
 1.Instantiate IFlyVoiceWakeuper singleton;
 2.Set Voice Wakeup params;
 3.Add IFlyVoiceWakeuperDelegate methods selectively;
 4.Start Voice Wakeup;
 **/
@interface IVWViewController : UIViewController <IFlyVoiceWakeuperDelegate>

@property (nonatomic, strong) IBOutlet UITextView  * resultView;
@property (nonatomic, strong) PopupView            * popUpView;

@property (nonatomic, strong) NSString             * result;

@property (nonatomic,strong)  NSDictionary         * words;
@property (nonatomic,strong)  IFlyVoiceWakeuper    * iflyVoiceWakeuper;

@property (weak, nonatomic) IBOutlet UIButton      *startBtn;
@property (weak, nonatomic) IBOutlet UIButton      *stopBtn;

@property (nonatomic, strong) IBOutlet UILabel     * thresLable;
@property (nonatomic, strong) IBOutlet UISlider    * thresSlider;

@end
