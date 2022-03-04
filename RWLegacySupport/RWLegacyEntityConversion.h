//
//  RWLegacyEntityConversion.h
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RWCharacterConverter : NSObject

+ (NSString*)encodeUnicodeForHTML:(NSString*)html skipTags:(BOOL)skipTags;

@end

@interface NSString (EntityConversion)

- (NSString *)convertToEntities;

@end
