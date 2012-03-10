//
//  iiVolumeUsageProvider.m
//  VolumeUsageAPI
//
//  Created by Joshua Lay on 24/02/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "iiVolumeUsageProvider.h"

// Constants
#import "Errors.h"
#import "XMLElements.h"

@implementation iiVolumeUsageProvider

@synthesize error       = _error;
@synthesize delegate    = _delegate;

NSString *const kCacheName = @"VolumeUsageProviderCache";
NSString *const kCacheFeedKey = @"iiFeedKey";
NSString *kStateVolumeUsage = @"top_level_volume_usage";
NSString *const kToolboxAPIUrl = @"https://toolbox.iinet.net.au/cgi-bin/new/volume_usage_xml.cgi?action=login&username=%@&password=%@";
double const kCacheExpiryMinutes = 15.0;
NSInteger const kMillisecondsToMinutes = 60000;

- (id)init {
    self = [super init];
    if (self) {
        self->_errorFlagged = NO;
        self->_error = nil;
        self->_volumeUsage = nil;
        self->_accountInfo = nil;
        self->_lastRetrieved = nil;
        self->_cache = [[NSCache alloc] init];
        [self->_cache setName:kCacheName];
    }
    return self;
}

+ (iiVolumeUsageProvider *)sharedSingleton {
    static iiVolumeUsageProvider *sharedSingleton;
    
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[iiVolumeUsageProvider alloc] init];
        
        return sharedSingleton;
    }
}

- (iiFeed *)retrieveUsage {
    if ([self.delegate respondsToSelector:@selector(didBeginRetrieveUsage)])
        [self.delegate didBeginRetrieveUsage];
    
    if (self->_lastRetrieved != nil && [self->_cache objectForKey:kCacheFeedKey] != nil) {
        NSTimeInterval elapsedTimeSinceLastCache = [self->_lastRetrieved timeIntervalSinceNow];
        double minutes = elapsedTimeSinceLastCache * kMillisecondsToMinutes
;
        if (minutes <= kCacheExpiryMinutes) {
            if ([self.delegate respondsToSelector:@selector(didUseCachedResult)])
                [self.delegate didUseCachedResult];
            
            return [self->_cache objectForKey:kCacheFeedKey];
        }
    }
    
    // Don't put the responsibility of account management in this class
    NSString *username = [self.delegate accountUsername];
    NSString *password = [self.delegate accountPassword];
    NSString *urlAuthString = [NSString stringWithFormat:kToolboxAPIUrl, username, password];
    
    // Create the URL
    NSURL *toolboxURL = [NSURL URLWithString:urlAuthString];
    
    // Create the request 
    NSURLRequest *request = [NSURLRequest requestWithURL:toolboxURL];
    
    NSURLResponse *urlResponse;
    NSError *error;
    // Send the request synchronously - we need to wait for the response to come back before we can action
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error != nil) {
        if ([self.delegate respondsToSelector:@selector(didHaveConnectionError:)])
            [self.delegate didHaveConnectionError:[error localizedDescription]];
        
        return nil;
    }
    
    // Construct the parser object with our NSData
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:responseData];
    if (xmlParser != nil) {
        xmlParser.delegate = self;
        
        // Run the parser - We implement the delegate methods of the parser to build the object model whilst it parses
        BOOL parsingResult = [xmlParser parse];
        if (!parsingResult) {
            NSError *parsingError = [xmlParser parserError];
            if ([self.delegate respondsToSelector:@selector(didHaveParsingError:)])
                [self.delegate didHaveParsingError:[parsingError localizedDescription]];
        }
        // If we've parsed successfully check if we encountered any errors
        else {
            if (self->_errorFlagged) {
                self->_error = [self->_error stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([self->_error isEqualToString:ErrorAuthentication]) 
                    [self.delegate didHaveAuthenticationError:self->_error];
                else if ([self->_error isEqualToString:ErrorToolboxLoad]) {
                    if ([self.delegate respondsToSelector:@selector(didHaveToolboxUnderLoadError:)])
                        [self.delegate didHaveToolboxUnderLoadError:self->_error];
                }
                else {
                    if ([self.delegate respondsToSelector:@selector(didHaveGenericError:)])
                        [self.delegate didHaveGenericError:self->_error];
                }
                return nil;
            }
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(didHaveXMLConstructionError)]) {
            [self.delegate didHaveXMLConstructionError];
        }
        return nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishRetrieveUsage)]) 
        [self.delegate didFinishRetrieveUsage];
    
    iiFeed *feed = [[iiFeed alloc] initFeedWith:self->_accountInfo volumeUsage:self->_volumeUsage connection:self->_connection];
    if (feed == nil)
        return nil;
    
    self->_lastRetrieved = [NSDate date];
    [self->_cache setObject:feed forKey:kCacheFeedKey];
    
    return [self->_cache objectForKey:kCacheFeedKey];
}

