//
//  GP_RegisterViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-27.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_RegisterViewController.h"

//----------------------------------------------------------

@interface GP_RegisterViewController () < UITextFieldDelegate, MyAuthCodeViewDelegate >

@property (strong, nonatomic) IBOutlet MySegmentedControl *registerWayChangeControl;

@property (strong, nonatomic) IBOutlet UIView *textFieldBGView;

@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UITextField *authCodeTextField;

@property (strong, nonatomic) IBOutlet MyAuthCodeView *authCodeView;

@property (strong, nonatomic) IBOutlet UIButton *showPasswordButton;
- (IBAction)showPasswordButtonHandle:(id)sender;

//注册按钮
@property (strong, nonatomic) IBOutlet MyButton *registerButton;

- (IBAction)registerButtonHandle:(id)sender;

- (IBAction)tapInView:(id)sender;


//核对文本框文字
- (BOOL)_checkTextFieldText;

//注册成功
- (void)_userRegisterSuccessNotification:(NSNotification *)notification;

//注册失败
- (void)_userRegisterFailNotification:(NSNotification *)notification;

@end

//----------------------------------------------------------

@implementation GP_RegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.myNavigationItem.title = @"注册";

    //按钮设置
    [_registerButton setBackgroundColor:[[self currentThemeColor] colorWithAlphaComponent:0.7f]];
    [_registerButton setBackgroundColor:BlackColorWithAlpha(0.7f) forState:UIControlStateHighlighted];
    [_registerButton setBackgroundColor:[[self currentThemeColor] colorWithAlphaComponent:0.2f] forState:UIControlStateDisabled];
    _registerButton.layer.cornerRadius = 5.f;
    
    //设置选择的图片
    [_showPasswordButton setImage:[[_showPasswordButton imageForState:UIControlStateNormal] imageWithTintColor:[self currentThemeColor]] forState:UIControlStateSelected];
    
    
    //注册方式设置
    _registerWayChangeControl.sectionTitles = @[@"手机注册",@"邮箱注册"];
    _registerWayChangeControl.backgroundColor = defaultCellBackgroundColor;
    _registerWayChangeControl.textColor = defaultTitleTextColor;
    _registerWayChangeControl.selectedTextColor = _registerWayChangeControl.textColor;
    _registerWayChangeControl.showSeparatorLine = NO;
    _registerWayChangeControl.selectedIndicatorLineInsetScale = UIEdgeInsetsMake(0.f, 0.15f, 0.f, 0.15f);
    [_registerWayChangeControl addTarget:self action:@selector(_registerWayChangeHandle) forControlEvents:UIControlEventValueChanged];
    _registerWayChangeControl.selectedSectionIndex = 0.f;
    
    //验证码
    _authCodeView.delegate = self;
    _authCodeView.layer.cornerRadius = 5.f;
    _authCodeView.clipsToBounds = YES;
    
    
    //绘制线
    CGFloat onePiexlLength = PiexlToPoint(1);
    
    _textFieldBGView.layer.cornerRadius = 5.f;
    _textFieldBGView.layer.borderWidth = onePiexlLength;
    _textFieldBGView.layer.borderColor = defaultLineColor.CGColor;
    
    CGFloat lineWidth = screenSize().width - 2 * CGRectGetMinX(_textFieldBGView.frame);
    CALayer * lineLayer = [[CALayer alloc] init];
    lineLayer.frame = CGRectMake(0.f, 40.f - onePiexlLength * 0.5f, lineWidth, onePiexlLength);
    lineLayer.backgroundColor = defaultLineColor.CGColor;
    [_textFieldBGView.layer addSublayer:lineLayer];
    
    lineLayer = [[CALayer alloc] init];
    lineLayer.frame = CGRectMake(0.f, 80.f - onePiexlLength * 0.5f, lineWidth, 0.5f);
    lineLayer.backgroundColor = defaultLineColor.CGColor;
    [_textFieldBGView.layer addSublayer:lineLayer];
    
    lineLayer = [[CALayer alloc] init];
    lineLayer.frame = CGRectMake(0, CGRectGetHeight(_registerWayChangeControl.bounds), screenSize().width, 1.f);
    lineLayer.backgroundColor = defaultLineColor.CGColor;
    [_registerWayChangeControl.layer addSublayer:lineLayer];
    
    
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userRegisterSuccessNotification:) name:UserRegisterSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userRegisterFailNotification:) name:UserRegisterFailNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_textDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_userNameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_textDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_passwordTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_textDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_authCodeTextField];
    
}

- (void)didChangeThemeColor
{
    [_registerButton setBackgroundColor:[[self currentThemeColor] colorWithAlphaComponent:0.7f]];
    [_registerButton setBackgroundColor:[[self currentThemeColor] colorWithAlphaComponent:0.3f] forState:UIControlStateDisabled];
    
    [_showPasswordButton setImage:[[_showPasswordButton imageForState:UIControlStateNormal] imageWithTintColor:[self currentThemeColor]] forState:UIControlStateSelected];
}


