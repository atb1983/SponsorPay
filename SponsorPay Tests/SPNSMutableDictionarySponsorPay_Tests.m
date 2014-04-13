//
//  SPNSMutableDictionarySponsorPay_Tests.m
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSMutableDictionary+SponsorPay.h"
#import "SPConstants.h"

@interface SPNSMutableDictionarySponsorPay_Tests : XCTestCase

@property (nonatomic, strong) NSMutableDictionary *baseDictionary;

@end

@implementation SPNSMutableDictionarySponsorPay_Tests

- (void)setUp
{
    [super setUp];
	
	// Create a base dictionary
	self.baseDictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
																			kAPIOffersAppId:		@"2070",
																			kAPIOffersUid:			@"uid",
																			kAPIOffersLocale:		@"EN",
																			kAPIOffersDeviceId:		@"111111",
																			kAPIOffersDevice:		@"phone",
																			}];
}

- (void)testNSMutableDictionaryApiKeyNil
{
	NSMutableDictionary *dictToTest = [[NSMutableDictionary alloc] init];
	XCTAssertNoThrow([dictToTest hashDictionaryWithApiKey:nil]);
}

- (void)testNSMutableDictionaryApiKeyEmpty
{
	NSMutableDictionary *dictToTest = [[NSMutableDictionary alloc] init];
	XCTAssertNoThrow([dictToTest hashDictionaryWithApiKey:@""]);
}

- (void)testNSMutableDictionaryApiKey
{
	XCTAssertNoThrow([self.baseDictionary hashDictionaryWithApiKey:@"APIKEYTEST"]);
	XCTAssertNotNil([self.baseDictionary objectForKey:kAPIOffersHashKey], @"hash should not be empty");
}

@end
