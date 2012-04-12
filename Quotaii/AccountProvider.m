//
//  AccountDelegate.m
//  Quotaii
//
//  Created by Joshua Lay on 9/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//


#import "AccountProvider.h"
#import "AccountDetails.h"

#import "KeychainItemWrapper.h"

@interface AccountProvider (PrivateMethods)
- (AccountDetails *)retrieveAccountDetailsOrNil;
- (void)retrieveAccountInformation;
@end

@implementation AccountProvider

- (id)init {
    self = [super init];
    if (self != nil) {
        [self retrieveAccountInformation];
        self->_keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"Quotaii" accessGroup:nil];
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
    
    [self->_keychain setObject:accountDetails.username forKey:(__bridge id)kSecAttrAccount];
    [self->_keychain setObject:accountDetails.password forKey:(__bridge id)kSecValueData];
    
    NSLog(@"store:accountDetails - username: %@", accountDetails.username);
}

- (void)resetAccount {
    [self->_keychain resetKeychainItem];
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
    id something = [self->_keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString *username = (NSString *)[self->_keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSLog(@"retrieveAccountDetailsOrNil : username: %@", username);
    if (username == nil || [username isEqualToString:@""])
        return nil;
    
    NSString *password = (NSString *)[self->_keychain objectForKey:(__bridge id)kSecValueData];
    AccountDetails *accountDetails = [[AccountDetails alloc] initWithUsername:username 
                                                                     Password:password];
    self->_accountDetails = accountDetails;
    
    return self->_accountDetails;
}


@end
