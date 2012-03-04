//
//  iiFeed.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 26/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iiAccountInfo.h"
#import "iiVolumeUsage.h"
#import "iiConnection.h"

@interface iiFeed : NSObject {
    iiAccountInfo *_accountInfo;
    iiVolumeUsage *_volumeUsage;
    iiConnection  *_connection;
}

@property (readonly) iiAccountInfo *accountInfo;
@property (readonly) iiVolumeUsage *volumeUsage;
@property (readonly) iiConnection  *connection;

- (id)initFeedWith:(iiAccountInfo *)accountInfo volumeUsage:(iiVolumeUsage *)volumeUsage connection:(iiConnection *)connection;

@end
