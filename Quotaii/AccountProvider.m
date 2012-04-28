//
//  AccountDelegate.m
//  Quotaii
//
//  Created by Joshua Lay on 9/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//


#import "AccountProvider.h"
#import "AccountDetails.h"

#import "Lockbox.h"

#define kUsernameString @"lockboxUsernameKey"
#define kPasswordString @"lockboxPasswordKey"

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
    
    [self resetAccount];
    
    NSLog(@"store:accountDetails - username: %@", accountDetails.username);
    
    BOOL didSetUsername = [Lockbox setString:self->_accountDetails.username forKey:kUsernameString];
    BOOL didSetPassword = [Lockbox setString:self->_accountDetails.password forKey:kPasswordString];
}

- (void)resetAccount {
    [Lockbox setString:nil forKey:kUsernameString];
    [Lockbox setString:nil forKey:kPasswordString];
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
    NSString *username = [Lockbox stringForKey:kUsernameString];
    NSLog(@"retrieveAccountDetailsOrNil : username: %@", username);
    if (username == nil || [username isEqualToString:@""])
        return nil;
    
    NSString *password = [Lockbox stringForKey:kPasswordString];
    AccountDetails *accountDetails = [[AccountDetails alloc] initWithUsername:username 
                                                                     Password:password];
    self->_accountDetails = accountDetails;
    
    return self->_accountDetails;
}


@end
