//
//  iiUsageUnit.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 22/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iiTrafficType.h"

@interface iiUsageUnit : NSObject

@property (nonatomic, assign) TrafficType trafficType;
@property (nonatomic, assign) long long bytes;

- (double)getMegaBytes;
- (double)getGigaBytes;

@end
