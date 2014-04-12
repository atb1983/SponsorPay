//
//  Offer.h
//  SponsorPay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OfferType, Thumbnail, TimeToPayout;

@interface Offer : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * offerId;
@property (nonatomic, retain) NSString * teaser;
@property (nonatomic, retain) NSString * requiredActions;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * payout;
@property (nonatomic, retain) NSSet *offerToOfferType;
@property (nonatomic, retain) Thumbnail *offerToThumbnail;
@property (nonatomic, retain) TimeToPayout *timeToPayout;
@end

@interface Offer (CoreDataGeneratedAccessors)

- (void)addOfferToOfferTypeObject:(OfferType *)value;
- (void)removeOfferToOfferTypeObject:(OfferType *)value;
- (void)addOfferToOfferType:(NSSet *)values;
- (void)removeOfferToOfferType:(NSSet *)values;

@end
