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

@interface MasterViewController : UITableViewController <iiVolumeUsageProviderDelegate, AccountDetailsViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) iiVolumeUsageProvider *volumeUsageProvider;
@property (strong, nonatomic) AccountProvider *accountProvider;

@end
