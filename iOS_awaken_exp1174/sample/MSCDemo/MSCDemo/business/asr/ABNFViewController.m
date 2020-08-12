//
//  ABNFViewController.m
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "ABNFViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "RecognizerFactory.h"
#import "PopupView.h"
#import "ISRDataHelper.h"

#define kOFFSET_FOR_KEYBOARD 110.0

#define GRAMMAR_TYPE_BNF    @"bnf"
#define GRAMMAR_TYPE_ABNF    @"abnf"

@implementation ABNFViewController

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
    
    self.resultView.layer.cornerRadius = 8;
    self.resultView.layer.borderWidth = 1;
    self.resultView.layer.borderColor =[[UIColor whiteColor] CGColor];
    
    UIBarButtonItem *spaceBtnItem= [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardDown:)];
    UIToolbar * toolbar = [[ UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray * array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    //resultView.inputAccessoryView = toolbar;
    
    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
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
    
    self.engineTypes = @[NSLocalizedString(@"K_ASR_cloud", nil),NSLocalizedString(@"K_ASR_local", nil)];
    self.iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"asr"];
    
    [self.iFlySpeechRecognizer setParameter:@"1" forKey:@"asr_wbest"];
    
    self.isCanceled = NO;
    
    self.curResult = [[NSMutableString alloc]init];
    
    //default cloud grammar recognition
    self.engineType = [IFlySpeechConstant TYPE_CLOUD];
    self.grammarType = GRAMMAR_TYPE_ABNF;
    
    self.localgrammerId = nil;
    self.cloudGrammerid = nil;
    
    self.uploader = [[IFlyDataUploader alloc] init];
    
    [self.startBtn setTitle:NSLocalizedString(@"K_ASR_cloud", nil) forState:UIControlStateNormal];
    
    [self.engineBtn setEnabled:YES];
    [self.uploadBtn setEnabled:YES];
    [self.startBtn setEnabled:YES];
    [self.stopBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    //stop Grammar Recognition
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer setDelegate: nil];
    [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant TYPE_CLOUD] forKey:[IFlySpeechConstant ENGINE_TYPE]];
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [super viewWillDisappear:animated];
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

