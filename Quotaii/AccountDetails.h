//
//  AccountDetails.h
//  Quotaii
//
//  Created by Joshua Lay on 10/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountDetails : NSObject {
    NSString *_username;
    NSString *_password;
}

- (id)initWithUsername:(NSString *)username Password:(NSString *)password;

@property (readonly, strong) NSString *username;
@property (readonly, strong) NSString *password;

@end
