//
//  RWLegacyNSString.h
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Encoding)

- (NSString*)stringEscapedForHTMLElementText;
- (NSString*)stringEscapedForHTMLAttribute;

- (NSString*)stringEscapedForXMLElementText;
- (NSString*)stringEscapedForXMLElementTextWithCharactersToLeaveUnescaped:(NSArray *)characters;

- (NSString*)stringEscapedForFilename;
- (NSString*)stringEscapedForLowercaseFilename;
- (NSString*)stringEscapedForFriendlyFilename;
- (NSString*)stringEscapedForLowercaseFriendlyFilename;
- (NSString*)stringEscapedForMacFriendlyFilename;
- (NSString*)stringEscapedForInclusionInSingleQuotedPHPString;

@end

NS_ASSUME_NONNULL_END


