//
//  MasterViewController.m
//  Quotaii
//
//  Created by Joshua Lay on 4/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AccountProvider.h"
#import "AccountDetails.h"

@interface MasterViewController (PrivateMethods)

@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize volumeUsageProvider  = _volumeUsageProvider;
@synthesize accountProvider      = _accountProvider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        self.volumeUsageProvider = [[iiVolumeUsageProvider alloc] init];
        self.volumeUsageProvider.delegate = self;
        
        self.accountProvider = [[AccountProvider alloc] init];                                
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self.accountProvider hasAccountInformation]) {
        AccountDetailsViewController *vc = [[AccountDetailsViewController alloc] initWithNibName:@"AccountDetailsViewController" bundle:nil];
        vc.delegate = self;
        [self presentModalViewController:vc animated:NO];
        
        return;
    }
    
    [self retrieveVolumeUsage];

}

- (void)retrieveVolumeUsage {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        iiFeed *iiFeed = [self.volumeUsageProvider retrieveUsage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Got volume usage");
        });
    });    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell.
    cell.textLabel.text = NSLocalizedString(@"Detail", @"Detail");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}


#pragma mark - iiVolumeUsageProviderDelegate
// @required

- (void)didHaveAuthenticationError:(NSString *)message {
    UIAlertView *authAlert = [[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Your account details appear to be incorrect. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Try again", nil];
    [authAlert show];
    
    // TODO -- Handle try again to present AccountDetailsViewController
}

// Provide the username to the Provider
- (NSString *)accountUsername {
    return [self.accountProvider username];
}

// Provide the password to the Provider
- (NSString *)accountPassword {
    return [self.accountProvider password];
}

// @optional
- (void)didBeginRetrieveUsage {
    NSLog(@"didBeginRetrieveUsage");
}

- (void)didFinishRetrieveUsage {
    NSLog(@"didFinishRetrieveUsage");
}

#pragma mark - AccountDetailsViewControllerDelegate
- (void)didRetrieveAccountUsername:(NSString *)username Password:(NSString *)password {
    AccountDetails *ad = [[AccountDetails alloc] initWithUsername:username Password:password];
    [self.accountProvider store:ad];
    [self retrieveVolumeUsage];
    [self dismissModalViewControllerAnimated:YES];
}

@end
