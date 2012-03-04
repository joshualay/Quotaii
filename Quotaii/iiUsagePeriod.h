//
//  iiUsageUnit.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 22/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iiUsagePeriod : NSObject

@property (nonatomic, strong) NSString *period;
@property (nonatomic, strong) NSMutableArray *usageUnitList;

@end
