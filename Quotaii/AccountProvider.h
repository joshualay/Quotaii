//
//  AccountDelegate.h
//  Quotaii
//
//  Created by Joshua Lay on 9/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AccountDetails;

@interface AccountProvider : NSObject {
    AccountDetails *_accountDetails;
}

- (NSString *)username;
- (NSString *)password;

- (BOOL)hasAccountInformation;
- (void)store:(AccountDetails *)accountDetails;


@end
