//
//  AccountDelegate.h
//  Quotaii
//
//  Created by Joshua Lay on 9/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AccountDetails;
@class KeychainItemWrapper;

@interface AccountProvider : NSObject {
    AccountDetails *_accountDetails;
    KeychainItemWrapper *_keychain;
}

- (NSString *)username;
- (NSString *)password;

- (BOOL)hasAccountInformation;
- (void)store:(AccountDetails *)accountDetails;
- (void)resetAccount;


@end
