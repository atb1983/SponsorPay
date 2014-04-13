//
//  SPReskitManager.h
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <RestKit/RestKit.h>

typedef void(^RequestOperationHandler)(RKMappingResult *returnObject, BOOL success, NSError *error);

@interface SPReskitManager : NSObject

// Singleton
+ (instancetype)sharedInstance;

// Properties
@property (nonatomic, strong) RKObjectManager *manager;
@property (nonatomic, strong) RKManagedObjectStore *managedObjectStore;

- (void)loadOffersByAppId:(NSString *)appId uid:(NSString *)uid apiKey:(NSString *)apiKey pub0:(NSString *)pub0 completionBlock:(RequestOperationHandler)completionBlock;

@end
