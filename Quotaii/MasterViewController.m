//
//  MasterViewController.m
//  Quotaii
//
//  Created by Joshua Lay on 4/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AccountProvider.h"
#import "AccountDetails.h"
#import "DDProgressView.h"

#define kLoadingWidth  100.0f
#define kLoadingHeight 100.0f

#define kSubviewWidth 300.0f

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_noise_tile"]];
    
    self.navigationController.navigationBarHidden = YES;
    
    if (![self.accountProvider hasAccountInformation]) {
        [self presentAccountDetailsView:NO];
        return;
    }
    
    [self retrieveVolumeUsage];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self retrieveVolumeUsage];
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
    self->_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];  
    CGRect viewFrame = self.view.frame;
    self->_activityIndicator.frame = CGRectMake((viewFrame.size.width / 2) - (kLoadingWidth / 2.0f), viewFrame.size.height/4, kLoadingWidth, kLoadingHeight);
    [self->_activityIndicator setClipsToBounds:YES];
    [self->_activityIndicator.layer setCornerRadius:10];
    
    self->_activityIndicator.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self->_activityIndicator];
    [self->_activityIndicator startAnimating];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        // TODO - remove
        //iiFeed *iiFeed = [self.volumeUsageProvider retrieveUsage];
        iiFeed *iiFeed = [self.volumeUsageProvider mockRetrieveUsage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_activityIndicator stopAnimating];
            [self->_activityIndicator removeFromSuperview];
            
            NSLog(@"Got volume usage: %@", iiFeed);
            [self presentVolumeUsage:iiFeed];
        });
    });    
}

- (void)presentVolumeUsage:(iiFeed *)iiFeed {     
    for (iiTraffic *trafficType in iiFeed.volumeUsage.expectedTrafficList) {
        NSLog(@"Quota: %i, Type: %i", trafficType.quota, trafficType.trafficType);
        
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
        
        NSInteger quota = trafficType.quota;
        if (quota != 0) {
            UILabel *trafficTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, kSubviewWidth, 50.0f)];
            trafficTypeLabel.text = trafficTypeName;
            [self.view addSubview:trafficTypeLabel];
            
            // To GB - We're using basic conversion here as Toolbox returns nice rounded quota's
            NSInteger total = trafficType.quota / 1000;
            
            UILabel *usedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 110.0f, kSubviewWidth, 55.0f)];
            NSInteger used  = (NSInteger)(trafficType.used / 1024.0f / 1024.0f);        
            if (used < 1024) {
                usedLabel.text = [NSString stringWithFormat:@"%iMB", used];
            }
            else {
                usedLabel.text = [NSString stringWithFormat:@"%.2fGB", (used/1024.0f)];
            }
            
            [self.view addSubview:usedLabel];
            
            UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 170.0f, kSubviewWidth, 55.0f)];
            totalLabel.text = [NSString stringWithFormat:@"%iGB", total];
            [self.view addSubview:totalLabel];
            
            float usagePercentage = (float)used / (float)quota;
            
            DDProgressView *usageBar = [[DDProgressView alloc] initWithFrame:CGRectMake(10.0f, 50.0f, kSubviewWidth, 55.0f)];
            
            int roundedUsagePercentage = (int)(usagePercentage * 100);
            NSString *percentageUsedString = [NSString stringWithFormat:@"%@ (%i%%)", trafficTypeName, roundedUsagePercentage];
            
            [usageBar setProgress:usagePercentage];
            [self.view addSubview:usageBar];
        }
        
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
