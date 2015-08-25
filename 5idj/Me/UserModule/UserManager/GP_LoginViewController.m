//
//  GP_LoginViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-27.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_LoginViewController.h"
#import "GP_RegisterViewController.h"

//----------------------------------------------------------

@interface GP_LoginViewController ()<UITextFieldDelegate,GP_RegisterViewControllerDelegate>

//Textfield
@property (strong, nonatomic) IBOutlet UIView *textFieldBGView;

@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)tapInView:(id)sender;

//登录按钮
@property (strong, nonatomic) IBOutlet MyButton *loginButton;

- (IBAction)loginButtonHandle:(id)sender;

//注册按钮
@property (strong, nonatomic) IBOutlet MyButton *registerButton;

- (IBAction)registerButtonHandle:(id)sender;

//登录成功通知
- (void)_userLoginSuccessNotification:(NSNotification *)notification;

//登录失败通知
- (void)_userLoginFailNotification:(NSNotification *)notification;

@end

//----------------------------------------------------------


@implementation GP_LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.myNavigationItem.title  = @"登录";
    
    //按钮设置
    UIColor * normalBGColor = [[self currentThemeColor] colorWithAlphaComponent:0.7f];
    UIColor * highlightBGColor  = BlackColorWithAlpha(0.7f);
    
    [_loginButton setBackgroundColor:normalBGColor];
    [_loginButton setBackgroundColor:highlightBGColor forState:UIControlStateHighlighted];
    [_loginButton setBackgroundColor:[[self currentThemeColor] colorWithAlphaComponent:0.2f] forState:UIControlStateDisabled];
    _loginButton.layer.cornerRadius = 5.f;
    
    [_registerButton setBackgroundColor:normalBGColor];
    [_registerButton setBackgroundColor:highlightBGColor forState:UIControlStateHighlighted];
    _registerButton.layer.cornerRadius = 5.f;
    
    
    //绘制线
    CGFloat onePiexlLength = PiexlToPoint(1);
    
    _textFieldBGView.layer.cornerRadius = 5.f;
    _textFieldBGView.layer.borderWidth = onePiexlLength;
    _textFieldBGView.layer.borderColor = defaultLineColor.CGColor;
    
    CALayer * lineLayer = [[CALayer alloc] init];
    lineLayer.frame = CGRectMake(0.f, 40.f - onePiexlLength * 0.5f, screenSize().width - 2 * CGRectGetMinX(_textFieldBGView.frame), onePiexlLength);
    lineLayer.backgroundColor = defaultLineColor.CGColor;
    [_textFieldBGView.layer addSublayer:lineLayer];
    
    
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userLoginSuccessNotification:) name:UserLoginSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userLoginFailNotification:) name:UserLoginFailNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_textDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_userNameTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_textDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_passwordTextField];
    
    //设置初始化状态
    NSDictionary * recentUserInfo = [GP_UserManager recentUserInfo];
    _userNameTextField.text = recentUserInfo[GP_SP_LOGIN_USERNAME];
    _passwordTextField.text = recentUserInfo[GP_SP_REGISTER_PASSWORD];
    
    //无内容时不可用
    _loginButton.enabled = (_userNameTextField.text.length && _passwordTextField.text.length);

    //取消自动登录
    [GP_UserManager cancleAutoLogin];
}

- (void)didChangeThemeColor
{
    UIColor * tmpThemeColor = [[self currentThemeColor] colorWithAlphaComponent:0.7f];
    
    [_loginButton setBackgroundColor:tmpThemeColor];
    [_loginButton setBackgroundColor:[[self currentThemeColor] colorWithAlphaComponent:0.3f] forState:UIControlStateDisabled];
    [_registerButton setBackgroundColor:tmpThemeColor];
}

#pragma mark - textField相关

- (IBAction)tapInView:(id)sender
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _passwordTextField) {
        _loginButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameTextField) {
        [_passwordTextField becomeFirstResponder];
    }else{
        [self loginButtonHandle:self];
    }
    
    return YES;
}


- (void)_textDidChangeNotification:(NSNotificationCenter *)notification
{
    _loginButton.enabled = _userNameTextField.text.length && _passwordTextField.text.length;
}

#pragma mark - 登录相关

- (IBAction)loginButtonHandle:(id)sender
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    //核对信息
    if (_userNameTextField.text.length == 0) {
        showErrorMessage(nil, nil, @"请输入用户名");
        [_userNameTextField becomeFirstResponder];
    }else if (_passwordTextField.text.length == 0){
        showErrorMessage(nil, nil, @"请输入密码");
        [_passwordTextField becomeFirstResponder];
    }else{
        //开始登录
        if ([self currentNetworkStatus:YES] != kNotReachable) {
            [self showProgressIndicatorView:@"登录中..."];
            [GP_UserManager userLoginWithUserName:_userNameTextField.text password:_passwordTextField.text];
        }
    }
}


- (void)_userLoginSuccessNotification:(NSNotification *)notification
{
    [self hideProgressIndicatorView];
    
    //显示登录成功消息
    showSuccessMessage(self.view, @"登陆成功", [NSString stringWithFormat:@"欢迎你，%@!",[GP_UserManager currentUser].userName]);

    
    //1秒后通知代理
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate loginViewControllerDidSucceedLoginUser:self];
    });
}

- (void)_userLoginFailNotification:(NSNotification *)notification
{
    [self hideProgressIndicatorView];
    
    NSString * errorDescription = [(NSError *)notification.userInfo[UserHandleFailErrorUserInfoKey] localizedDescription];
    
    [self showAlertViewWithTitle:@"登录失败" message:errorDescription];
}

- (void)registerViewController:(GP_RegisterViewController *)registerViewController didRegisterSuccessWithUserName:(NSString *)userName
{
    [self popSubViewControllerAnimated:YES];
    
    _userNameTextField.text = userName;
    [_passwordTextField becomeFirstResponder];
    
}


- (IBAction)registerButtonHandle:(id)sender
{
    GP_RegisterViewController * registerViewController = [GP_RegisterViewController viewController];
    registerViewController.delegate = self;
    [self pushSubViewController:registerViewController animated:YES];
}

@end
