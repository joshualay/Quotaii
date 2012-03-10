//
//  iiFeed.m
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 26/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "iiFeed.h"

@implementation iiFeed

@synthesize accountInfo = _accountInfo;
@synthesize volumeUsage = _volumeUsage;
@synthesize connection  = _connection;

- (id)initFeedWith:(iiAccountInfo *)accountInfo volumeUsage:(iiVolumeUsage *)volumeUsage connection:(iiConnection *)connection {
    if (accountInfo == nil && volumeUsage == nil && connection == nil)
        return nil;
    
    self = [super init];
    if (self) {
        self->_accountInfo = accountInfo;
        self->_volumeUsage = volumeUsage;
        self->_connection  = connection;
    }
    return self;
}

@end
