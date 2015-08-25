//
//  GP_SuggestViewController.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-30.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SuggestViewController.h"
#import "UMFeedback.h"

//----------------------------------------------------------

@interface GP_SuggestViewController ()<
                                        UITextViewDelegate,
                                        UITextFieldDelegate,
                                        UMFeedbackDataDelegate
                                      >

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextView *contentTextView;

@property (strong, nonatomic) IBOutlet UITextField *contactTextField;

@property (strong, nonatomic) IBOutlet MyButton *sendButton;

- (IBAction)sendButtonHandle:(id)sender;

- (IBAction)tapGestureHandle:(id)sender;

- (void)_keyboardWillChangeFrame:(NSNotification *)notification;

@end

//----------------------------------------------------------


@implementation GP_SuggestViewController
{
    NSString * _contentString;
    
    CGRect     _keyboardFrame;
}

- (void)dealloc
{
    [UMFeedback sharedInstance].delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"意见反馈";
    
    
    CGFloat onePiexlLength = PiexlToPoint(1);
    
    self.contentTextView.layer.cornerRadius = 5.f;
    self.contentTextView.layer.borderColor  = defaultLineColor.CGColor;
    self.contentTextView.layer.borderWidth  = onePiexlLength;
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(8.f, 3.f, 8.f, 3.f);
    self.contentTextView.textColor          = [UIColor lightGrayColor];
    self.contentTextView.text               = @"写下您想对我们说的话...";
    
    CALayer * bgLayer = self.contactTextField.superview.layer;
    bgLayer.borderColor  = defaultLineColor.CGColor;
    bgLayer.borderWidth  = onePiexlLength;
    bgLayer.cornerRadius = 5.f;
    
    [self.sendButton setBackgroundColor:[[self currentThemeColor] colorWithAlphaComponent:0.7f]];
    [self.sendButton setBackgroundColor:BlackColorWithAlpha(0.7f) forState:UIControlStateHighlighted];
    self.sendButton.layer.cornerRadius = 5.f;
    
    //友盟
    UMFeedback * feedback = [UMFeedback sharedInstance];
    [feedback setAppkey:[[GP_AppDelegate appDelegate] appUMKey] delegate:self];
    
#if DEBUG
    [UMFeedback setLogEnabled:YES];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (void)didChangeThemeColor
{
    [self.sendButton setBackgroundColor:[[self currentThemeColor] colorWithAlphaComponent:0.7f]];
}

- (IBAction)sendButtonHandle:(id)sender
{
    if (_contentString.length == 0) {
        
        showErrorMessage(nil, nil, @"请输入您的意见");
//        [self showErrorMessageWithTitle:@"请输入您的意见。" subTitle:nil];
        [self.contentTextView becomeFirstResponder];
        
        return;
    }
    
    [self tapGestureHandle:nil];
    
    if ([self currentNetworkStatus:YES] != kNotReachable) {
        
        [self showProgressIndicatorView:@"正在提交您的意见..."];
        
        //反馈信息
        NSMutableDictionary * infoDic = [NSMutableDictionary dictionaryWithCapacity:2];
        [infoDic setObject:_contentString forKey:@"content"];
        
        //联系方式
        NSMutableDictionary * contactDic = [NSMutableDictionary dictionaryWithCapacity:2];
        
        if ([GP_UserManager currentUser]) {
            [contactDic setObject:[GP_UserManager currentUser].userName forKey:@"userName"];
        }
        
        if (self.contactTextField.text.length) {
            [contactDic setObject:self.contactTextField.text forKey:@"others"];
        }
        
        if (contactDic.count) {
            [infoDic setObject:contactDic forKey:@"contact"];
        }
        
        //发送消息
        [[UMFeedback sharedInstance] post:infoDic];
        
    }
}

- (IBAction)tapGestureHandle:(id)sender
{
    [self.contentTextView resignFirstResponder];
    [self.contactTextField resignFirstResponder];
 }


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = _contentString;
    textView.textColor = [UIColor blackColor];
    
    [self _checkOffsetWithKeyboardFrame:_keyboardFrame
                         animationCurve:UIViewAnimationCurveEaseInOut
                      animationDuration:0.3f];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        textView.text = @"写下您想对我们说的话...";
        textView.textColor = [UIColor lightGrayColor];
    }
}


- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 255.f) {
        
        showErrorMessage(nil, nil, @"超过255个字符限制");
        
//        [self showErrorMessageWithTitle:@"超过255个字符限制。" subTitle:nil];
        
        textView.text = _contentString;
        
    }else{
         _contentString = textView.text;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self _checkOffsetWithKeyboardFrame:_keyboardFrame
                         animationCurve:UIViewAnimationCurveEaseInOut
                      animationDuration:0.3f];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButtonHandle:nil];
    
    return YES;
}

- (void)_keyboardWillChangeFrame:(NSNotification *)notification
{
    _keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self _checkOffsetWithKeyboardFrame:_keyboardFrame
                         animationCurve:[[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]
                      animationDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
}

- (void)_checkOffsetWithKeyboardFrame:(CGRect)keyboardFrame
                       animationCurve:(UIViewAnimationCurve)animationCurve
                    animationDuration:(NSTimeInterval)animationDuration
{
    CGFloat contentOffsetY = 0.f;
    
    if (self.contactTextField.isFirstResponder && !CGRectEqualToRect(keyboardFrame, CGRectZero)) {
        
        CGFloat keyboardMinY = [self.view convertPoint:keyboardFrame.origin fromView:self.view.window].y;
        CGFloat buttonMaxY   = CGRectGetMaxY(self.sendButton.frame) + CGRectGetMinY(self.scrollView.frame);
        
        contentOffsetY = (buttonMaxY + 5.f > keyboardMinY) ? buttonMaxY + 5.f - keyboardMinY : 0.f;
    }
    
    if (contentOffsetY != self.scrollView.contentOffset.y) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:animationCurve];
        [UIView setAnimationDuration:animationDuration];
        
        self.scrollView.contentOffset = CGPointMake(0.f, contentOffsetY);
        
        [UIView commitAnimations];
        
    }
}

- (void)postFinishedWithError:(NSError *)error
{
    [self hideProgressIndicatorView];
    
    if (error) {
        showErrorMessage(self.view, error, @"提交失败");
    }else{
        
//        [self showSucceedMessageWithTitle:@"感谢，您宝贵的意见我们已收到！" subTitle:nil];
        
        showSuccessMessage(self.view, @"提交成功", @"感谢您的宝贵意见");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self popSubViewControllerAnimated:YES];
        });
    }
}




@end
