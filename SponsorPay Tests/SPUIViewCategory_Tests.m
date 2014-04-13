//
//  SPUIViewCategory_Tests.m
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIView+Border.h"

@interface SPUIViewCategory_Tests : XCTestCase

@property (nonatomic, strong) UIView *view;

@end

@implementation SPUIViewCategory_Tests

- (void)setUp
{
    [super setUp];
	
	self.view = [[UIView alloc] init];
}

- (void)testUIViewBorderWithColor
{
	XCTAssertNoThrow([self.view applyBorderWithColor:[UIColor whiteColor]]);
}

- (void)testUIViewBorderNil
{
	XCTAssertNoThrow([self.view applyBorderWithColor:nil]);
}

@end
