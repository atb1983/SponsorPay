//
//  SPNSStringCategory_Tests.m
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Extentions.h"

@interface SPNSStringCategory_Tests : XCTestCase

@end

@implementation SPNSStringCategory_Tests

- (void)setUp
{
    [super setUp];
}

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
