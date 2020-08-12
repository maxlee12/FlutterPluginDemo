//
//  OneshotViewController.m
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "OneshotViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "RecognizerFactory.h"
#import "PopupView.h"
#import "ISRDataHelper.h"

#define kOFFSET_FOR_KEYBOARD 110.0

#define GRAMMAR_TYPE_BNF    @"bnf"
#define GRAMMAR_TYPE_ABNF    @"abnf"
#define GRAMMAR_DICRECTORY  @"/grm"

@implementation OneshotViewController

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //adjust the UI for iOS 7
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    
    UIBarButtonItem *spaceBtnItem= [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardDown:)];
    [hideBtnItem setTintColor:[UIColor whiteColor]];
    UIToolbar * toolbar = [[ UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray * array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    //self.resultView.inputAccessoryView = toolbar;
    
    self.resultView.layer.cornerRadius = 8;
    self.resultView.layer.borderWidth = 1;
    self.resultView.layer.borderColor =[[UIColor whiteColor] CGColor];
    
    self.resultView.text = NSLocalizedString(@"M_IVW_Step", nil);
    
    self.popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, 300, 0, 0)];
    self.popUpView.ParentView = self.view;
    
    [self setExclusiveTouchForButtons:self.view];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [super viewWillAppear:animated];
    
    self.stopBtn.enabled = YES;
    self.startBtn.enabled = YES;
    self.uploadBtn.enabled = YES;
    self.engineBtn.enabled = YES;
    
    [self initParam];
    
    //the keyword list，such as "叮咚叮咚"
    self.wakeupWordsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"叮咚叮咚",@"0",nil];
    
    self.engineTypesArray = @[NSLocalizedString(@"K_ASR_cloud", nil),NSLocalizedString(@"K_ASR_local", nil)];
    self.isCanceled = NO;
    
    self.curResult = [[NSMutableString alloc] init];
    
    //default cloud grammar recognition
    self.engineType = [IFlySpeechConstant TYPE_CLOUD];
    self.grammarType = GRAMMAR_TYPE_ABNF;
    
    self.localgrammerId = nil;
    self.cloudGrammerid = nil;
    
    [self.startBtn setTitle:NSLocalizedString(@"K_IVW_cloud", nil) forState:UIControlStateNormal];
    
    self.iflyVoiceWakeuper = [IFlyVoiceWakeuper sharedInstance];
    self.iflyVoiceWakeuper.delegate = self;
    
    [_iflyVoiceWakeuper setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    //Instantiate IFlySpeechRecognizer singleton to build grammer
    self.iflySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"asr"];
    
    [self createDirec:GRAMMAR_DICRECTORY];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s",__func__);
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    
    [_iflySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [_iflyVoiceWakeuper setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    self.iflyVoiceWakeuper.delegate = nil;
    [self.iflyVoiceWakeuper cancel];
    
    [super viewWillDisappear:animated];
}

-(void)onKeyBoardDown:(id) sender
{
    [_resultView resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification *)aNotification {
    [self setViewSize:YES Notification:aNotification];
}

-(void)keyboardWillHide :(NSNotification *)aNotification{
    [self setViewSize:NO Notification:aNotification ];
}

//method to change the size of view whenever the keyboard is shown/dismissed
-(void)setViewSize:(BOOL)show Notification:(NSNotification*) notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = _resultView.frame;
    if (show) {
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    _resultView.frame = rect;
    
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setExclusiveTouchForButtons:(UIView *)myView
{
    for (UIView * button in [myView subviews]) {
        if([button isKindOfClass:[UIButton class]])
        {
            [((UIButton *)button) setExclusiveTouch:YES];
        }
        else if ([button isKindOfClass:[UIView class]])
        {
            [self setExclusiveTouchForButtons:button];
        }
    }
}


#pragma mark - Button handler
/*
 start speech recognition
 */
- (IBAction) onBtnStart:(id)sender
{
    if (![self isCommitted]) {
        [_popUpView showText:NSLocalizedString(@"M_ASR_UpGram", nil)];
        return;
    }
    
    self.resultView.text = NSLocalizedString(@"M_IVW_Ost", nil);
    
    
    //set the threshold for keyeword
    //for example, 0:1450;1:1450
    //0:the first keyword，1450:the threshold value of first keyword
    //1:the second keyword，1450:the threshold value of second keyword
    //The order of the keywords must be consistent with the resource file
    [_iflyVoiceWakeuper setParameter:@"0:1450" forKey:[IFlySpeechConstant IVW_THRESHOLD]];
    
    //set the path of resource file
    NSString *ivwResourcePath = [IFlyResourceUtil generateResourcePath:_wakupEnginPath];
    [self.iflyVoiceWakeuper setParameter:ivwResourcePath forKey:@"ivw_res_path"];

    //set engine type
    [_iflyVoiceWakeuper setParameter:self.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    
    [_iflyVoiceWakeuper setParameter:@"utf8" forKey:[IFlySpeechConstant RESULT_ENCODING]];
    
    [_iflyVoiceWakeuper setParameter:@"1000" forKey:[IFlySpeechConstant VAD_EOS]];
    
    //set session type,oneshot
    [_iflyVoiceWakeuper setParameter:@"oneshot" forKey:[IFlySpeechConstant IVW_SST]];
    
    [_iflyVoiceWakeuper setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    [_iflyVoiceWakeuper setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    [_iflyVoiceWakeuper setParameter:_grammBuildPath forKey:[IFlyResourceUtil GRM_BUILD_PATH]];
    
    [_iflyVoiceWakeuper setParameter:self.grammarType forKey:[IFlyResourceUtil GRAMMARTYPE]];
    
    if([self.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]])
    {
        [_iflyVoiceWakeuper setParameter:_aitalkResourcePath forKey:[IFlyResourceUtil ASR_RES_PATH]];
        //set local grammarID
        [_iflyVoiceWakeuper setParameter:_localgrammerId forKey:[IFlySpeechConstant LOCAL_GRAMMAR]];
        
    }
    else if([self.engineType isEqualToString: [IFlySpeechConstant TYPE_CLOUD]])
    {
        //set cloud grammarID
        [_iflyVoiceWakeuper setParameter:_cloudGrammerid forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
    }
    
    //start oneshot
    BOOL ret = [_iflyVoiceWakeuper startListening];
    if(ret)
    {
        self.stopBtn.enabled=YES;
        self.uploadBtn.enabled = NO;
        self.startBtn.enabled = NO;
        self.engineBtn.enabled = NO;
    }
    else
    {
        [_popUpView showText: NSLocalizedString(@"M_ISR_Fail", nil)];//Last session may be not over, recognition not supports concurrent multiplexing.
    }
}

/*
 stop recording
 */
- (IBAction) onBtnStop:(id) sender
{
    [self.iflyVoiceWakeuper stopListening];
    
    [_resultView resignFirstResponder];
    
    self.stopBtn.enabled=YES;
    self.uploadBtn.enabled = YES;
    self.startBtn.enabled = YES;
    self.engineBtn.enabled = YES;
}


/*
 set engine type
 */
- (IBAction) onSetEngineBtn:(id) sender
{
    [_resultView resignFirstResponder];
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"T_ASR_Engtype", nil)
        delegate:self cancelButtonTitle:nil
        destructiveButtonTitle:nil
        otherButtonTitles:nil];
    
    for (NSString* type in self.engineTypesArray) {
        [actionSheet addButtonWithTitle:type];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}


/*
 upload grammer
 */
- (IBAction) onBtnUpload:(id)sender
{
    self.startBtn.enabled = NO;
    self.stopBtn.enabled = YES;
    self.engineBtn.enabled = NO;
    self.uploadBtn.enabled = NO;
    
    [self showPopup];

    //build grammer
    [self buildGrammar];
}

#pragma mark - upload grammar

-(void) buildGrammar
{
    NSString *grammarContent = nil;

    //set engine type, clound or local
    [_iflySpeechRecognizer setParameter:self.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    [_iflySpeechRecognizer setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
    [_iflySpeechRecognizer setParameter:self.grammarType forKey:[IFlyResourceUtil GRAMMARTYPE]];

    [[IFlySpeechUtility getUtility] setParameter:@"asr" forKey:[IFlyResourceUtil ENGINE_START]];
    
    [_iflySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    if([self.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]])
    {
        grammarContent = [self readFile:_bnfFilePath];
        
        [_iflySpeechRecognizer setParameter:_grammBuildPath forKey:[IFlyResourceUtil GRM_BUILD_PATH]];
        [_iflySpeechRecognizer setParameter:_aitalkResourcePath forKey:[IFlyResourceUtil ASR_RES_PATH]];
    }
    else
    {
        grammarContent = [self readFile:_abnfFilePath];
    }
    
    //start build grammar
    [_iflySpeechRecognizer buildGrammarCompletionHandler:^(NSString * grammerID, IFlySpeechError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"errorCode=%d",[error errorCode]);
            
            if (![error errorCode]) {
                
                [_popUpView showText: NSLocalizedString(@"T_ISR_UpSucc", nil)];
                _resultView.text = grammarContent;
            }
            else {
                [_popUpView showText: [NSString stringWithFormat:@"%@:%d", NSLocalizedString(@"T_ISR_UpFail", nil), error.errorCode]];
            }
            
            //set grammer id
            if ([self.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]]) {
                _localgrammerId = grammerID;
            }
            else{
                _cloudGrammerid = grammerID;
            }
            
            self.startBtn.enabled = YES;
            self.engineBtn.enabled = YES;
            self.stopBtn.enabled = YES;
            self.uploadBtn.enabled = YES;
            
        });
        
    }grammarType:self.grammarType grammarContent:grammarContent];
    
}

/*
 read file
 */
-(NSString *)readFile:(NSString *)filePath
{
    NSData *reader = [NSData dataWithContentsOfFile:filePath];
    return [[NSString alloc] initWithData:reader
                                 encoding:NSUTF8StringEncoding];
}

-(BOOL) createDirec:(NSString *) direcName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *subDirectory = [documentsDirectory stringByAppendingPathComponent:direcName];
    
    BOOL ret = YES;
    if(![fileManager fileExistsAtPath:subDirectory])
    {
        ret = [fileManager createDirectoryAtPath:subDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return ret;
}

#pragma mark - IFlyVoiceWakeuperDelegate

/**
 volume callback,range from 0 to 30.
 */
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"%@：%d", NSLocalizedString(@"T_RecVol", nil),volume];
    [_popUpView showText: vol];
}

/**
 Beginning Of Speech
 */
- (void) onBeginOfSpeech
{
    [_popUpView showText: NSLocalizedString(@"T_RecNow", nil)];
}

/**
 End Of Speech
 */
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
    [_popUpView showText: NSLocalizedString(@"T_RecStop", nil)];
}

/**
 voice wakeup session completion.
 error.errorCode =
 0     success
 other fail
 */
- (void) onCompleted:(IFlySpeechError *) error
{
    NSLog(@"error=%d",[error errorCode]);
    
    if (error.errorCode!=0) {
        [_popUpView showText:[NSString stringWithFormat:@"Error:%d",error.errorCode]];
    }

    _stopBtn.enabled = NO;
    _startBtn.enabled = YES;
    self.uploadBtn.enabled = YES;
    self.engineBtn.enabled = YES;

}

/**
 result callback of voice wakeup
 resultDic：voice wakeup results
 */
-(void) onResult:(NSMutableDictionary *)resultDic
{
    
    NSLog(@"onResult");

    NSString *sst = [resultDic objectForKey:@"sst"];
    NSNumber *wakeId = [resultDic objectForKey:@"id"];
    NSString *score = [resultDic objectForKey:@"score"];
    NSString *bos = [resultDic objectForKey:@"bos"];
    NSString *eos = [resultDic objectForKey:@"eos"];
    NSString * wakeIDStr = [NSString stringWithFormat:@"%@",wakeId];
    
    NSLog(@"【【KEYWORD】   %@",[self.wakeupWordsDictionary objectForKey:wakeIDStr]);
    NSLog(@"【SST】   %@",sst);
    NSLog(@"【ID】    %@",wakeId);
    NSLog(@"【SCORE】 %@",score);
    NSLog(@"【EOS】   %@",eos);
    NSLog(@"【BOS】   %@",bos);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\n"];
    
    [result appendFormat:@"【KEYWORD】   %@\n",[self.wakeupWordsDictionary objectForKey:wakeIDStr]];
    [result appendFormat:@"【SST】   %@\n",sst];
    [result appendFormat:@"【ID】    %@\n",wakeId];
    [result appendFormat:@"【SCORE】 %@\n",score];
    [result appendFormat:@"【EOS】   %@\n",eos];
    [result appendFormat:@"【BOS】   %@\n\n",bos];
    
    [result appendFormat:@"【ASR Results】\n"];
    
    self.curResult = result;
    _resultView.text = result;
}

- (void) onEvent:(int)eventType isLast:(BOOL)isLast arg1:(int)arg1 data:(NSMutableDictionary *)eventData
{
    NSLog(@"onEvent eventType=%d,isLast=%d",eventType,isLast);
    
    if( eventType == IFlySpeechEventTypeIVWResult )
    {
        NSMutableString *result = [[NSMutableString alloc] init];
        NSString * resultFromJson = nil;
        
        NSDictionary *dic = eventData;
        
        for (NSString *key in dic) {
            
            [result appendFormat:@"\n%@",key];
            NSLog(@"----%@",key);
            if([self.engineType isEqualToString:[IFlySpeechConstant TYPE_LOCAL]])
            {
                resultFromJson =  [ISRDataHelper stringFromJson:result];
                [self.curResult appendString:resultFromJson];
            }
            else
            {
                resultFromJson =  [ISRDataHelper stringFromABNFJson:result];
                [self.curResult appendString:resultFromJson];
            }
            [self.curResult appendString:@"\n"];
        }

        _resultView.text = self.curResult;
        
        if(isLast)
        {
            [_resultView resignFirstResponder];
            
            self.stopBtn.enabled=YES;
            self.startBtn.enabled = YES;
            self.uploadBtn.enabled = YES;
            self.engineBtn.enabled = YES;
        }
    }
}

-(void) showPopup
{
    [_popUpView showText: NSLocalizedString(@"T_ISR_Uping", nil)];
}

-(BOOL) isCommitted
{
    if ([self.engineType isEqualToString:[IFlySpeechConstant TYPE_LOCAL]]) {
        if(_localgrammerId == nil || _localgrammerId.length ==0)
            return NO;
    }
    else{
        if (_cloudGrammerid == nil || _cloudGrammerid.length == 0) {
            return NO;
        }
    }
    return YES;
}


#pragma mark - Initialization

/*
 initialize params
 */
-(void) initParam
{
    
    NSString *documentsPath = nil;
    NSArray *appArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([appArray count] > 0) {
        documentsPath = [appArray objectAtIndex:0];
    }
    NSString *appPath = [[NSBundle mainBundle] resourcePath];
    
    _grammBuildPath = [documentsPath stringByAppendingString:GRAMMAR_DICRECTORY];
    
    _aitalkResourcePath = [[NSString alloc] initWithFormat:@"fo|%@/aitalk/common.jet",appPath] ;
    
    _bnfFilePath = [[NSString alloc] initWithFormat:@"%@/oneshotbnf/oneshot_local.bnf",appPath];
    
    _abnfFilePath = [[NSString alloc] initWithFormat:@"%@/oneshotbnf/oneshot_cloud.abnf",appPath];
    
    _wakupEnginPath = [[NSString alloc] initWithFormat:@"%@/ivw/%@.jet",appPath,APPID_VALUE];
}

#pragma mark Set Engine UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [_iflySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iflyVoiceWakeuper setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            self.engineType  = [IFlySpeechConstant TYPE_CLOUD];
            self.grammarType = GRAMMAR_TYPE_ABNF;
            self.localgrammerId = nil;
            [self.startBtn setTitle:NSLocalizedString(@"K_IVW_cloud", nil) forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            [_iflySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iflyVoiceWakeuper setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            self.engineType  = [IFlySpeechConstant TYPE_LOCAL];
            self.cloudGrammerid = nil;
            [self.startBtn setTitle:NSLocalizedString(@"K_IVW_local", nil) forState:UIControlStateNormal];
            self.grammarType = GRAMMAR_TYPE_BNF;
        }
            break;
        default:
            break;
    }
}

@end
