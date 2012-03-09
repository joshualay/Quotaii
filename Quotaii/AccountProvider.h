//
//  AccountDelegate.h
//  Quotaii
//
//  Created by Joshua Lay on 9/03/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AccountProviderDelegate <NSObject>

@end

@interface AccountProvider : NSObject

@property (nonatomic, weak) id<AccountProviderDelegate> delegate;

- (NSString *)username;
- (NSString *)password;

@end
