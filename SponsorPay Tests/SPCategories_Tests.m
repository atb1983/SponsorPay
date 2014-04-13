//
//  SPCategories_Tests.m
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UIView+Border.h"
#import "UIImage+Extentions.h"
#import "NSString+Extentions.h"

@interface SPCategories_Tests : XCTestCase

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIImage *image;

@end

@implementation SPCategories_Tests

- (void)setUp
{
	[super setUp];
	
	self.view = [[UIView alloc] init];
	self.image = [UIImage imageNamed:@"Placeholder"];
}

#pragma mark - UIView+Border

- (void)testUIViewBorderWithColor
{
	XCTAssertNoThrow([self.view applyBorderWithColor:[UIColor whiteColor]]);
}

- (void)testUIViewBorderNil
{
	XCTAssertNoThrow([self.view applyBorderWithColor:nil]);
}

#pragma mark - UIImage+Extentions

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

#pragma mark - NSString+Extentions

- (void)testNSStringEmpty
{
	NSString *stringToTest = @"";
	XCTAssertNotNil([stringToTest sha1]);
}

- (void)testNSStringNil
{
	NSString *stringToTest = nil;
	XCTAssertNil([stringToTest sha1]);
}

- (void)testNSStringOneCharacter
{
	NSString *stringToTest = @"a";
	XCTAssertNotNil([stringToTest sha1]);
}

- (void)testNSStringOneNumber
{
	NSString *stringToTest = @"1";
	XCTAssertNoThrow([stringToTest sha1]);
}

- (void)testNSStringLongText
{
	NSString *stringToTest = @"adhasgdasjgdhajsgdashgdhjasdgasdgyugdeygyag273y2783627362763232322#@#@#@#2382893728777{}{[]3434343r3ahder3yi3y4iu3y4u3iy4u3yy3uy4";
	XCTAssertNoThrow([stringToTest sha1]);
	XCTAssertNotNil([stringToTest sha1]);
}

@end
