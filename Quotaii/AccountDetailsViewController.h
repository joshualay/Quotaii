//
//  AccountDetailsViewController.h
//  Quotaii
//
//  Created by Joshua Lay on 10/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountDetailsViewControllerDelegate <NSObject>
@required
- (void)didRetrieveAccountUsername:(NSString *)username Password:(NSString *)password;

@end

@interface AccountDetailsViewController : UIViewController {
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIButton *storeButton;
}

@property (nonatomic, weak) id<AccountDetailsViewControllerDelegate> delegate;

- (IBAction)storeAccountDetails:(id)sender;

@end
