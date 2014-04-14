//
//  SPReskitManager.m
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPReskitManager.h"
#import "KeychainUserPass.h"

#import "SPRespose.h"
#import "SPInformation.h"
#import "_OfferType.h"
#import "SPError.h"

#import "NSString+Extentions.h"
#import "NSMutableDictionary+SponsorPay.h"

@import AdSupport;

@implementation SPReskitManager

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
	static SPReskitManager *_sharedClient = nil;
	static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
		[_sharedClient configurateRestKit];
    });
	
	return _sharedClient;
}

#pragma mark - Helpers

- (void)cleanupCoreData:(void (^)(BOOL finished))completion
{
	NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
		[[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext performBlockAndWait:^{
			for (NSEntityDescription *entity in [RKManagedObjectStore defaultStore].managedObjectModel)
			{
				NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
				[fetchRequest setEntity:entity];
				[fetchRequest setIncludesSubentities:NO];
				NSArray *objects = [[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext executeFetchRequest:fetchRequest error:nil];
				for (NSManagedObject *managedObject in objects)
				{
					[[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext deleteObject:managedObject];
				}
			}
			
			[[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext save:nil];
		}];
	}];
	[operation setCompletionBlock:^{
		completion(YES);
	}];
	[operation start];
	
}

#pragma mark - Configuration

- (void)configurateRestKit
{
    NSError *error;
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	
    self.managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
	
	BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
	
    if (!success)
	{
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
	
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"SponsorPay.sqlite"];
    NSPersistentStore *persistentStore = [self.managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    
	if (!persistentStore)
	{
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
	
    [self.managedObjectStore createManagedObjectContexts];
    
    self.manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kAPIBaseURL]];
	[self.manager setValue:self.managedObjectStore forKeyPath:@"managedObjectStore"];
	
	
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
	[[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"gzip" value:@"Accept-Encoding"];
	[[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"Connection" value:@"Keep-Alive"];
	
	// ------------------
    // Class Descriptions
    // ------------------
	[self addErrorDescriptor];
	[self addResponseDescription];
	[self addInformationDescription];
	[self addOffersDescription];
}

#pragma mark -
#pragma mark - Descriptions

- (void)addErrorDescriptor
{
	RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[SPError class]];
	// The entire value at the source key path containing the errors maps to the message
	[errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"message" toKeyPath:@"message"]];
	[errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"code" toKeyPath:@"code"]];
	NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);
	// Any response in the 4xx status code range with an "errors" key path uses this mapping
	RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"" statusCodes:statusCodes];
	
    [[RKObjectManager sharedManager] addResponseDescriptor:errorDescriptor];
}