- (void)resetCache {
    [self->_cache removeObjectForKey:kCacheFeedKey];
    self->_lastRetrieved = nil;
}

- (BOOL)hasRetrievedUsage {
    iiFeed *feed = [[iiFeed alloc] initFeedWith:self->_accountInfo volumeUsage:self->_volumeUsage connection:self->_connection];
    return (feed == nil) ? NO : YES;
}

#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (self->_errorFlagged)
        return;
    
     
    if ([elementName isEqualToString:XMLElementError]) {
        self->_errorFlagged = YES;
        return;
    }
    
    if ([elementName isEqualToString:XMLElementAccountInfo]) {
        self->_accountInfo = [[iiAccountInfo alloc] init];        
        self->_stateTracking = XMLElementAccountInfo;
        
        return;
    }
    
    if ([elementName isEqualToString:XMLElementVolumeUsage] && self->_volumeUsage == nil) {
        self->_volumeUsage = [[iiVolumeUsage alloc] init];
        self->_stateTracking = kStateVolumeUsage;
        return;
    }
    
    if ([self->_stateTracking isEqualToString:kStateVolumeUsage]) {
        if ([elementName isEqualToString:XMLElementQuotaReset]) {
            self->_volumeUsage.quotaReset = [[iiQuotaReset alloc] init];
            self->_secondTierStateTracking = XMLElementQuotaReset;
            
            return;
        }
        if ([elementName isEqualToString:XMLElementExpectedTrafficTypes]) {
            self->_volumeUsage.expectedTrafficList = [[NSMutableArray alloc] init];
            self->_secondTierStateTracking = XMLElementExpectedTrafficTypes;
            
            return;
        }
        if ([elementName isEqualToString:XMLElementVolumeUsage]) {
            self->_volumeUsage.volumeUsageBreakdown = [[NSMutableArray alloc] init];
            self->_secondTierStateTracking = XMLElementVolumeUsage;
        }
        
        
        
        
        if ([self->_secondTierStateTracking isEqualToString:XMLElementExpectedTrafficTypes]) {
            if ([elementName isEqualToString:XMLElementType]) {
                self->_trafficUnit = nil;
                self->_trafficUnit = [[iiTraffic alloc] init];
                self->_trafficUnit.trafficType = [[attributeDict objectForKey:XMLElementClassification] iiTrafficTypeFromString];
                NSString *trafficString = [attributeDict objectForKey:XMLElementUsed];
                self->_trafficUnit.used = [trafficString longLongValue];
            }
        }
        if ([self->_secondTierStateTracking isEqualToString:XMLElementVolumeUsage]) {
            if ([elementName isEqualToString:XMLElementDayHour]) {
                self->_usagePeriod = nil;
                self->_usagePeriod = [[iiUsagePeriod alloc] init];
                
                self->_usagePeriod.period = [attributeDict objectForKey:XMLElementPeriod];
                self->_usagePeriod.usageUnitList = [[NSMutableArray alloc] init];
            }
            if ([elementName isEqualToString:XMLElementUsage]) {                
                self->_usageUnit = nil;
                self->_usageUnit = [[iiUsageUnit alloc] init];
                
                self->_usageUnit.trafficType = [[attributeDict objectForKey:XMLElementType] iiTrafficTypeFromString];
            }
        }
    }
    
    if ([elementName isEqualToString:XMLElementConnections]) {
        self->_stateTracking = XMLElementConnections;
        self->_connection = [[iiConnection alloc] init];
        self->_connection.ipList = [[NSMutableArray alloc] init];
        return;
    }
    
    if ([self->_stateTracking isEqualToString:XMLElementConnections]) {
        if ([elementName isEqualToString:XMLElementIp]) {
            self->_ip = [[iiIpAddress alloc] init];
            self->_ip.connectedSinceDate = [attributeDict objectForKey:XMLElementOnSince];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self->_currentStringValue) {
        self->_currentStringValue = [[NSMutableString alloc] init];
    }
    
    [self->_currentStringValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (self->_errorFlagged && self->_error != nil)
        return;
    
    if (self->_errorFlagged && [elementName isEqualToString:XMLElementError])
        self->_error = self->_currentStringValue;
    
    
    NSString *currentStringValue = [self->_currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self->_currentStringValue = nil;
    
    
    if ([self->_stateTracking isEqualToString:XMLElementAccountInfo]) {
        if ([elementName isEqualToString:XMLElementPlan])
            self->_accountInfo.plan = currentStringValue;
        
        if ([elementName isEqualToString:XMLElementProduct])
            self->_accountInfo.product = currentStringValue;
        
        return;
    }
    
    if ([self->_stateTracking isEqualToString:kStateVolumeUsage]) {
        if ([elementName isEqualToString:XMLElementOffpeakStart])
            self->_volumeUsage.offPeakStart = currentStringValue;
        if ([elementName isEqualToString:XMLElementOffpeakEnd]) 
            self->_volumeUsage.offPeakEnd = currentStringValue;
        
        if ([self->_secondTierStateTracking isEqualToString:XMLElementQuotaReset]) {
            if ([elementName isEqualToString:XMLElementAnniversary])       
                self->_volumeUsage.quotaReset.anniversary = [currentStringValue  integerValue];
            
            if ([elementName isEqualToString:XMLElementDaysSoFar])
                self->_volumeUsage.quotaReset.daysSoFar = [currentStringValue integerValue];
            
            if ([elementName isEqualToString:XMLElementDaysRemaining])
                self->_volumeUsage.quotaReset.daysRemaining = [currentStringValue integerValue];
            
            if ([elementName isEqualToString:XMLElementQuotaReset])
                self->_secondTierStateTracking = @"";
            
            return;
        }
        
        if ([self->_secondTierStateTracking isEqualToString:XMLElementExpectedTrafficTypes]) {
            if ([elementName isEqualToString:XMLElementQuotaAllocation])
                self->_trafficUnit.quota = [currentStringValue integerValue];
            if ([elementName isEqualToString:XMLElementIsShaped])
                self->_trafficUnit.isShaped = ([currentStringValue isEqualToString:@"true"]) ? YES : NO;
            
            if ([elementName isEqualToString:XMLElementType])
                [self->_volumeUsage.expectedTrafficList addObject:self->_trafficUnit];
            
            if ([elementName isEqualToString:XMLElementExpectedTrafficTypes]) 
                self->_secondTierStateTracking = @"";
            
            return;
        }
        
        if ([self->_secondTierStateTracking isEqualToString:XMLElementVolumeUsage]) {
            if ([elementName isEqualToString:XMLElementUsage]) {
                self->_usageUnit.bytes = [currentStringValue longLongValue];
                [self->_usagePeriod.usageUnitList addObject:self->_usageUnit];
            }
            
            if ([elementName isEqualToString:XMLElementDayHour]) {
                [self->_volumeUsage.volumeUsageBreakdown addObject:self->_usagePeriod];
            }
        }
        
        
        if ([self->_secondTierStateTracking isEqualToString:@""] && [elementName isEqualToString:XMLElementVolumeUsage])
            self->_stateTracking = @"";
        
        return;
    }
    
    if ([self->_stateTracking isEqualToString:XMLElementConnections]) {
        if ([elementName isEqualToString:XMLElementIp]) {
            self->_ip.ipAddress = currentStringValue;
            [self->_connection.ipList addObject:self->_ip];
        }
    }
    
    if ([self->_stateTracking isEqualToString:elementName]) {
        self->_stateTracking = @"";
    }
}


@end
