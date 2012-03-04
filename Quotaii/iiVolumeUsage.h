//
//  iiVolumeUsage.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 22/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iiQuotaReset.h"
#import "iiVolumeUsageBreakdown.h"

@interface iiVolumeUsage : NSObject

@property (nonatomic, strong) NSString *offPeakStart;
@property (nonatomic, strong) NSString *offPeakEnd;
@property (nonatomic, strong) iiQuotaReset *quotaReset;
// Of type iiTraffic
@property (nonatomic, strong) NSMutableArray *expectedTrafficList;
@property (nonatomic, strong) NSMutableArray *volumeUsageBreakdown;

@end
