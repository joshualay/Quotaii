//
//  iiConnection.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 22/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iiIpAddress : NSObject

@property (nonatomic, strong) NSDate *connectedSinceDate;
@property (nonatomic, strong) NSString *ipAddress;
    
@end

@interface iiConnection : NSObject

@property (nonatomic, strong) NSMutableArray *ipList;

@end
