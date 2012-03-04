//
//  iiTrafficType.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 22/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    iiTrafficTypePeak = 0,
    iiTrafficTypeOffPeak,
    iiTrafficTypeFreezone,
    iiTrafficTypeAnytime,
    iiTrafficTypeUploads
} TrafficType;

/*
 Category: EnumParser
 
 Since we're using an enum to store the traffic type we require a way to convert the string value
 to what matches in iiTrafficType.
 
 This Category will allow us to turn a valid traffic type string into its corresponding enum value.
 
 e.g.
 
 #import "iiTrafficType.h"
 
 NSString *trafficTypeAsString = @"peak";
 
 iiTraffic *traffic = [[iiTraffic alloc] init];
 
 traffic.trafficType = [trafficTypeAsString iiTrafficTypeFromString];
 
 */
@interface NSString (EnumParser)
- (TrafficType)iiTrafficTypeFromString;
@end

@implementation NSString (EnumParser)

- (TrafficType)iiTrafficTypeFromString {
    NSDictionary *trafficTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:iiTrafficTypePeak], @"peak", 
                                  [NSNumber numberWithInteger:iiTrafficTypeOffPeak], @"offpeak",
                                  [NSNumber numberWithInteger:iiTrafficTypeFreezone], @"freezone",
                                  [NSNumber numberWithInteger:iiTrafficTypeAnytime], @"anytime",
                                  [NSNumber numberWithInteger:iiTrafficTypeUploads], @"uploads",
                                  nil];
    return (TrafficType)[[trafficTypes objectForKey:self] intValue];
}

@end