//
//  SPConstants.h
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)

extern NSString* const kAPIKey;
extern NSInteger const kAPIKeyLength;
extern NSString* const kAPIBaseURL;
extern NSString* const kAPIResponseSignature;

// Offers
extern NSString* const kAPIOffersEndPoint;
extern NSString* const kAPIOffersAppId;
extern NSString* const kAPIOffersUid;
extern NSString* const kAPIOffersIp;
extern NSString* const kAPIOffersLocale;
extern NSString* const kAPIOffersDevice;
extern NSString* const kAPIOffersDeviceId;
extern NSString* const kAPIOffersPsTime;
extern NSString* const kAPIOffersPub0;
extern NSString* const kAPIOffersTimeStamp;
extern NSString* const kAPIOffersHashKey;
extern NSString* const kAPIOffersOsVersion;
extern NSString* const kAPIOffersPage;
extern NSString* const kAPIOffersTypes;

// User Defautls
extern NSString *const kUserDefaultsFilters;

// Cell Identifiers
extern NSString *const kFilterOffersCellIdentifier;
extern NSString *const kOffersCellIdentifier;

// Segues
extern NSString *const kSegueGoToOffersViewController;
extern NSString *const kSegueGoToFilterOffersViewController;
extern NSString *const kSegueGoToConfigurationViewController;

// Filter Offers VC
extern NSString *const kFilterOffersCellIdentifier;
extern NSString *const kUserDefaultsFilters;

// Entities
extern NSString* const kSPEntityOffer;
extern NSString* const kSPEntityOfferType;
extern NSString* const kSPEntityThumbnail;
extern NSString* const kSPEntityTimeToPayout;

// Errors
extern NSString* const kAPIResponseSignatureFail;