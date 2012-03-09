//
//  MasterViewController.h
//  Quotaii
//
//  Created by Joshua Lay on 4/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iiVolumeUsageProvider.h"
#import "AccountProvider.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <iiVolumeUsageProviderDelegate, AccountProviderDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) iiVolumeUsageProvider *volumeUsageProvider;
@property (strong, nonatomic) AccountProvider *accountProvider;

@end
