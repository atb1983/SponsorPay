//
//  SPOffersViewController.m
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPOffersViewController.h"
#import "SPOfferTableViewCell.h"
#import "SPPlaceHolderTableViewCell.h"

#import "Offer.h"
#import "Thumbnail.h"
#import "TimeToPayout.h"

#import "UIImage+Extentions.h"

#import <SDWebImageManager.h>

NSString *const kOffersCellIdentifier		= @"OffersCellID";
NSString *const kPlaceHolderCellIdentifier	= @"PlaceHolderCellID";

@interface SPOffersViewController () <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation SPOffersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = NSLocalizedString(@"offers_vc_title", nil);
	[self.navigationItem setHidesBackButton:YES];

	// Number Formatter
	self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[self.numberFormatter setCurrencySymbol:@"€ "];
	[self.numberFormatter setMaximumFractionDigits:0];
	
	// RefreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
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
        return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	if ([[self.fetchedResultsController sections] count] == 0)
	{
		// No results
		cell = [tableView dequeueReusableCellWithIdentifier:kPlaceHolderCellIdentifier];
		SPPlaceHolderTableViewCell *placeHolderCell = (SPPlaceHolderTableViewCell *)cell;
		placeHolderCell.titleLabel.text = NSLocalizedString(@"offers_no_data", nil);
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kOffersCellIdentifier];
		[self configureCell:(SPOfferTableViewCell *)cell atIndexPath:indexPath];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self.fetchedResultsController sections] count] > 0)
	{
        return 114;
    }
	else
	{
        return 60;
	}
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


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat contentOffsetY = scrollView.contentOffset.y;
	CGFloat contentHeight = scrollView.contentSize.height;
	CGFloat boundsHeight = scrollView.bounds.size.height;
	
	if ((contentOffsetY + boundsHeight) >= contentHeight)
	{
		[self loadOffers];
	}
}

#pragma mark - Actions

- (void)refresh:(UIEvent *)event
{
	[self loadOffers];
}

#pragma mark - Helpers

- (void)loadOffers
{
	[[SPReskitManager sharedInstance] loadOffersWithCompletionBlock:^(RKMappingResult *returnObject, BOOL success, NSError *error) {
		[self.refreshControl endRefreshing];
	}];
}

- (void)configureCell:(SPOfferTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Offer *offer = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
    cell.titleLabel.text = offer.title;
	cell.amountLabel.text = [self.numberFormatter stringFromNumber:offer.timeToPayout.amount];
	cell.teaserLabel.text	= offer.teaser;
	cell.readableLabel.text = [NSString stringWithFormat:NSLocalizedString(@"offers_timetopayout_label", nil), offer.timeToPayout.readable];
    
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:offer.offerToThumbnail.lowres]
							placeholderImage:[UIImage imageNamed:@"Placeholder"]];
	
	//using the SDWebImage downloader, start downloading the image
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
	[manager downloadWithURL:[NSURL URLWithString:offer.offerToThumbnail.lowres]
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
