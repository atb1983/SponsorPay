//
//  NSMutableDictionary+SponsorPlay.m
//  SponsorPlay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "NSMutableDictionary+SponsorPlay.h"
#import "NSString+Extentions.h"

@implementation NSMutableDictionary (SponsorPlay)

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
- (void)hashDictionaryWithApiKey:(NSString *)apiKey
{
	// First we need to sort the nsdictionary
	NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	NSMutableString *preHashString = [[NSMutableString alloc] init];
	
	for (id item in sortedKeys)
	{
		if (![preHashString isEqualToString:@""])
		{
			[preHashString appendString:@"&"];
		}
		
		[preHashString appendString:[NSString stringWithFormat:@"%@=%@", item, [self objectForKey:item]]];
	}
	
	// We add the APIKey
	[preHashString appendFormat:@"&%@", apiKey];
	
	// We get the hashString using Sha1
	NSString *hashString = [[preHashString sha1] lowercaseString];
	
	// When we finish we add another entry to our dictionary with the hash key and value
	[self setObject:hashString forKey:kAPIOffersHashKey];
}

@end
