//
//  GP_SettingTableController.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-9-4.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "GP_SettingTableController.h"

@implementation GP_SettingTableController

- (id)initWithTableView:(UITableView *)tableView
  configurationFileName:(NSString *)fileName
                 bundle:(NSBundle *)bundleOrNil
{
    self = [super initWithTableView:tableView configurationFileName:fileName bundle:bundleOrNil];
    
    if (self) {
        
        self.tableViewCellBackgroundColor = defaultCellBackgroundColor;
        self.tableViewCellTintColorAlpha  = 0.7f;
        self.tableView.separatorColor     = defaultLineColor;
        
    }
    
    return self;
}
@end
