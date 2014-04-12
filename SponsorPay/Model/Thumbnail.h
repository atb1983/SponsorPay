//
//  Thumbnail.h
//  SponsorPay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Offer;

@interface Thumbnail : NSManagedObject

@property (nonatomic, retain) NSString * lowres;
@property (nonatomic, retain) NSString * hires;
@property (nonatomic, retain) Offer *thumbnailToOffer;

@end
