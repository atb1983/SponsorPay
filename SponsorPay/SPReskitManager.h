//
//  SPReskitManager.h
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPError.h"
#include <RestKit/RestKit.h>

typedef void(^RequestOperationHandler)(RKMappingResult *returnObject, BOOL success, SPError *error);

@interface SPReskitManager : NSObject

// Singleton
+ (instancetype)sharedInstance;

// Properties
@property (nonatomic, strong) RKObjectManager *manager;
@property (nonatomic, strong) RKManagedObjectStore *managedObjectStore;

/**
 *  Delete/Reset all entries in CoreData
 *
 *  @param completion return YES when the coredata is cleaned
 */
- (void)cleanupCoreData:(void (^)(BOOL finished))completion;

/**
 *  Return offers from SponsorPay
 *
 *  @param page = pagination
 */
- (void)loadOffersWithPage:(NSNumber *)page complationBlock:(RequestOperationHandler)completionBlock;

@end
