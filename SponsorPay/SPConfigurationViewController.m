//
//  SPConfigurationViewController.m
//  SponsorPay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "SPConfigurationViewController.h"
#import "UIView+Border.h"
#import "KeychainUserPass.h"

NSString *const kSegueGoToOffersViewController			= @"GoToOffersViewControllerSegue";
NSString *const kSegueGoToFilterOffersViewController	= @"GoToFilterOffersViewControllerSegue";
CGFloat const kScrollVieHeigthwWithKeyboardShown		= 150.0f;

@interface SPConfigurationViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *uidLabel;
@property (weak, nonatomic) IBOutlet UILabel *apiKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *appIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *filtersLabel;
@property (weak, nonatomic) IBOutlet UITextField *uidTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *pub0Label;
@property (weak, nonatomic) IBOutlet UITextField *pub0Textfield;

@property (weak, nonatomic) IBOutlet UIButton *changeFiltersButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) CGFloat previousConstraint;
@property (assign, nonatomic) BOOL currentKeyboardShowing;

@end

@implementation SPConfigurationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"configuration_vc_title", nil);
	
	[self configureScrollView];
	[self loadData];
	[self applyLocalization];
    [self applyStyle];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.uidTextField)
	{
        [self.apiKeyTextField becomeFirstResponder];
	}
	else if (textField == self.apiKeyTextField)
	{
        [self.appIdTextField becomeFirstResponder];
	}
	else if (textField == self.appIdTextField)
	{
		[self.pub0Textfield becomeFirstResponder];
	}
	else if (textField == self.pub0Textfield)
	{
		[self.changeFiltersButton sendActionsForControlEvents: UIControlEventTouchUpInside];
	}
	
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self updateViewForKeyBoardShowing:YES];
	
	if (!IS_IPHONE_5)
	{
		[self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 20) animated:YES];
	}
}

#pragma mark - Actions

- (IBAction)showFilterOffers:(id)sender
{
	[self hideKeyboard];
	[self performSegueWithIdentifier:kSegueGoToFilterOffersViewController sender:nil];
}

- (IBAction)next:(id)sender
{
	if ([self validateFields])
	{
		[self saveData];
		[self hideKeyboard];
		[self performSegueWithIdentifier:kSegueGoToOffersViewController sender:nil];
	}
}

/**
 *  Reponses to self.view touches
 *
 *  @param touches
 *  @param event
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self hideKeyboard];
}

/**
 *  We hide the keyboard and we update the constraints
 */
- (void)hideKeyboard
{
	[self.scrollView resignFirstResponder];
	[self.view endEditing:YES];
    [self updateViewForKeyBoardShowing:NO];
}

#pragma mark - Helpers

- (void)configureScrollView
{
	self.previousConstraint = self.scrollViewHeightConstraint.constant;
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.scrollView.frame.size.height, 0.0);
	self.scrollView.contentInset = contentInsets;
	self.scrollView.scrollIndicatorInsets = contentInsets;
	
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	[self.scrollView addGestureRecognizer:recognizer];
	
	self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

// Set the name of the view controoler, labels and place holders.
- (void)applyLocalization
{
	[self.uidLabel setText:NSLocalizedString(@"configuration_uid_label", nil)];
	[self.uidTextField setPlaceholder:NSLocalizedString(@"configuration_uid_textfield_placeholder", nil)];
	
	[self.apiKeyLabel setText:NSLocalizedString(@"configuration_apikey_label", nil)];
	[self.apiKeyTextField setPlaceholder:NSLocalizedString(@"configuration_apikey_textfield_placeholder", nil)];
	
	[self.appIdLabel setText:NSLocalizedString(@"configuration_appid_label", nil)];
	[self.appIdTextField setPlaceholder:NSLocalizedString(@"configuration_appid_textfield_placeholder", nil)];

	[self.pub0Label setText:NSLocalizedString(@"configuration_pub0_label", nil)];
	[self.pub0Textfield setPlaceholder:NSLocalizedString(@"configuration_pub0_textfield_placeholder", nil)];
	
	[self.filtersLabel setText:NSLocalizedString(@"configuration_filters_label", nil)];
	[self.changeFiltersButton setTitle:NSLocalizedString(@"configuration_changefilters_button", nil) forState:UIControlStateNormal];
	
	[self.nextButton setTitle:NSLocalizedString(@"configuration_next_button", nil) forState:UIControlStateNormal];
}

