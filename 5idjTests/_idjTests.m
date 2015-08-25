//
//  _idjTests.m
//  5idjTests
//
//  Created by Xuzhanya on 14-9-25.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
//#import "MyDataStoreManager.h"

@interface _idjTests : XCTestCase//<MyDataStoreManagerDelegate>

@end

@implementation _idjTests
//{
//    MyDataStoreManager * _dataStoreManager;
//}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testDataStoreManager
//{
//    MyDataStoreManager * dataStoreManager = [[MyDataStoreManager alloc] initWithDesignSectionDatasCount:5.f sectionsCountLimit:2.f cacheName:nil];
//    dataStoreManager.delegate = self;
//    [dataStoreManager addDatas:@[@"1",@"2"]];
//    
//    XCTAssert([dataStoreManager numberOfSections] == 1 ,@"");
//    XCTAssert([dataStoreManager numberOfDatasAtSection:0] == 2 ,@"");
//    
//    [self _logdataStore:dataStoreManager];
//    
//    [dataStoreManager addDatas:@[@"1",@"2",@"3",@"4",@"",@"1",@"2",@"3",@"4",@"1",@"2",@"3",@"4"]];
//    
////    XCTAssert([dataStoreManager numberOfSections] == 3 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:0] == 5 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:1] == 1 ,@"");
////    
//    [self _logdataStore:dataStoreManager];
//    
//    [dataStoreManager addSection:@[@"1",@"2",@"3",@"4"]];
//    
////    XCTAssert([dataStoreManager numberOfSections] == 3 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:0] == 5 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:1] == 1 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:2] == 4 ,@"");
////    
//    [self _logdataStore:dataStoreManager];
//    
//    [dataStoreManager addSection:@[@"1",@"2",@"3",@"4"]];
//    
////    XCTAssert([dataStoreManager numberOfSections] == 4 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:0] == 5 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:1] == 1 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:2] == 4 ,@"");
////    XCTAssert([dataStoreManager numberOfDatasAtSection:3] == 4 ,@"");
//    
//    [self _logdataStore:dataStoreManager];
//    
//    _dataStoreManager = dataStoreManager;
//    
////    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////        sleep(5);
////    });
//}
//
//- (void)_logdataStore:(MyDataStoreManager *)dataStoreManager
//{
//    for (int i = 0 ; i < [dataStoreManager numberOfSections] ; i++) {
//        XCTAssert([dataStoreManager datasAtSection:i].count == [dataStoreManager numberOfDatasAtSection:i]);
//        NSLog(@"section%i datas = %@",i,[dataStoreManager datasAtSection:i]);
//    }
//}
//
//- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager didAddSection:(NSUInteger)section
//{
//    
//}
//
//- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager didAddDatasAtSection:(NSUInteger)section andIndexSet:(NSIndexSet *)indexSet
//{
//    
//}

////
////- (void)testExample {
////    // This is an example of a functional test case.
////    XCTAssert(YES, @"Pass");
////}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
