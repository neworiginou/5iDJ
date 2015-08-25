//
//  MyAuthCodeView.m
//  5idj
//
//  Created by Xuzhanya on 14-10-12.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "MyAuthCodeView.h"
#import "help.h"
#import "MacroDef.h"

@interface MyAuthCodeView()

@property(nonatomic,strong,readonly) UIImage * authCodeImage;

@end

@implementation MyAuthCodeView

@synthesize authCodeImage = _authCodeImage;
@synthesize authCode      = _authCode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        [self _setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _setup];
}

- (void)_setup
{
    _authCodeLength = 4.f;
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapToChangeAuthCode)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)_tapToChangeAuthCode
{
    BOOL bRet = YES;
    
    id<MyAuthCodeViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(authCodeViewWillChangeAuthCode:)){
        bRet = [delegate authCodeViewWillChangeAuthCode:self];
    }
    
    if(bRet){
        
        [self changeAuthCode];
        
        ifRespondsSelector(delegate, @selector(authCodeViewDidChangeAuthCode:)){
            [delegate authCodeViewDidChangeAuthCode:self];
        }
    }
}

- (void)changeAuthCode
{
    _authCodeImage = nil;
    _authCode = nil;
    
    [self setNeedsDisplay];
}


- (NSString *)authCode
{
    if (!_authCode) {
        _authCode = getRandomString(self.authCodeLength);
    }
    
    return _authCode;
}

- (UIImage *)authCodeImage
{
    if (!_authCodeImage) {
        _authCodeImage = createAuthCodeImage(self.authCode, 20.f);
    }
    
    return _authCodeImage;
}

- (void)setAuthCodeLength:(NSUInteger)authCodeLength
{
    if (_authCodeLength != authCodeLength) {
        _authCodeLength = authCodeLength;
        [self changeAuthCode];
    }
}

- (void)drawRect:(CGRect)rect {
    [self.authCodeImage drawInRect:rect];
}

@end
