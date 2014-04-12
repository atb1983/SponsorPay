//
//  SPOffersViewController.m
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPOffersViewController.h"
#import "SPDetailViewController.h"
#import "SPOfferTableViewCell.h"

#import "Offer.h"
#import "Thumbnail.h"
#import "TimeToPayout.h"

#import "UIImage+Extentions.h"

#import <SDWebImageManager.h>

NSString *const kOffersCellIdentifier = @"OffersCellID";

@interface SPOffersViewController () <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SPOffersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	// RefreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
	[self.navigationController setDelegate:self];
	
    // Feed
    [self loadOffers];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
	{
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSPEntityOffer inManagedObjectContext:[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptorType = [[NSSortDescriptor alloc] initWithKey:@"offerId" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorType];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
	
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext sectionNameKeyPath:nil cacheName:kSPEntityOffer];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error])
	{
	    abort();
	}
	
    return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([[self.fetchedResultsController sections] count] > 0)
	{
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
	else
	{
        return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPOfferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOffersCellIdentifier];
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
		{
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
        case NSFetchedResultsChangeDelete:
		{
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
            break;
		}
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	switch(type)
	{
        case NSFetchedResultsChangeInsert:
		{
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
        case NSFetchedResultsChangeDelete:
		{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
        case NSFetchedResultsChangeUpdate:
		{
			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
        case NSFetchedResultsChangeMove:
		{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Helpers

- (void)loadOffers
{
	[[SPReskitManager sharedInstance] loadOffersByAppId:@"2070" uid:@"Spiderman" apiKey:kAPIKey pub0:@"112"];
}

- (void)configureCell:(SPOfferTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Offer *offer = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
    cell.titleLabel.text = offer.title;
	cell.amountLabel.text = [NSString stringWithFormat:@"€%@", offer.timeToPayout.amount];
	cell.teaserLabel.text	= offer.teaser;
    
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:offer.offerToThumbnail.lowres]
							placeholderImage:[UIImage imageNamed:@"Placeholder"]];
	
	//using the SDWebImage downloader, start downloading the image
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
	[manager downloadWithURL:[NSURL URLWithString:offer.offerToThumbnail.hires]
					 options:0
					progress:^(NSInteger receivedSize, NSInteger expectedSize) {
					}
				   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
					   /**
						We can do this because the block "captures" the
						necessary variables in its context for reference
						when it starts execution.
						**/
					   NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
					   if ([visibleIndexPaths containsObject:indexPath])
					   {
						   cell.avatarImageView.image = [image imageWithRoundedCornersRadius:2.0f];
					   }
				   }];
}

@end
