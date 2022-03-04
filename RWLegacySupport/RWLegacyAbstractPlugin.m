//
//  RWLegacyAbstractPlugin.m
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import "RWLegacyAbstractPlugin.h"

@implementation RWAbstractPlugin (LegacySupport)

- (NSMutableDictionary *)contentOnlySubpageWithHTML:(NSString *)content name:(NSString *)name
{
    NSMutableDictionary *substitutionsInfo = [NSMutableDictionary dictionary];
    [substitutionsInfo setValue:content forKey:@"content"];
    
    NSMutableDictionary *contentInfo = [NSMutableDictionary dictionary];
    [contentInfo setValue:name forKey:@"name"];
    [contentInfo setObject:substitutionsInfo forKey:@"substitutions"];
    return contentInfo;
}

- (NSMutableDictionary *)contentOnlySubpageWithEntireHTML:(NSString *)content name:(NSString *)name
{
    NSMutableDictionary *contentInfo = [NSMutableDictionary dictionary];
    [contentInfo setValue:name forKey:@"name"];
    [contentInfo setValue:content forKey:@"entirehtml"];
    return contentInfo;
}

- (NSMutableDictionary *)contentOnlySubpageWithData:(NSData *)content name:(NSString *)name
{
    NSMutableDictionary *contentInfo = [NSMutableDictionary dictionary];
    [contentInfo setValue:name forKey:@"name"];
    [contentInfo setValue:content forKey:@"contentdata"];
    return contentInfo;
}

@end
