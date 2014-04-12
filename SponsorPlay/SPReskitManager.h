//
//  SPReskitManager.h
//  SponsorPlay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <RestKit/RestKit.h>

@interface SPReskitManager : NSObject

// Sigleton
+ (instancetype)sharedInstance;

// Properties
@property (nonatomic, strong) RKObjectManager *manager;
@property (nonatomic, strong) RKManagedObjectStore *managedObjectStore;

@end
