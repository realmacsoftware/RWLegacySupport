//
//  RWLegacyAbstractPlugin.h
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import <RWKit/RWKit.h>

@interface RWAbstractPlugin (LegacySupport)

- (NSMutableDictionary *)contentOnlySubpageWithHTML:(NSString *)content name:(NSString *)name;
- (NSMutableDictionary *)contentOnlySubpageWithData:(NSData *)content name:(NSString *)name;
- (NSMutableDictionary *)contentOnlySubpageWithEntireHTML:(NSString *)content name:(NSString *)name;

@end
