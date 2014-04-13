//
//  SPUIImageCategory_Tests.m
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIImage+Extentions.h"

@interface SPUIImageCategory_Tests : XCTestCase

@property (nonatomic, strong) UIImage *image;

@end

@implementation SPUIImageCategory_Tests

- (void)setUp
{
    [super setUp];
	
	self.image = [UIImage imageNamed:@"Placeholder"];
}

- (void)testUIImageExtentions
{
	XCTAssertNotNil([self.image imageWithRoundedCornersRadius:3.0f]);
}

- (void)testUIImageExtentionsBigNumber
{
	XCTAssertNotNil([self.image imageWithRoundedCornersRadius:9999999999.0f]);
}

- (void)testUIImageExtentionsNil
{
	XCTAssertNoThrow([self.image imageWithRoundedCornersRadius:0.0]);
}

- (void)testUIImageExtentionsNegativeValue
{
	XCTAssertNoThrow([self.image imageWithRoundedCornersRadius:-1.0]);
}

@end
