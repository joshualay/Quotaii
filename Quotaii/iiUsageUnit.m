//
//  iiUsageUnit.m
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 22/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "iiUsageUnit.h"
#import "iiTrafficType.h"

@implementation iiUsageUnit

@synthesize trafficType, bytes;

- (double)getMegaBytes {
    return self.bytes / 1024 / 1024;
}

- (double)getGigaBytes {
    return [self getMegaBytes] / 1024;
}

@end
