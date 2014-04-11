//
//  SPReskitManager.m
//  SponsorPlay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPReskitManager.h"

@implementation SPReskitManager

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
	static SPReskitManager *_sharedClient = nil;
	static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
    });
	
	return _sharedClient;
}


@end