-(void)onKeyBoardDown:(id) sender
{
    [_resultView resignFirstResponder];
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
/**
 start speech recognition
 **/
- (IBAction) onBtnStart:(id)sender
{
    if (![self isCommitted]) {
        [_popUpView showText: NSLocalizedString(@"M_ASR_UpGram", nil)];
        return;
    }
    
    BOOL ret = [IFlySpeechRecognizer.sharedInstance startListening];
    if (ret) {
        [_stopBtn setEnabled:YES];
        [_cancelBtn setEnabled:YES];
        [_startBtn setEnabled:NO];
        [_uploadBtn setEnabled:NO];
        [_engineBtn setEnabled:NO];
        
        self.isCanceled = NO;
        [self.curResult setString:@""];
    }
    else
    {
        [_popUpView showText: NSLocalizedString(@"M_ISR_Fail", nil)];//Last session may be not over, recognition not supports concurrent multiplexing.
    }
}

/**
 stop recording
 **/
- (IBAction) onBtnStop:(id) sender
{
    NSLog(@"%s",__func__);
    [IFlySpeechRecognizer.sharedInstance stopListening];
    [_resultView resignFirstResponder];
}

/**
 cancel speech recognition
 **/
- (IBAction) onBtnCancel:(id) sender
{
    NSLog(@"%s",__func__);
    self.isCanceled = YES;
    [IFlySpeechRecognizer.sharedInstance cancel];
    [_resultView resignFirstResponder];
}

/**
 set engine type
 **/
- (IBAction) onSetEngineBtn:(id) sender
{
    [_resultView resignFirstResponder];
    UIActionSheet * actionSheet = [[UIActionSheet alloc]  initWithTitle:NSLocalizedString(@"T_ASR_Engtype", nil)
        delegate:self cancelButtonTitle:nil
        destructiveButtonTitle:nil
        otherButtonTitles:nil];
    
    for (NSString* type in self.engineTypes) {
        [actionSheet addButtonWithTitle:type];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}
/**
 upload grammer
 **/
- (IBAction) onBtnUpload:(id)sender
{
    [_iFlySpeechRecognizer stopListening];
    
    [_uploadBtn setEnabled:NO];
    [_startBtn setEnabled:NO];
    [_engineBtn setEnabled:NO];
    [_stopBtn setEnabled:NO];
    [_cancelBtn setEnabled:NO];
    
    [self showPopup];

    //build grammer
    [self buildGrammer];
}

-(void) buildGrammer
{
        NSString *grammarContent = nil;
        NSString *documentsPath = nil;
        NSArray *appArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([appArray count] > 0) {
            documentsPath = [appArray objectAtIndex:0];
        }
        NSString *appPath = [[NSBundle mainBundle] resourcePath];
        [self createDirec:@"grm"];
    
        if([self.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]])
        {
            //grammar build path
            NSString *grammBuildPath = [documentsPath stringByAppendingString:@"/grm"];
    
            //aitalk resource path
            NSString *aitalkResourcePath = [[NSString alloc] initWithFormat:@"fo|%@/aitalk/common.jet",appPath];
    
            //bnf resource
            NSString *bnfFilePath = [[NSString alloc] initWithFormat:@"%@/bnf/call.bnf",appPath];
            grammarContent = [self readFile:bnfFilePath];
    
            [[IFlySpeechUtility getUtility] setParameter:@"asr" forKey:[IFlyResourceUtil ENGINE_START]];
    
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
            [_iFlySpeechRecognizer setParameter:self.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    
            [_iFlySpeechRecognizer setParameter:grammBuildPath forKey:[IFlyResourceUtil GRM_BUILD_PATH]];
    
            [_iFlySpeechRecognizer setParameter:aitalkResourcePath forKey:[IFlyResourceUtil ASR_RES_PATH]];
            [self.iFlySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:@"result_encoding"];
             [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        }
        else
        {
            [_iFlySpeechRecognizer setParameter:self.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
            [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
            [self.iFlySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            //bnf resource
            NSString *bnfFilePath = [[NSString alloc] initWithFormat:@"%@/bnf/grammar_sample.abnf",appPath];
            grammarContent = [self readFile:bnfFilePath];
        }
    
        //start build grammar
        [_iFlySpeechRecognizer buildGrammarCompletionHandler:^(NSString * grammerID, IFlySpeechError *error){
    
            dispatch_async(dispatch_get_main_queue(), ^{
    
                if (![error errorCode]) {
                    NSLog(@"errorCode=%d",[error errorCode]);
                    [_popUpView showText: NSLocalizedString(@"T_ISR_UpSucc", nil)];
                    _resultView.text = grammarContent;
                }
                else {
                    [_popUpView showText: [NSString stringWithFormat:@"%@:%d", NSLocalizedString(@"T_ISR_UpFail", nil), error.errorCode]];
                }
                if(error.errorCode==10102){
                    
                    [_popUpView showText: NSLocalizedString(@"M_ILO_File", nil)];
                    [self.view addSubview:_popUpView];
                    
                    NSLog(@"%s,errorCode:%d",__func__,error.errorCode);
                    
                }
                
                //set grammer id
                if ([self.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]]) {
                    _localgrammerId = grammerID;
                    [_iFlySpeechRecognizer setParameter:_localgrammerId  forKey:[IFlySpeechConstant LOCAL_GRAMMAR]];
                }
                else{
                    _cloudGrammerid = grammerID;
                    [_iFlySpeechRecognizer setParameter:_cloudGrammerid forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
                
                }
                
                _uploadBtn.enabled = YES;
                _startBtn.enabled = YES;
                [_engineBtn setEnabled:YES];
                [_stopBtn setEnabled:NO];
                [_cancelBtn setEnabled:NO];
                
            });
            
        }grammarType:self.grammarType grammarContent:grammarContent];
    
}

/**
 read file
 **/
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


#pragma mark - IFlySpeechRecognizerDelegate

/**
 volume callback,range from 0 to 30.
 **/
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"%@：%d", NSLocalizedString(@"T_RecVol", nil),volume];
    
    [_popUpView showText: vol];
}

/**
 Beginning Of Speech
 **/
- (void) onBeginOfSpeech
{
    [_popUpView showText: NSLocalizedString(@"T_RecNow", nil)];
}

/**
 End Of Speech
 */
- (void) onEndOfSpeech
{
    [_popUpView showText: NSLocalizedString(@"T_RecStop", nil)];
}

/**
 recognition session completion, which will be invoked no matter whether it exits error.
 error.errorCode =
 0     success
 other fail
 **/
- (void) onCompleted:(IFlySpeechError *) error
{
    
    NSLog(@"error=%d",[error errorCode]);
    
    NSString *text ;
    if (self.isCanceled) {
        text = NSLocalizedString(@"T_ISR_Cancel", nil);
    }
    else if (error.errorCode ==0 ) {
        if (self.curResult.length==0 || [self.curResult hasPrefix:@"nomatch"]) {
            text = NSLocalizedString(@"T_ASR_NoMat", nil);
        }else
        {
            text = NSLocalizedString(@"T_ISR_Succ", nil);
            _resultView.text = _curResult;
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"Error：%d %@", error.errorCode,error.errorDesc];
        NSLog(@"%@",text);
    }
//    if(error.errorCode==10102){
//
//        [_popUpView showText: NSLocalizedString(@"M_ILO_File", nil)];
//        [self.view addSubview:_popUpView];
//
//        NSLog(@"%s,errorCode:%d",__func__,error.errorCode);
//
//    }
    
    [_popUpView showText: text];
    
    [_stopBtn setEnabled:NO];
    [_cancelBtn setEnabled:NO];
    [_uploadBtn setEnabled:YES];
    [_startBtn setEnabled:YES];
    [_engineBtn setEnabled:YES];
}

/**
 result callback of recognition without view
 results：recognition results
 isLast：whether or not this is the last result
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
        if([self.engineType isEqualToString:[IFlySpeechConstant TYPE_LOCAL]])
        {
            NSString * resultFromJson =  [ISRDataHelper stringFromJson:result];
            [resultString appendString:resultFromJson];
        }
        else
        {
            NSString * resultFromJson =  [ISRDataHelper stringFromABNFJson:result];
            [resultString appendString:resultFromJson];
        }
        
    }
    
    if (isLast) {
        
        NSLog(@"result is:%@",self.curResult);
    }
    
    [self.curResult appendString:resultString];

}

/**
 callback of canceling recognition
 */

- (void) onCancel
{
    NSLog(@"Recognition is cancelled");
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

#pragma mark Set Engine UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            self.engineType  = [IFlySpeechConstant TYPE_CLOUD];
            self.grammarType = GRAMMAR_TYPE_ABNF;
            self.localgrammerId = nil;
            [self.startBtn setTitle:NSLocalizedString(@"K_ASR_cloud", nil) forState:UIControlStateNormal];
            break;
        case 1:
            self.engineType  = [IFlySpeechConstant TYPE_LOCAL];
            self.cloudGrammerid = nil;
            [self.startBtn setTitle:NSLocalizedString(@"K_ASR_local", nil) forState:UIControlStateNormal];
            self.grammarType = GRAMMAR_TYPE_BNF;
            break;
        default:
            break;
    }
}

@end
