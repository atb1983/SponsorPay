//
//  SPCoredata_Tests.m
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <CoreData/CoreData.h>
#import "Offer.h"
#import "OfferType.h"
#import "Thumbnail.h"
#import "TimeToPayout.h"

#import "SPConstants.h"

@interface SPCoredata_Tests : XCTestCase

@end

@implementation SPCoredata_Tests

- (NSManagedObjectContext *)managedObjectContextForTesting
{
    static NSManagedObjectContext *_managedObjectContext = nil;
    if (_managedObjectContext == nil) {
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
		
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SponsorPay" withExtension:@"momd"];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
		
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
		
        [psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
		
        [moc setPersistentStoreCoordinator:psc];
		
        _managedObjectContext = moc;
    }
	
    return _managedObjectContext;
}

- (void)setUp
{
    [super setUp];
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		[self managedObjectContextForTesting];
    });
}

- (void)testOfferEntityInsert
{
	Offer *offer = [NSEntityDescription insertNewObjectForEntityForName:kSPEntityOffer inManagedObjectContext:self.managedObjectContextForTesting];
	
	offer.title = @"Title Test";
	offer.offerId = @1;
	offer.teaser = @"Teaser Test";
	offer.requiredActions = @"RequiredActions";
	offer.link = @"link";
	offer.storeId = @1;
	
	XCTAssertTrue([self saveCoreData]);
}


- (void)testOfferEntityDelete
{
	Offer *offer = [NSEntityDescription insertNewObjectForEntityForName:kSPEntityOffer inManagedObjectContext:self.managedObjectContextForTesting];
	
	offer.title = @"Title Test";
	offer.offerId = @2;
	offer.teaser = @"Teaser Test";
	offer.requiredActions = @"RequiredActions";
	offer.link = @"link";
	offer.storeId = @2;
	
	BOOL result = [self saveCoreData];
	
	XCTAssertTrue(result);

	if (result)
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:kSPEntityOffer inManagedObjectContext:self.managedObjectContextForTesting]];
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"offerId == %@", @2]];
		
		NSError *error;
		NSArray *results = [self.managedObjectContextForTesting executeFetchRequest:fetchRequest error:&error];
		XCTAssertEqual(results.count, 1, @"the object should be found");
		
		[self.managedObjectContextForTesting deleteObject:[results firstObject]];

		XCTAssertTrue([self saveCoreData]);
	}
}

- (void)testOfferEntityUpdate
{
	Offer *offer = [NSEntityDescription insertNewObjectForEntityForName:kSPEntityOffer inManagedObjectContext:self.managedObjectContextForTesting];
	
	offer.title = @"Title Test";
	offer.offerId = @3;
	offer.teaser = @"Teaser Test";
	offer.requiredActions = @"RequiredActions";
	offer.link = @"link";
	offer.storeId = @3;
	
	BOOL result = [self saveCoreData];
	
	XCTAssertTrue(result);
	
	if (result)
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:kSPEntityOffer inManagedObjectContext:self.managedObjectContextForTesting]];
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"offerId == %@", @3]];
		
		NSError *error;
		NSArray *results = [self.managedObjectContextForTesting executeFetchRequest:fetchRequest error:&error];
		XCTAssertEqual(results.count, 1, @"the object should be found");
		
		Offer *offerToUpdate = [results firstObject];
		offerToUpdate.title = @"Title Test Updated";
		
		XCTAssertTrue([self saveCoreData]);
	}
}
- (void)testOfferTypeInsert
{
	OfferType *offerType = [NSEntityDescription insertNewObjectForEntityForName:kSPEntityOfferType inManagedObjectContext:self.managedObjectContextForTesting];
	
	offerType.offerTypeId = @1;
	offerType.readable = @"Readable";
	
	XCTAssertTrue([self saveCoreData]);
}

- (void)testThumbnailInsert
{
	Thumbnail *thumbnail = [NSEntityDescription insertNewObjectForEntityForName:kSPEntityThumbnail  inManagedObjectContext:self.managedObjectContextForTesting];
	
	thumbnail.lowres = @"http://blog.gettyimages.com/wp-content/uploads/2013/01/Siberian-Tiger-Running-Through-Snow-Tom-Brakefield-Getty-Images-200353826-001.jpg";
	thumbnail.hires = @"http://blog.gettyimages.com/wp-content/uploads/2013/01/Siberian-Tiger-Running-Through-Snow-Tom-Brakefield-Getty-Images-200353826-001.jpg";
	
	XCTAssertTrue([self saveCoreData]);
}

- (void)testTimeToPayoutInsert
{
	TimeToPayout *offerType = [NSEntityDescription insertNewObjectForEntityForName:kSPEntityTimeToPayout inManagedObjectContext:self.managedObjectContextForTesting];
	
	offerType.amount = @100;
	offerType.readable = @"30 Minute";
	
	XCTAssertTrue([self saveCoreData]);
}

#pragma mark - Helpers

- (BOOL)saveCoreData
{
	NSError *error = nil;
	if (![[self managedObjectContextForTesting] save:&error])
	{
		XCTFail(@"Error saving the object in coredata: %@, %@", error, [error userInfo]);
		
		return NO;
	}
	
	return YES;
}

@end
