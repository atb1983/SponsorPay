//
//  SPOffersViewController.m
//  SponsorPay
//
//  Created by Alex Núñez on 11/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPOffersViewController.h"
#import "SPOfferTableViewCell.h"

#import "Offer.h"
#import "Thumbnail.h"
#import "TimeToPayout.h"
#import "SPRespose.h"

#import "UIImage+Extentions.h"

#import <SDWebImageManager.h>

@interface SPOffersViewController () <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) SPRespose *response;
@property (nonatomic, assign) BOOL isShownPlaceHolder;
@property (nonatomic, strong) UIView *customHeader;

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

	[self addTableHeader];
	
    // Feed
    [self loadOffersWithPage:@1];
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
		NSInteger numberOfObjects = [sectionInfo numberOfObjects];
		
        return numberOfObjects;
    }
	else
	{
        return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOffersCellIdentifier];
	[self configureCell:(SPOfferTableViewCell *)cell atIndexPath:indexPath];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sponsorpay_title", nil) message:NSLocalizedString(@"funtionality_not_implemented_yet", nil) delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	
	[self updateTableViewHeader];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (buttonIndex == 1)
	{
		[self performSegueWithIdentifier:kSegueGoToConfigurationViewController sender:nil];
	}
}

#pragma mark - Actions

- (void)refresh:(UIEvent *)event
{
	// Refresh the first page
	[self loadOffersWithPage:@1];
}

#pragma mark - Helpers

/**
 *  Add a header with util information
 */
- (void)addTableHeader
{
	self.customHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
	UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.customHeader.frame.size.width - 10, 60)];
	helpLabel.text = NSLocalizedString(@"offers_no_data", nil);
	helpLabel.textAlignment = NSTextAlignmentCenter;
	[helpLabel setNumberOfLines:2];
	[self.customHeader addSubview:helpLabel];
    self.customHeader.backgroundColor = [UIColor clearColor];
	
	[self updateTableViewHeader];
}

/**
 *  Shows a place holder when fetchedObjects are 0
 */
- (void)updateTableViewHeader
{
    if ([self.fetchedResultsController.fetchedObjects count] == 0)
    {
        self.tableView.tableHeaderView = self.customHeader;
    }
    else
    {
        self.tableView.tableHeaderView = nil;
    }
}
/**
 *  Load offers,  also allows pagination. if we have already a "response" and the count is bigger than pages it means that we can load more information
 * ATENTION: I coudn't test this properly, I wasn't able to get more than one page for the user : spiderman. I would like to have another use to test in order to make sure that this method is working well.
 */
- (void)loadOffers
{
	if (self.response.count > self.response.pages)
	{
		// current page + 1;
		NSNumber *nextPage = @([self.response.pages intValue] + 1);
		[self loadOffersWithPage:nextPage];
	}
}

/**
 *  Load offers using an specific page
 *
 *  @param page to fetch
 */
- (void)loadOffersWithPage:(NSNumber *)page;
{
	[[SPReskitManager sharedInstance] loadOffersWithPage:page complationBlock:^(RKMappingResult *returnObject, BOOL success, SPError *error) {
		[self.refreshControl endRefreshing];
		
		if (!success)
		{
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:error.message delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:NSLocalizedString(@"offers_change_configuration",nil), nil] show];
		}
		else
		{
			self.response = [returnObject.array objectAtIndex:0];
		}
		
		[self.tableView reloadData];
	}];
}

- (void)configureCell:(SPOfferTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Offer *offer = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
    cell.titleLabel.text = offer.title;
	cell.amountLabel.text = [self.numberFormatter stringFromNumber:offer.timeToPayout.amount];
	cell.teaserLabel.text	= offer.teaser;
	cell.readableLabel.text = [NSString stringWithFormat:NSLocalizedString(@"offers_timetopayout_label", nil), offer.timeToPayout.readable];
    
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:offer.offerToThumbnail.hires]
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
