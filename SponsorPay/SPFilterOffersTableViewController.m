//
//  SPFilterOffersTableViewController.m
//  SponsorPay
//
//  Created by Alex Núñez on 13/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPFilterOffersTableViewController.h"
#import "_OfferType.h"

@interface SPFilterOffersTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *filters;

@end

@implementation SPFilterOffersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"filteroffers_vc_title", nil);
	
	[self addTableHeader];
	[self loadSavedFilters];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	// before we leave the view we save the filter list
	[self saveFilters];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFilterOffersCellIdentifier forIndexPath:indexPath];
    
	_OfferType *offerType = [self.filters objectAtIndex:indexPath.row];
	
	cell.textLabel.text = offerType.description;
	cell.detailTextLabel.text = offerType.readable;
	cell.accessoryType = offerType.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// We get the object
	_OfferType *offerType = [self.filters objectAtIndex:indexPath.row];
	
	// if the object is seleted we set it as unselected and vicversa
	offerType.selected = !offerType.selected;
	
	// update the cell with the cell accesory
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = offerType.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helpers

/**
 *  Add a header with useful information
 */
- (void)addTableHeader
{
    UIView *customHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
	
	UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, customHeader.frame.size.width - 10, 60)];
	helpLabel.text = NSLocalizedString(@"filteroffers_info", nil);
	helpLabel.textAlignment = NSTextAlignmentCenter;
	[helpLabel setNumberOfLines:2];
	[customHeader addSubview:helpLabel];
    customHeader.backgroundColor = [UIColor lightGrayColor];
	
	self.tableView.tableHeaderView = customHeader;
}

/**
 *  Load the filters from the user defaults, if the object return from user defautls is empty we create the list of filters
 */
- (void)loadSavedFilters
{
	NSData *filtersEncoded = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFilters];
	self.filters = [NSKeyedUnarchiver unarchiveObjectWithData: filtersEncoded];
	
	if (!self.filters)
	{
		[self createFilters];
	}
}

/**
 *  self.filters gets encoded to a NSData object and we save if to the userdefaults.
 */
- (void)saveFilters
{
	NSData *filtersEncoded = [NSKeyedArchiver archivedDataWithRootObject:self.filters];
	[[NSUserDefaults standardUserDefaults] setObject:filtersEncoded forKey:kUserDefaultsFilters];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  List with the filters
 */
- (void)createFilters
{
	self.filters = [[NSMutableArray alloc] init];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@100 readable:@"Mobile" description:@"Mobile subscription offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@101 readable:@"Download" description:@"Download offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@102 readable:@"Trial" description:@"Trial offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@103 readable:@"Sale" description:@"Shopping offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@104 readable:@"Registration" description:@"Information request offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@105 readable:@"Registration" description:@"Registration offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@106 readable:@"Games" description:@"Gaming offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@107 readable:@"Games" description:@"Gambling offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@108 readable:@"Registration" description:@"Data generation offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@109 readable:@"Games" description:@"Games offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@110 readable:@"Surveys" description:@"Dating offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@111 readable:@"Registration" description:@"Survey offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@112 readable:@"Free" description:@"Free offers" selected:NO]];
	[self.filters addObject:[[_OfferType alloc] initWithTypeId:@113 readable:@"Video" description:@"Video offers" selected:NO]];
	
	NSArray *sortedArray = [self.filters sortedArrayUsingComparator:^(id a, id b) {
		NSString *first = [(_OfferType *)a description];
		NSString *second = [(_OfferType *)b description];
		return [first caseInsensitiveCompare:second];
	}];

	self.filters = [sortedArray mutableCopy];
}

@end
