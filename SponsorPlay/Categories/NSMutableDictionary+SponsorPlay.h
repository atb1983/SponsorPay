//
//  NSMutableDictionary+SponsorPlay.h
//  SponsorPlay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SponsorPlay)

/**
 *  Method for hashing a dicionary for the Sponsor Play
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
