//
//  GP_AboutViewController.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-30.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "GP_AboutViewController.h"
#import "GP_SettingTableController.h"

//----------------------------------------------------------

@interface GP_AboutViewController ()

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *buildLabel;
@property (strong, nonatomic) IBOutlet UILabel *teamLogoLabel;

@property (strong, nonatomic) IBOutlet UITableView *infoTableVeiw;
//@property (strong, nonatomic) IBOutlet UIImageView *authCodeImageView;

@end

//----------------------------------------------------------


@implementation GP_AboutViewController
{
    GP_SettingTableController * _itemsTableController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"关于我们";
    
    self.versionLabel.textColor = defaultTitleTextColor;
    self.buildLabel.textColor = defaultBodyTextColor;
    self.teamLogoLabel.textColor = [self currentThemeColor];

    self.versionLabel.text = [NSString stringWithFormat:@"iPhone V%@",[[GP_AppDelegate appDelegate] appVersion]];
    self.buildLabel.text = [NSString stringWithFormat:@"Build%@",[[GP_AppDelegate appDelegate] appBuild]];
    
    _itemsTableController = [[GP_SettingTableController alloc] initWithTableView:self.infoTableVeiw configurationFileName:@"GP_AboutViewTableItem" bundle:nil];
    _itemsTableController.delegate = self;
    
//    self.authCodeImageView.image = createAuthCodeImage(getRandomString(4), 20.f);
    
//    [self.authCodeImageView sizeToFit];
    
}

- (void)didChangeThemeColor
{
    self.teamLogoLabel.textColor = [self currentThemeColor];
}

@end
