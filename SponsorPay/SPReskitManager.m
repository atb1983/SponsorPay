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
    
	if (! persistentStore)
	{
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
	
    [self.managedObjectStore createManagedObjectContexts];
    
    self.manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kAPIBaseURL]];
	[self.manager setValue:self.managedObjectStore forKeyPath:@"managedObjectStore"];
	
	
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
	[[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"gzip" value:@"Accept-Encoding"];
	
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
	RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
	// The entire value at the source key path containing the errors maps to the message
	[errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"message" toKeyPath:@"errorMessage"]];
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

- (void)loadOffersWithCompletionBlock:(RequestOperationHandler)completionBlock
{
	[self loadOffersByAppId:[KeychainUserPass load:kAPIOffersAppId] uid:[KeychainUserPass load:kAPIOffersUid] apiKey:[KeychainUserPass load:kAPIKey] pub0:[KeychainUserPass load:kAPIOffersPub0] completionBlock:^(RKMappingResult *returnObject, BOOL success, NSError *error) {
		completionBlock(returnObject, success, error);
	}];
}

- (void)loadOffersByAppId:(NSString *)appId uid:(NSString *)uid apiKey:(NSString *)apiKey pub0:(NSString *)pub0 completionBlock:(RequestOperationHandler)completionBlock
{
	NSString *advertisingIdentifier = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
	NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
	NSString *timeStamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
	NSString *languageCode = [[[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode] uppercaseString];
	
	// Offer Types
	NSData *filtersEncoded = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFilters];
	NSArray *filters = [NSKeyedUnarchiver unarchiveObjectWithData: filtersEncoded];
	NSArray *filtersSelected = [filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected = YES"]];
	
	NSMutableString *offerTypes = [[NSMutableString alloc] init];
	
	for (_OfferType *object in filtersSelected)
	{
		[offerTypes appendFormat:[offerTypes isEqualToString:@""] ? @"%@" : @",%@", object.offerTypeId];
	}
	
	// Get dictionary
	NSMutableDictionary *offersDictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
																							  kAPIOffersAppId:		appId,
																							  kAPIOffersUid:		uid,
																							  kAPIOffersIp:			@"109.235.143.113",
																							  kAPIOffersLocale:		languageCode,
																							  kAPIOffersDeviceId:	advertisingIdentifier,
																							  kAPIOffersTimeStamp:	timeStamp,
																							  kAPIOffersDevice:		@"phone",
																							  kAPIOffersOsVersion:	deviceVersion,
																							  kAPIOffersTypes:		offerTypes,
																							  kAPIOffersPub0:		pub0
																							  }];
	
	[offersDictionary hashDictionaryWithApiKey:apiKey];
	
	[self.manager getObject:nil path:kAPIOffersEndPoint parameters:offersDictionary success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		
		NSDictionary *myDic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
		NSLog(@"=======:%@",myDic);
		
		completionBlock(mappingResult, YES, nil);
	} failure:^(RKObjectRequestOperation *operation, NSError *error) {
		NSDictionary *myDic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
		NSLog(@"=======:%@",myDic);
		
		NSError *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
		completionBlock(nil, NO, errorMessage);
	}];
}

@end
