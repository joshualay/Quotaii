//
//  AccountDelegate.m
//  Quotaii
//
//  Created by Joshua Lay on 9/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//


#import "AccountProvider.h"
#import "AccountDetails.h"

@interface AccountProvider (PrivateMethods)
- (AccountDetails *)retrieveAccountDetailsOrNil;
- (void)retrieveAccountInformation;
@end

@implementation AccountProvider

- (id)init {
    self = [super init];
    if (self != nil) {
        [self retrieveAccountInformation];
    }
    return self;
}

- (BOOL)hasAccountInformation {
    return (self->_accountDetails == nil) ? NO : YES;
}


- (void)store:(AccountDetails *)accountDetails {
    // TODO: Throw an error
    if (accountDetails == nil)
        return;
    
    self->_accountDetails = accountDetails;
}

- (void)resetAccount {

}

- (NSString *)username {
    return [self->_accountDetails username];
}

- (NSString *)password {
    return [self->_accountDetails password];
}


// PRIVATE
- (void)retrieveAccountInformation {
    AccountDetails *ad = [self retrieveAccountDetailsOrNil];
    if (ad == nil) {
        // TODO: Throw error
        return;
    }
    
    self->_accountDetails = ad;
}

- (AccountDetails *)retrieveAccountDetailsOrNil {
    // TODO
    NSString *username = @"";
    if (username == nil || [username isEqualToString:@""])
        return nil;
    
    AccountDetails *accountDetails = [[AccountDetails alloc] initWithUsername:username 
                                                                     Password:@"0"];
    self->_accountDetails = accountDetails;
    
    return self->_accountDetails;
}


@end
