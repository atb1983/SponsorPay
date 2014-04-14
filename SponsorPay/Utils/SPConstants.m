//
//  SPConstants.m
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPConstants.h"

NSString* const kAPIKey					=	@"apikey";
NSInteger const kAPIKeyLength			=	40;
NSString* const kAPIBaseURL				=	@"http://api.sponsorpay.com";

// Offers
NSString* const kAPIOffersEndPoint		=	@"/feed/v1/offers.json";
NSString* const kAPIOffersAppId			=	@"appid";
NSString* const kAPIOffersUid			=	@"uid";
NSString* const kAPIOffersIp			=	@"ip";
NSString* const kAPIOffersLocale		=	@"locale";
NSString* const kAPIOffersDevice		=	@"device";
NSString* const kAPIOffersDeviceId		=	@"device_id";
NSString* const kAPIOffersPsTime		=	@"ps_time";
NSString* const kAPIOffersPub0			=	@"pub0";
NSString* const kAPIOffersTimeStamp		=	@"timestamp";
NSString* const kAPIOffersHashKey		=	@"hashkey";
NSString* const kAPIOffersOsVersion		=	@"os_version";
NSString* const kAPIOffersPage			=	@"page";
NSString* const kAPIOffersTypes			=	@"offer_types";

// User Defautls
NSString *const kUserDefaultsFilters		= @"SPFilters";

// Cell Indentifiers
NSString *const kFilterOffersCellIdentifier = @"OffersCellID";
NSString *const kOffersCellIdentifier		= @"OffersCellID";

// Segues
NSString *const kSegueGoToOffersViewController				= @"GoToOffersViewControllerSegue";
NSString *const kSegueGoToFilterOffersViewController		= @"GoToFilterOffersViewControllerSegue";
NSString *const kSegueGoToConfigurationViewController		= @"GoToConfigurationSegue";


// Entities
NSString* const kSPEntityOffer			=	@"Offer";
NSString* const kSPEntityOfferType		=	@"OfferType";
NSString* const kSPEntityThumbnail		=	@"Thumbnail";
NSString* const kSPEntityTimeToPayout	=	@"TimeToPayout";