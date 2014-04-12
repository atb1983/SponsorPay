//
//  SPInformation.h
//  SponsorPlay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPInformation : NSObject

@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *virtualCurrency;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *supportUrl;

@end
