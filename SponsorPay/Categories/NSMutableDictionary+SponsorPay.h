//
//  NSMutableDictionary+SponsorPay.h
//  SponsorPay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SponsorPay)

/**
 *  Method for hashing a dictionary for the Sponsor Pay
 *
 *		- Order all request alphabetically
 *		- Concatenate all request parameters & and = symbols
 *		- Concatenate the resulting string with your API Key
 *		- Hash the resulting string using SHA1
 *
 *  @param apiKey apiKey
 */
- (void)hashDictionaryWithApiKey:(NSString *)apiKey;

@end
