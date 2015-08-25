//
//  GP_ChannelSearchViewController.m
//  5idj
//
//  Created by Xuzhanya on 14/12/19.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ChannelSearchViewController.h"
#import "GP_SearchResultViewController.h"
#import "GP_SearchHistoryView.h"
#import "GP_SearchHistoryManager.h"

//----------------------------------------------------------

@interface GP_ChannelSearchViewController () <
                                                UISearchBarDelegate ,
                                                GP_SearchHistoryViewDelegate
                                             >

@property(nonatomic,strong) GP_Channel * channel;

@property(nonatomic,strong) UISearchBar * searchBar;

@property(nonatomic,strong) GP_SearchHistoryView * searchHistoryView;

@end

//----------------------------------------------------------

@implementation GP_ChannelSearchViewController

+ (GP_MainNavigationController *)navigationControllerWithChannel:(GP_Channel *)channel
{
    return [[GP_MainNavigationController alloc] initWithRootViewController:[[self alloc] initWithChannel:channel]];
}

- (id)initWithChannel:(GP_Channel *)channel
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        self.channel = channel;
    }
    
    return self;
}


- (BOOL)hasNavigationBar{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.interactiveDismissEnable = YES;
    
    UIView * searchBarBGView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.bounds), 70.f)];
    searchBarBGView.backgroundColor = [UIColor whiteColor];
    searchBarBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:searchBarBGView];
    
    //添加阴影
    searchBarBGView.layer.shadowPath = [UIBezierPath bezierPathWithRect:searchBarBGView.bounds].CGPath;
    searchBarBGView.layer.shadowOffset  = CGSizeMake(0.f, 3.f);
    searchBarBGView.layer.shadowOpacity = 0.6f;
    
    //搜索控件
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 20.f, CGRectGetWidth(searchBarBGView.bounds), 50.f)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleBottomMargin;
    self.searchBar.searchBarStyle  = UISearchBarStyleMinimal;
    self.searchBar.placeholder     = @"请输入要搜索的内容";
    self.searchBar.delegate        = self;
    self.searchBar.showsCancelButton = YES;
    [searchBarBGView addSubview:self.searchBar];
    
    //搜索历史
    self.searchHistoryView = [[GP_SearchHistoryView alloc] initWithFrame:CGRectMake(0.f, 70.f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 70.f)];
    self.searchHistoryView.delegate = self;
    [self.view insertSubview:self.searchHistoryView belowSubview:searchBarBGView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardDidChangeFrameNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.searchBar resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
}

- (void)_keyboardDidChangeFrameNotification:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardMinY = [self.view convertPoint:keyboardFrame.origin fromView:self.view.window].y;
    
    self.searchHistoryView.frame = CGRectMake(0.f, 70.f, CGRectGetWidth(self.view.bounds), keyBoardMinY - 70.f);
}

#pragma mark - search history view delegate

- (void)searchHistoryView:(GP_SearchHistoryView *)searchHistoryView didSelectSearchKeyword:(NSString *)keyword
{
    [self _searchWithKeyword:keyword];
}

- (void)searchHistoryView:(GP_SearchHistoryView *)searchHistoryView didUpSearchKeyword:(NSString *)keyword
{
    self.searchBar.text = keyword;
}

#pragma mark - searchBar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self backBarButtonHandle];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self _searchWithKeyword:searchBar.text];
}


- (void)_searchWithKeyword:(NSString *)keyword
{
    //添加历史搜索记录
    [[GP_SearchHistoryManager shareManager] addSearchKeyword:keyword];
    
    [self pushSubViewController:[[GP_SearchResultViewController alloc] initWithSearchKeyword:keyword channelID:self.channel.ID] animated:YES];
}

@end
