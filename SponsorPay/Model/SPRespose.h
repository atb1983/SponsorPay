//
//  SPRespose.h
//  SponsorPay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPRespose : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *pages;

@end
