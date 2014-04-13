//
//  _OfferType.h
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

@interface _OfferType : NSObject

@property (nonatomic, strong) NSNumber *offerTypeId;
@property (nonatomic, strong) NSString *readable;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign) BOOL selected;

- (instancetype)initWithTypeId:(NSNumber *)typeId readable:(NSString *)readable description:(NSString *)description selected:(BOOL)selected;

@end
