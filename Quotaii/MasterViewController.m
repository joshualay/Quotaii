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
#import "DDProgressView.h"

@interface MasterViewController (PrivateMethods)
- (void)presentVolumeUsage:(iiFeed *)iiFeed;
- (void)presentAccountDetailsView:(BOOL)animate;
- (void)retrieveVolumeUsage;
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize volumeUsageProvider  = _volumeUsageProvider;
@synthesize accountProvider      = _accountProvider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Quotaii", @"Quotaii");
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
    
    NSLog(@"viewDidLoad");
    
    self->_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect viewFrame = self.view.frame;
    self->_activityIndicator.frame = CGRectMake((viewFrame.size.width / 2) - 20.0f, viewFrame.size.height/2, 40.0f, 40.0f);
    self->_activityIndicator.backgroundColor = [UIColor blackColor];
    
    [self->_activityIndicator startAnimating];
    [self.view addSubview:self->_activityIndicator];
    
    if (![self.accountProvider hasAccountInformation]) {
        [self presentAccountDetailsView:NO];
        return;
    }
    
    [self retrieveVolumeUsage];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - PrivateMethods
- (void)presentAccountDetailsView:(BOOL)animate {
    AccountDetailsViewController *vc = [[AccountDetailsViewController alloc] initWithNibName:@"AccountDetailsViewController" bundle:nil];
    vc.delegate = self;
    [self presentModalViewController:vc animated:animate];
}

- (void)retrieveVolumeUsage {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        iiFeed *iiFeed = [self.volumeUsageProvider retrieveUsage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_activityIndicator stopAnimating];
            [self->_activityIndicator removeFromSuperview];
            
            NSLog(@"Got volume usage: %@", iiFeed);
            [self presentVolumeUsage:iiFeed];
        });
    });    
}

- (void)presentVolumeUsage:(iiFeed *)iiFeed {
    
    float xOffset = 8.0f;
    
    float yOffset = 20.0f;    
    float labelHeight = 22.0f;
    float labelOffset = 20.0f;
    float usageBarHeight = 54.0f;
    float usageBarWidth = 300.0f;
    
    for (iiTraffic *trafficType in iiFeed.volumeUsage.expectedTrafficList) {
        NSLog(@"Quota: %i, Type: %i", trafficType.quota, trafficType.trafficType);
        
        NSInteger quota = trafficType.quota;
        // Freezone && Uploads
        if (quota == 0) {
            continue; 
        }
        
        NSInteger used  = (NSInteger)(trafficType.used / 1024.0f / 1024.0f);        
        float usagePercentage = (float)used / (float)quota;
        
        DDProgressView *usageBar = [[DDProgressView alloc] initWithFrame:CGRectMake(xOffset, yOffset, usageBarWidth, usageBarHeight)];
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset + labelOffset + usageBarHeight, usageBarWidth, labelHeight)];
        
        NSString *trafficTypeName = nil;
        switch (trafficType.trafficType) {
            case iiTrafficTypeAnytime:
                trafficTypeName = @"Anytime";
                break;
            case iiTrafficTypePeak:
                trafficTypeName = @"Peak";
                break;
            case iiTrafficTypeOffPeak:
                trafficTypeName = @"Offpeak";
                break;
            default:
                break;
        }
        
        int roundedUsagePercentage = (int)(usagePercentage * 100);
        
        typeLabel.text = [NSString stringWithFormat:@"%@ (%i%%)", trafficTypeName, roundedUsagePercentage];
        
        [usageBar setProgress:usagePercentage];
        
        [self.view addSubview:typeLabel];
        [self.view addSubview:usageBar];
        
        yOffset += (usageBarHeight + labelHeight + labelOffset);
    }
    
    [self dismissModalViewControllerAnimated:NO];
}


#pragma mark - iiVolumeUsageProviderDelegate
// @required

- (void)didHaveAuthenticationError:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.accountProvider resetAccount];
        UIAlertView *authAlert = [[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Your account details appear to be incorrect. Please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Try again", nil];
        [authAlert show];
    });
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

- (void)didHaveConnectionError:(NSString *)message {
    NSLog(@"didHaveConnectionError: %@", message);
}

- (void)didHaveParsingError:(NSString *)message {
    NSLog(@"didHaveParsingError: %@", message);
}

- (void)didHaveXMLConstructionError {
    NSLog(@"didHaveXMLConstructionError");
}
 
- (void)didHaveToolboxUnderLoadError:(NSString *)message {
    NSLog(@"didHaveToolboxUnderLoadError");
}

- (void)didHaveGenericError:(NSString *)messageOrNil {
    NSLog(@"didHaveGenericError: %@", messageOrNil);
}

- (void)didUseCachedResult {
    NSLog(@"didUseCachedResult");
}

#pragma mark - AccountDetailsViewControllerDelegate
- (void)didRetrieveAccountUsername:(NSString *)username Password:(NSString *)password {
    AccountDetails *ad = [[AccountDetails alloc] initWithUsername:username Password:password];
    [self.accountProvider store:ad];
    [self retrieveVolumeUsage];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"present alert view");
    [self presentAccountDetailsView:YES];
    NSLog(@"alertView clickedButtonAtIndex: %i", buttonIndex);
}

@end
