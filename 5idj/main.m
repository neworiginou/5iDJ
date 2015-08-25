//
//  main.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-26.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GP_AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        
        @try {
           return UIApplicationMain(argc, argv, nil, NSStringFromClass([GP_AppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"exception = %@",exception);
        }
        @finally {
            
        }
    }
}
