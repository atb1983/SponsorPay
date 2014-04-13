//
//  _OfferType.m
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "_OfferType.h"

@implementation _OfferType

- (instancetype)initWithTypeId:(NSNumber *)typeId readable:(NSString *)readable description:(NSString *)description selected:(BOOL)selected
{
	self = [super init];
	
	if (self)
	{
		self.offerTypeId = typeId;
		self.readable = readable;
		self.description = description;
		self.selected = selected;
	}
	
	return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode the properties of the object
    [encoder encodeObject:self.offerTypeId forKey:@"offerTypeId"];
    [encoder encodeObject:self.readable forKey:@"readable"];
	[encoder encodeObject:self.description forKey:@"description"];
	[encoder encodeObject:[NSNumber numberWithBool:self.selected] forKey:@"selected"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        self.offerTypeId = [decoder decodeObjectForKey:@"offerTypeId"];
        self.readable = [decoder decodeObjectForKey:@"readable"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.selected = [[decoder decodeObjectForKey:@"selected"] boolValue];
    }
    return self;
}

@end
