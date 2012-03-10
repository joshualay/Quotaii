//
//  AccountDetails.m
//  Quotaii
//
//  Created by Joshua Lay on 10/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "AccountDetails.h"

@implementation AccountDetails

@synthesize username = _username;
@synthesize password = _password;

- (id)initWithUsername:(NSString *)username Password:(NSString *)password {
    self = [super init];
    if (self != nil) {
        self->_username = username;
        self->_password = password;
    }
    return self;
}

@end