- (void)addResponseDescription
{
	RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[SPRespose class]];
	
	[responseMapping addAttributeMappingsFromDictionary:@{
														  @"code":		@"code",
														  @"message":	@"message",
														  @"count":		@"count",
														  @"pages":		@"pages"
														  }];
	
	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	
	[[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)addInformationDescription
{
	RKObjectMapping *informationMapping = [RKObjectMapping mappingForClass:[SPInformation class]];
	
	[informationMapping addAttributeMappingsFromDictionary:@{
															 @"app_name":			@"appName",
															 @"appid":				@"appid",
															 @"virtual_currency":	@"virtualCurrency",
															 @"country":			@"country",
															 @"support_url":		@"supportUrl"
															 }];
	
	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:informationMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"information" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	
	[[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)addOffersDescription
{
	// Offers
    RKEntityMapping *offersMapping = [RKEntityMapping mappingForEntityForName:kSPEntityOffer inManagedObjectStore:self.managedObjectStore];
	
    [offersMapping addAttributeMappingsFromDictionary:@{
														@"title":			@"title",
														@"offer_id":			@"offerId",
														@"teaser":			@"teaser",
														@"required_actions":	@"requiredActions",
														@"link":				@"link",
														@"payout":			@"payout",
														@"store_id":			@"storeId",
														}];
	
	offersMapping.identificationAttributes = @[@"offerId"];
	
	[self addOfferTypeDescriptionWithOffersMapping:offersMapping];
	[self addThumbnailDescriptionWithOffersMapping:offersMapping];
	[self addTimeToPayoutDescriptionWithOffersMapping:offersMapping];
	
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:offersMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"offers" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (void)addOfferTypeDescriptionWithOffersMapping:(RKEntityMapping *)offersMapping
{
	// Offer Type
    RKEntityMapping *offerTypeMapping = [RKEntityMapping mappingForEntityForName:kSPEntityOfferType inManagedObjectStore:self.managedObjectStore];
	
    [offerTypeMapping addAttributeMappingsFromDictionary:@{
														   @"offer_type_id":	@"offerTypeId",
														   @"readable":			@"readable",
														   }];
	
	offerTypeMapping.identificationAttributes = @[@"offerTypeId"];
	
	[offersMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"offer_types" toKeyPath:@"offerToOfferType" withMapping:offerTypeMapping]];
}

- (void)addThumbnailDescriptionWithOffersMapping:(RKEntityMapping *)offersMapping
{
	// Thumbnail
    RKEntityMapping *thumbnailMapping = [RKEntityMapping mappingForEntityForName:kSPEntityThumbnail inManagedObjectStore:self.managedObjectStore];
	
    [thumbnailMapping addAttributeMappingsFromDictionary:@{
														   @"lowres":	@"lowres",
														   @"hires":	@"hires"
														   }];
	
	[offersMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"thumbnail" toKeyPath:@"offerToThumbnail" withMapping:thumbnailMapping]];
}

- (void)addTimeToPayoutDescriptionWithOffersMapping:(RKEntityMapping *)offersMapping
{
	// Time To Payout
    RKEntityMapping *timeToPayoutMapping = [RKEntityMapping mappingForEntityForName:kSPEntityTimeToPayout inManagedObjectStore:self.managedObjectStore];
	
    [timeToPayoutMapping addAttributeMappingsFromDictionary:@{
															  @"amount":	@"amount",
															  @"readable":	@"readable"
															  }];
	
	[offersMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"time_to_payout" toKeyPath:@"timeToPayout" withMapping:timeToPayoutMapping]];
}
#pragma mark - WebServices

- (void)loadOffersWithPage:(NSNumber *)page complationBlock:(RequestOperationHandler)completionBlock
{
	NSMutableDictionary *offersDictionary = [[NSMutableDictionary alloc] initWithDictionary:[self baseDict]];
	
	// Pages
	if ([page isEqualToNumber:@1])
	{
		[offersDictionary setObject:page forKey:kAPIOffersPage];
	}
	
	// Offer Types
	NSData *filtersEncoded = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFilters];
	NSArray *filters = [NSKeyedUnarchiver unarchiveObjectWithData: filtersEncoded];
	NSArray *filtersSelected = [filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected = YES"]];
	
	NSMutableString *offerTypes = [[NSMutableString alloc] init];
	
	for (_OfferType *object in filtersSelected)
	{
		[offerTypes appendFormat:[offerTypes isEqualToString:@""] ? @"%@" : @",%@", object.offerTypeId];
	}
	
	// if the string offerType is not empty we add the parameter to our dictionary
	if ([offerTypes length] > 0)
	{
		[offersDictionary setObject:offerTypes forKey:kAPIOffersTypes];
	}
	
	// We must hash the dictionary
	[offersDictionary hashDictionaryWithApiKey:[KeychainUserPass load:kAPIKey]];
	
	[self.manager getObject:nil path:kAPIOffersEndPoint parameters:offersDictionary success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
				
		if ([self checkSignature:operation])
		{
			completionBlock(mappingResult, YES, nil);
		}
		else
		{
			SPError *error = [[SPError alloc] init];
			error.message = @"The Response Signature not valid. please check your internet connection.";
			error.code = kAPIResponseSignatureFail;
			
			completionBlock(mappingResult, NO, error);
		}
	} failure:^(RKObjectRequestOperation *operation, NSError *error) {
		id errorMessage = [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
		completionBlock(nil, NO, errorMessage);
	}];
}

/**
 *  Creates a base dictinary for the comunication with SponsorPay
 *
 *  @return the base dict filled
 */
- (NSMutableDictionary *)baseDict
{
	NSString *advertisingIdentifier = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
	NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
	NSString *timeStamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
	NSString *languageCode = [[[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode] uppercaseString];
	
	// Get dictionary
	NSMutableDictionary *baseDictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
																							kAPIOffersAppId:		[KeychainUserPass load:kAPIOffersAppId],
																							kAPIOffersUid:			[KeychainUserPass load:kAPIOffersUid],
																							kAPIOffersLocale:		languageCode,
																							kAPIOffersDeviceId:		advertisingIdentifier,
																							kAPIOffersTimeStamp:	timeStamp,
																							kAPIOffersDevice:		@"phone",
																							kAPIOffersOsVersion:	deviceVersion
																							}];
	
	// Optional parametre
	NSString *pub0 = [KeychainUserPass load:kAPIOffersPub0];
	
	if ([pub0 length] > 0)
	{
		[baseDictionary setObject:pub0 forKey:kAPIOffersPub0];
	}
	
	return baseDictionary;
}

/**
 *  Method for verify the response signature
 *
 *  @param operation
 *
 *  @return YES or NO
 */
- (BOOL)checkSignature:(RKObjectRequestOperation *)operation
{
	BOOL result = NO;
	
	// First we need to check the response sginature
	NSHTTPURLResponse *response = [[operation HTTPRequestOperation] response];
	NSDictionary *headerDictionary = [response allHeaderFields];
	NSString *signatureResponse = [headerDictionary objectForKey:kAPIResponseSignature];
	
	// Now we get the body
	NSString *responseBody = [[NSString alloc] initWithData:operation.HTTPRequestOperation.responseData encoding:NSUTF8StringEncoding];
	
	// we concact the apikey
	NSString *responseBodyAndApiKey = [responseBody stringByAppendingString:[KeychainUserPass load:kAPIKey]];
	
	// and	hash the full string
	NSString *responseBodyAndKeySha1 = [responseBodyAndApiKey sha1];
	
	// comparation
	if ([signatureResponse isEqualToString:responseBodyAndKeySha1])
	{
		NSLog(@"The signature is correct");
		
		return YES;
	}
	else
	{
		NSLog(@"We are not able to verify the signature");
	}

	return result;
}

@end
