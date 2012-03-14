//
//  iiVolumeUsageProvider.h
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 24/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iiAccountInfo.h"
#import "iiQuotaReset.h"
#import "iiTraffic.h"
#import "iiVolumeUsage.h"
#import "iiUsageUnit.h"
#import "iiTrafficType.h"
#import "iiUsagePeriod.h"
#import "iiFeed.h"

@protocol iiVolumeUsageProviderDelegate
@required
// User has entered in the incorrect username and password
// You'd perform some error handling process to prompt again
- (void)didHaveAuthenticationError:(NSString *)message;
/* 
 AUTHENTICATION METHODS
 
I'm not storing any authentication details in the provider. I feel it's better separated out from this code.
 */
// Provide the username to the Provider
- (NSString *)accountUsername;
// Provide the password to the Provider
- (NSString *)accountPassword;

@optional
// Couldn't perform the URL request
- (void)didHaveConnectionError:(NSString *)message;
// For some reason the XML iiNet has returned is malformed
- (void)didHaveParsingError:(NSString *)message;
// Couldn't create an NSXMLParser with the NSData response
- (void)didHaveXMLConstructionError;
// 
- (void)didHaveToolboxUnderLoadError:(NSString *)message;
- (void)didHaveGenericError:(NSString *)messageOrNil;

// When iiFeed is read from the cache - in case you want to flag
- (void)didUseCachedResult;

// If you want to put a loading sequence whilst the usage is being retrieved and processed
- (void)didBeginRetrieveUsage;
- (void)didFinishRetrieveUsage;
@end


@interface iiVolumeUsageProvider : NSObject <NSXMLParserDelegate> {
    id<iiVolumeUsageProviderDelegate> _delegate;
    NSCache *_cache;
    NSDate *_lastRetrieved;
    
    NSMutableString *_currentStringValue;

    NSString *_stateTracking;
    NSString *_secondTierStateTracking;   

    iiAccountInfo *_accountInfo;
    iiVolumeUsage *_volumeUsage;
    iiConnection *_connection;
    iiIpAddress *_ip;

    iiTraffic *_trafficUnit;
    iiUsagePeriod *_usagePeriod;
    iiUsageUnit *_usageUnit;
        
    BOOL _errorFlagged;
    NSString *_error;
}

@property (nonatomic, strong) id delegate;
@property (readonly) NSString *error;

- (BOOL)hasRetrievedUsage;

- (iiFeed *)retrieveUsage;
- (void)resetCache;

@end
