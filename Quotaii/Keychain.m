//
//  Keychain.m
//  OpenStack
//
//  Based on KeychainWrapper in BadassVNC by Dylan Barrie
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Keychain.h"
#import <Security/Security.h>

@implementation Keychain

+ (NSString *)appName {    
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
	// Attempt to find a name for this application
	NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (!appName) {
		appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];	
	}
    return appName;
}

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key {
	if (string == nil || key == nil) {
		return NO;
	}
    
    key = [NSString stringWithFormat:@"%@ - %@", [Keychain appName], key];
    
	// First check if it already exists, by creating a search dictionary and requesting that 
    // nothing be returned, and performing the search anyway.
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	[existsQueryDictionary setObject:(__bridge_transfer id)kSecClassGenericPassword forKey:(__bridge_transfer id)kSecClass];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(__bridge_transfer id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(__bridge_transfer id)kSecAttrAccount];
    
	OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)existsQueryDictionary, NULL);
	if (res == errSecItemNotFound) {
		if (string != nil) {
			NSMutableDictionary *addDict = existsQueryDictionary;
			[addDict setObject:data forKey:(__bridge_transfer id)kSecValueData];
            
			res = SecItemAdd((__bridge CFDictionaryRef)addDict, NULL);
			NSAssert1(res == errSecSuccess, @"Recieved %d from SecItemAdd!", res);
		}
	} else if (res == errSecSuccess) {
		// Modify an existing one
		// Actually pull it now of the keychain at this point.
		NSDictionary *attributeDict = [NSDictionary dictionaryWithObject:data forKey:(__bridge_transfer id)kSecValueData];
        
		res = SecItemUpdate((__bridge_retained CFDictionaryRef)existsQueryDictionary, (__bridge CFDictionaryRef)attributeDict);
		NSAssert1(res == errSecSuccess, @"SecItemUpdated returned %d!", res);
		
	} else {
		NSAssert1(NO, @"Received %d from SecItemCopyMatching!", res);
	}
	
	return YES;
}

+ (NSString *)getStringForKey:(NSString *)key {
    
    key = [NSString stringWithFormat:@"%@ - %@", [Keychain appName], key];
    
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	
	[existsQueryDictionary setObject:(__bridge_transfer id)kSecClassGenericPassword forKey:(__bridge_transfer id)kSecClass];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(__bridge_transfer id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(__bridge_transfer id)kSecAttrAccount];
	
	// We want the data back!
	NSData *data = nil;
	CFDataRef attributes;
    
	[existsQueryDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
	
	OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)existsQueryDictionary, (CFTypeRef *)attributes);
    data = (__bridge_transfer NSData*) attributes;
	if (res == errSecSuccess) {
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		return string;
	} else {
		NSAssert1(res == errSecItemNotFound, @"SecItemCopyMatching returned %d!", res);
	}		
	
	return nil;
}

@end