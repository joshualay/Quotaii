//
//  MasterViewController.h
//  Quotaii
//
//  Created by Joshua Lay on 4/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iiVolumeUsageProvider.h"
#import "AccountDetailsViewController.h"

@class AccountProvider;
@class DetailViewController;

@interface MasterViewController : UIViewController <iiVolumeUsageProviderDelegate, AccountDetailsViewControllerDelegate, UIAlertViewDelegate> {
    UIActivityIndicatorView *_activityIndicator;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) iiVolumeUsageProvider *volumeUsageProvider;
@property (strong, nonatomic) AccountProvider *accountProvider;

@end
