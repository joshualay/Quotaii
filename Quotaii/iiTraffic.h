//
//  iiTraffic.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 21/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iiTrafficType.h"

@interface iiTraffic : NSObject

@property (nonatomic, assign) TrafficType trafficType;
// Since this is in bytes we can exceed the max integer range
@property (nonatomic, assign) long long used;
@property (nonatomic, assign) NSInteger quota;
@property (nonatomic, assign) BOOL isShaped;
@property (nonatomic, strong) NSString *shapedSpeed;

@end
