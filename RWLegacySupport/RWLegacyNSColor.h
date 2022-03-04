//
//  RWLegacyNSColor.h
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (HTMLColor)

+ (NSColor*)colorWithColorTagString:(NSString*)string colorTagMap:(NSDictionary*)colorTagMap;
+ (NSColor *)colorWithHexColorTagString:(NSString *)string colorTagMap:(NSDictionary *)colorTagMap;
+ (NSColor *)colorWithRGBAColorTagString:(NSString *)string colorTagMap:(NSDictionary *)colorTagMap;
+ (NSColor*)colorWithHTMLColorString:(NSString*)string;
- (NSString*)htmlColorString;

+ (NSColor *)colorWithRGBAColorString:(NSString *)string;
- (NSString *)rgbaColorString;

@end

