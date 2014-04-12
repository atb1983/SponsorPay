//
//  TimeToPayout.h
//  SponsorPlay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Offer;

@interface TimeToPayout : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * readable;
@property (nonatomic, retain) Offer *timePayoutToOffer;

@end