// Set the style for the labels and text fields
- (void)applyStyle
{
	// Colors
    UIColor *defaultBlue = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.uidTextField.textColor = defaultBlue;
    self.apiKeyTextField.textColor = defaultBlue;
    self.appIdTextField.textColor = defaultBlue;
	self.pub0Textfield.textColor = defaultBlue;
	
	// Borders
	[self.uidTextField applyBorderWithColor:defaultBlue];
    [self.apiKeyTextField applyBorderWithColor:defaultBlue];
	[self.appIdTextField applyBorderWithColor:defaultBlue];
	[self.pub0Textfield applyBorderWithColor:defaultBlue];
    [self.nextButton applyBorderWithColor:defaultBlue];
}

/**
 *  ValidateFields 
 *	Check all the textfields in order to make sure that they are correct
 *
 *  @return YES when all fields are validated
 */
- (BOOL)validateFields
{
	// Validations
	if ([self.uidTextField.text isEqualToString:@""])
	{
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"configuration_uid_empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"error", nil) otherButtonTitles:nil, nil] show];
		
		[self.uidTextField becomeFirstResponder];
		
		return NO;
	}
	else if ([self.apiKeyTextField.text length] != kAPIKeyLength)
	{
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"configuration_apikey_empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil] show];
		
		[self.apiKeyTextField becomeFirstResponder];
		
		return NO;
	}
	else if ([self.appIdTextField.text isEqualToString:@""])
	{
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"configuration_appid_empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil] show];
		
		[self.appIdTextField becomeFirstResponder];
		
		return NO;
	}
	
	return YES;
}

/**
 *  Load data from the keychain
 */
- (void)loadData
{
	self.uidTextField.text = [KeychainUserPass load:kAPIOffersUid];
	self.apiKeyTextField.text = [KeychainUserPass load:kAPIKey];
	self.appIdTextField.text = [KeychainUserPass load:kAPIOffersAppId];
	self.pub0Textfield.text = [KeychainUserPass load:kAPIOffersPub0];
}

/**
 *  We save the data in the KeyChain
 */
- (void)saveData
{
	[KeychainUserPass save:kAPIOffersUid data:self.uidTextField.text];
	[KeychainUserPass save:kAPIKey data:self.apiKeyTextField.text];
	[KeychainUserPass save:kAPIOffersAppId data:self.appIdTextField.text];
	[KeychainUserPass save:kAPIOffersPub0 data:self.pub0Textfield.text];
}

/**
 *  We update the constratins
 *
 *  @param keyboardShowing
 */
- (void)updateViewForKeyBoardShowing:(BOOL)keyboardShowing
{
    // If the keyboard is being currently displayed, we don't want to do anything with the layout otherwise weird
    // behavior can happen.
    if (self.currentKeyboardShowing == keyboardShowing)
    {
        return;
	}
	
    // Remember if the keyboard is currently on screen, so we can compare next time.
    self.currentKeyboardShowing = keyboardShowing;
	
	if (!IS_IPHONE_5)
	{
		if (keyboardShowing)
		{
			self.scrollViewHeightConstraint.constant = kScrollVieHeigthwWithKeyboardShown;
			
			[UIView animateWithDuration:0.25f animations:^
			 {
				 [self.view layoutIfNeeded];
			 }];
		}
		else
		{
			self.scrollViewHeightConstraint.constant = self.previousConstraint;
			
			[UIView animateWithDuration:0.25f animations:^
			 {
				 [self.view layoutIfNeeded];
			 }];
		}
	}
}

@end
