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

- (void)retrieveAccountInformation {
    AccountDetails *ad = [self retrieveAccountDetailsOrNil];
    if (ad == nil) {
        // TODO: Throw error
        return;
    }
    
    self->_accountDetails = ad;
}

- (void)store:(AccountDetails *)accountDetails {
    // TODO: Throw an error
    if (accountDetails == nil)
        return;
    
    self->_accountDetails = accountDetails;
    
    // TODO: Store in keychain!
}

- (NSString *)username {
    return [self->_accountDetails username];
}

- (NSString *)password {
    return [self->_accountDetails password];
}


// PRIVATE
- (AccountDetails *)retrieveAccountDetailsOrNil {
    // TODO -- actually look them up
    return self->_accountDetails;
}


@end
