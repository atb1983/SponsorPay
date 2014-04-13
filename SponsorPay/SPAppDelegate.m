//
//  SPAppDelegate.m
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPAppDelegate.h"

@implementation SPAppDelegate

#pragma mark Instance

+ (SPAppDelegate *)sharedInstance
{
	return (SPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)saveContext
{
	NSError *error;
	[[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext save:&error];
}

@end
