//
//  MasterViewController.m
//  Quotaii
//
//  Created by Joshua Lay on 4/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController (PrivateMethods)
- (void)doSomething:(iiFeed *)iiFeed;
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
	
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        iiFeed *iiFeed = [self.volumeUsageProvider retrieveUsage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Got volume usage");
            [self doSomething:iiFeed];
        });
    });
}

- (void)doSomething:(iiFeed *)iiFeed {
    NSLog(@"iiFeed: %@", iiFeed);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FEED" message:[NSString stringWithFormat:@"Product: %@", iiFeed.accountInfo.product] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
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

@end
