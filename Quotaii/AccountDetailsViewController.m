//
//  AccountDetailsViewController.m
//  Quotaii
//
//  Created by Joshua Lay on 10/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "AccountDetailsViewController.h"

@implementation AccountDetailsViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)storeAccountDetails:(id)sender {
    [self.delegate didRetrieveAccountUsername:self->usernameField.text Password:self->passwordField.text];
}

@end
