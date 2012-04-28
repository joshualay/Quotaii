//
//  Lockbox.m
//
//  Created by Mark H. Granoff on 4/19/12.
//  Copyright (c) 2012 Hawk iMedia. All rights reserved.
//

#import "Lockbox.h"
#import <Security/Security.h>

#define kDelimeter @"-|-"

static NSString *_bundleId = nil;

@implementation Lockbox

+(void)initialize
{
    _bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleIdentifierKey];
}

+(NSMutableDictionary *)_service
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject: (__bridge id) kSecClassGenericPassword  forKey: (__bridge id) kSecClass];

    return dict;
}

+(NSMutableDictionary *)_query
{
    NSMutableDictionary* query = [NSMutableDictionary dictionary];
    
    [query setObject: (__bridge id) kSecClassGenericPassword forKey: (__bridge id) kSecClass];
    [query setObject: (id) kCFBooleanTrue           forKey: (__bridge id) kSecReturnData];

    return query;
}

// Prefix a bare key like "MySecureKey" with the bundle id, so the actual key stored
// is unique to this app, e.g. "com.mycompany.myapp.MySecretKey"
+(NSString *)_hierarchicalKey:(NSString *)key
{
    return [_bundleId stringByAppendingFormat:@".%@", key];
}

+(BOOL)setObject:(NSString *)obj forKey:(NSString *)key
{
    OSStatus status;
    
    NSString *hierKey = [Lockbox _hierarchicalKey:key];

    // If the object is nil, delete the item
    if (!obj) {
        NSMutableDictionary *query = [Lockbox _query];
        [query setObject:hierKey forKey:(__bridge id)kSecAttrService];
        status = SecItemDelete((__bridge CFDictionaryRef)query);
        return (status == errSecSuccess);
    }
    
    NSMutableDictionary *dict = [Lockbox _service];
    [dict setObject: hierKey forKey: (__bridge id) kSecAttrService];
    [dict setObject: [obj dataUsingEncoding:NSUTF8StringEncoding] forKey: (__bridge id) kSecValueData];
    
    status = SecItemAdd ((__bridge CFDictionaryRef) dict, NULL);
    if (status == errSecDuplicateItem) {
        NSMutableDictionary *query = [Lockbox _query];
        [query setObject:hierKey forKey:(__bridge id)kSecAttrService];
        status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status == errSecSuccess)
            status = SecItemAdd((__bridge CFDictionaryRef) dict, NULL);        
    }
    if (status != errSecSuccess)
        NSLog(@"SecItemAdd failed for key %@: %ld", hierKey, status);
    
    return (status == errSecSuccess);
}

+(NSString *)objectForKey:(NSString *)key
{
    NSString *hierKey = [Lockbox _hierarchicalKey:key];

    NSMutableDictionary *query = [Lockbox _query];
    [query setObject:hierKey forKey: (__bridge id)kSecAttrService];

    CFDataRef data = nil;
    OSStatus status =
        SecItemCopyMatching ( (__bridge CFDictionaryRef) query, (CFTypeRef*) &data );
    if (status != errSecSuccess)
        NSLog(@"SecItemCopyMatching failed for key %@: %ld", hierKey, status);
    
    if (!data)
        return nil;

    NSString *s = [[NSString alloc] 
                    initWithData: (__bridge_transfer NSData *)data 
                    encoding: NSUTF8StringEncoding];

    return s;    
}

+(BOOL)setString:(NSString *)value forKey:(NSString *)key
{
    return [Lockbox setObject:value forKey:key];
}

+(NSString *)stringForKey:(NSString *)key
{
    return [Lockbox objectForKey:key];
}

+(BOOL)setArray:(NSArray *)value forKey:(NSString *)key
{
    NSString *components = [value componentsJoinedByString:kDelimeter];
    return [Lockbox setObject:components forKey:key];
}

+(NSArray *)arrayForKey:(NSString *)key
{
    NSArray *array = nil;
    NSString *components = [Lockbox objectForKey:key];
    if (components)
        array = [NSArray arrayWithArray:[components componentsSeparatedByString:kDelimeter]];
    
    return array;
}

+(BOOL)setSet:(NSSet *)value forKey:(NSString *)key
{
    return [Lockbox setArray:[value allObjects] forKey:key];    
}

+(NSSet *)setForKey:(NSString *)key
{
    NSSet *set = nil;
    NSArray *array = [Lockbox arrayForKey:key];
    if (array)
        set = [NSSet setWithArray:array];
    
    return set;
}

@end