#pragma mark - 注册方式相关
- (void)_registerWayChangeHandle
{
    [self.view endEditing:YES];
    
    [UIView transitionWithView:self.textFieldBGView.superview
                      duration:0.6f
                       options://UIViewAnimationOptionTransitionCrossDissolve
     _registerWayChangeControl.selectedSectionIndex ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        
                        //初始化
                        _userNameTextField.text = nil;
                        _passwordTextField.text = nil;
                        _showPasswordButton.selected = NO;
                        _passwordTextField.secureTextEntry = YES;
                        
                        //更改验证码
                        [self _changeAuthCode];
                        
                        //设置其它改变
                        if (_registerWayChangeControl.selectedSectionIndex) {
                            _userNameTextField.placeholder = @"请输入邮箱";
                            _userNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
                        }else{
                            _userNameTextField.placeholder = @"请输入11位手机号";
                            _userNameTextField.keyboardType = UIKeyboardTypeNumberPad;
                        }
                    
                    }
                    completion:nil];
}


#pragma mark - authCodeView delegate

- (void)_changeAuthCode
{
    [UIView transitionWithView:_authCodeView
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                        [_authCodeView changeAuthCode];
                        _authCodeTextField.text = nil;
                        _registerButton.enabled = NO;
                    } completion:nil];
}

- (BOOL)authCodeViewWillChangeAuthCode:(MyAuthCodeView *)authCodeView
{
    [self _changeAuthCode];
    
    return NO;
}

#pragma mark - textField 相关

- (IBAction)tapInView:(id)sender
{
    [self.view endEditing:YES];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _passwordTextField) {
        _registerButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userNameTextField) {
        [_passwordTextField becomeFirstResponder];
    }else if (textField == _passwordTextField){
        [_authCodeTextField becomeFirstResponder];
    }else{
        [self registerButtonHandle:self];
    }
    
    return YES;
}

- (void)_textDidChangeNotification:(NSNotificationCenter *)notification
{
    _registerButton.enabled = _userNameTextField.text.length && _passwordTextField.text.length && _authCodeTextField.text.length;
}


#pragma mark - 注册相关

- (BOOL)_checkTextFieldText
{
    NSString *msgText = nil;
    
    //验证用户名
    if (_registerWayChangeControl.selectedSectionIndex == 0) {
        if (!isPhoneNumber(_userNameTextField.text)) {
            msgText = @"输入的手机号不合法";
            [_userNameTextField becomeFirstResponder];
            goto end;
        }
    }else{
        if (!isEmailAddress(_userNameTextField.text)) {
            msgText = @"输入的邮箱不合法";
            [_userNameTextField becomeFirstResponder];
            goto end;
        }
    }
    
    //验证密码
    if (_passwordTextField.text.length) {
        if (_passwordTextField.text.length < 6) {
            msgText = @"密码太短，应大于等于6位";
            [_passwordTextField becomeFirstResponder];
            goto end;
        }else if (_passwordTextField.text.length > 32){
            msgText = @"密码太长，应小于等于32位";
            [_passwordTextField becomeFirstResponder];
            goto end;
        }
    }else{
        msgText = @"请输入密码";
        [_passwordTextField becomeFirstResponder];
        goto end;
    }
    
    
    //验证验证码
    if (_authCodeTextField.text.length){
        
        //验证码不相等
        if(![[_authCodeTextField.text uppercaseString] isEqualToString:[_authCodeView.authCode uppercaseString]]){
            msgText = @"输入的验证码错误";
            [_authCodeTextField becomeFirstResponder];
        }
    }else{
        msgText = @"请输入验证码";
        [_authCodeTextField becomeFirstResponder];
    }
    
end:
    
    if (msgText) {
        
        //验证失败消息
        showErrorMessage(nil, nil, msgText);
        
        //改变验证码
        [self _changeAuthCode];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)registerButtonHandle:(id)sender
{
    if ([self _checkTextFieldText]) {
 
        [self.view endEditing:YES];
        
        //检查网络
        if ([self currentNetworkStatus:YES] != kNotReachable) {
            
            [self showProgressIndicatorView:@"注册中..."];
            
            //开始注册
            [GP_UserManager userRegisterWithUserName:_userNameTextField.text password:_passwordTextField.text];
        }
    }
}

- (void)_userRegisterFailNotification:(NSNotification *)notification
{
    [self hideProgressIndicatorView];
    
    NSString * errorDescription = [(NSError *)notification.userInfo[UserHandleFailErrorUserInfoKey] localizedDescription];
    
    [self showAlertViewWithTitle:@"注册失败" message:errorDescription];
    
    //更改验证码
    [self _changeAuthCode];
}

- (void)_userRegisterSuccessNotification:(NSNotification *)notification
{
    [self hideProgressIndicatorView];
    
    showSuccessMessage(self.view, @"恭喜，注册成功", nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate registerViewController:self didRegisterSuccessWithUserName:_userNameTextField.text];
    });
}


- (IBAction)showPasswordButtonHandle:(id)sender
{
    _showPasswordButton.selected = !_showPasswordButton.isSelected;
    _passwordTextField.secureTextEntry = !_showPasswordButton.selected;
    
    _showPasswordButton.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    [UIView animateWithDuration:0.4f
                          delay:0.0f
         usingSpringWithDamping:0.3f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _showPasswordButton.transform = CGAffineTransformIdentity;;
                     } completion:nil];
    
}
@end
