//
//  RWLegacyNSString.m
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import "RWLegacyNSString.h"

#import <AppKit/AppKit.h>

#pragma mark - NSCharacterSet

@interface NSCharacterSet (SafeFilenameCharacterSet)
+ (NSCharacterSet*)safeFilenameCharacterSet;
@end

@implementation NSCharacterSet (SafeFilenameCharacterSet)

+ (NSCharacterSet*)safeFilenameCharacterSet
{
    return [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_."];
}

@end

#pragma mark - NSString

static NSRange nilRange = { NSNotFound, 0 };

@implementation NSString (Encoding)

- (NSString*)stringEscapedForHTMLElementText { return [self stringEscapedForXMLElementText]; }
- (NSString*)stringEscapedForHTMLAttribute { return [self stringEscapedForXMLElementText]; }

- (NSString*)stringEscapedForXMLElementText
{
    return [self stringEscapedForXMLElementTextWithCharactersToLeaveUnescaped:nil];
}

- (NSString*)stringEscapedForXMLElementTextWithCharactersToLeaveUnescaped:(NSArray *)characters
{
    static NSDictionary* predefinedXMLEntityReferencesMapping = nil;
    
    if (predefinedXMLEntityReferencesMapping == nil) {
        // Note that we use the numeric entities here rather than the named ones for maximum compatibility with IE.  (IE tends to choke on named entities when they're e.g. inside attributes)
        predefinedXMLEntityReferencesMapping = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 @"&#60;", @"<",
                                                 @"&#62;", @">",
                                                 @"&#38;", @"&",
                                                 @"&#39;", @"'",
                                                 @"&#34;", @"\"",
                                                 nil];
    }
    
    NSMutableString* illegalCharacters = [NSMutableString string];
    
    NSEnumerator* e = [predefinedXMLEntityReferencesMapping keyEnumerator];
    NSString* illegalCharacter = nil;
    while ((illegalCharacter = [e nextObject])) {
        if ([characters containsObject:illegalCharacter]) continue;
        [illegalCharacters appendString:illegalCharacter];
    }
    
    NSCharacterSet *predefinedXMLEntityReferencesCharacterSet = [NSCharacterSet characterSetWithCharactersInString:illegalCharacters];
    
    NSString* escapedString = self;
    NSRange rangeOfUnescapedCharacters = NSMakeRange(0, [self length]);
    
    for (;;){
        const NSRange rangeOfXMLCharacterToEscape = [escapedString rangeOfCharacterFromSet:predefinedXMLEntityReferencesCharacterSet options:NSLiteralSearch range:rangeOfUnescapedCharacters];
        if(NSEqualRanges(rangeOfXMLCharacterToEscape, nilRange))
        {
            if(escapedString == self) return [self copy];
            else return escapedString;
        }
        
        if (escapedString == self) escapedString = [self mutableCopy];
        NSMutableString* mutableEscapedString = (NSMutableString*) escapedString;
        
        NSString* illegalCharacter = [escapedString substringWithRange:rangeOfXMLCharacterToEscape];
        NSString* replacementEntity = [predefinedXMLEntityReferencesMapping objectForKey:illegalCharacter];
        [mutableEscapedString replaceCharactersInRange:rangeOfXMLCharacterToEscape withString:replacementEntity];
        
        const NSUInteger searchIndex = rangeOfXMLCharacterToEscape.location+[replacementEntity length];
        rangeOfUnescapedCharacters = NSMakeRange(searchIndex, [escapedString length]-searchIndex);
    }
}

- (NSString*)stringEscapedForFilename
{
    static NSCharacterSet* cachedUnsafeFilenameCharacterSet = nil;
    if(cachedUnsafeFilenameCharacterSet == nil) cachedUnsafeFilenameCharacterSet = [[NSCharacterSet safeFilenameCharacterSet] invertedSet];

    NSString* escapedString = self;
    NSRange rangeOfUnescapedCharacters = NSMakeRange(0, [self length]);
    
    for (;;){
        const NSRange rangeOfBadCharacter = [escapedString rangeOfCharacterFromSet:cachedUnsafeFilenameCharacterSet options:0 range:rangeOfUnescapedCharacters];
        
        if (NSEqualRanges(rangeOfBadCharacter, nilRange)) return escapedString;
        
        if (escapedString == self) escapedString = [self mutableCopy];
        NSMutableString* mutableEscapedString = (NSMutableString*) escapedString;
        
        const unichar badCharacter = [escapedString characterAtIndex:rangeOfBadCharacter.location];
        NSString* badCharacterReplacement = badCharacter == ' ' ? @"-" : [NSString stringWithFormat:@"%04X", badCharacter];
        [mutableEscapedString replaceCharactersInRange:rangeOfBadCharacter withString:badCharacterReplacement];
        
        const NSUInteger searchIndex = rangeOfBadCharacter.location+[badCharacterReplacement length];
        rangeOfUnescapedCharacters = NSMakeRange(searchIndex, [escapedString length]-searchIndex);
    }
}

- (NSString*)stringEscapedForLowercaseFilename
{
    return [[self stringEscapedForFilename] lowercaseString];
}

- (NSString*)stringEscapedForFriendlyFilename
{
    static NSCharacterSet* cachedUnsafeFilenameCharacterSet = nil;
    if(cachedUnsafeFilenameCharacterSet == nil) cachedUnsafeFilenameCharacterSet = [[NSCharacterSet safeFilenameCharacterSet] invertedSet];
    
    NSString* escapedString = self;
    NSRange rangeOfUnescapedCharacters = NSMakeRange(0, [self length]);
    
    for(;;){
        const NSRange rangeOfBadCharacter = [escapedString rangeOfCharacterFromSet:cachedUnsafeFilenameCharacterSet options:0 range:rangeOfUnescapedCharacters];
        
        if(NSEqualRanges(rangeOfBadCharacter, nilRange)) return escapedString;
        
        if(escapedString == self) escapedString = [self mutableCopy];
        NSMutableString* mutableEscapedString = (NSMutableString*) escapedString;
        
        const unichar badCharacter = [escapedString characterAtIndex:rangeOfBadCharacter.location];
        
        // Unintentionally not initialised for performance (oooo, aaah)
        NSString* badCharacterReplacement;
        
        switch(badCharacter)
        {
            case '\'':
                badCharacterReplacement = @"";
                break;
            default:
                badCharacterReplacement = @"-";
                break;
        }
        [mutableEscapedString replaceCharactersInRange:rangeOfBadCharacter withString:badCharacterReplacement];
        
        const NSUInteger searchIndex = rangeOfBadCharacter.location+[badCharacterReplacement length];
        rangeOfUnescapedCharacters = NSMakeRange(searchIndex, [escapedString length]-searchIndex);
    }
}

- (NSString*)stringEscapedForMacFriendlyFilename
{
    static NSCharacterSet* cachedUnsafeFilenameCharacterSet = nil;
    if(cachedUnsafeFilenameCharacterSet == nil) cachedUnsafeFilenameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@":/"];
    
    NSString* escapedString = self;
    NSRange rangeOfUnescapedCharacters = NSMakeRange(0, [self length]);
    
    for(;;){
        const NSRange rangeOfBadCharacter = [escapedString rangeOfCharacterFromSet:cachedUnsafeFilenameCharacterSet options:0 range:rangeOfUnescapedCharacters];
        
        if(NSEqualRanges(rangeOfBadCharacter, nilRange)) return escapedString;
        
        if(escapedString == self) escapedString = [self mutableCopy];
        NSMutableString* mutableEscapedString = (NSMutableString*) escapedString;
        
        static NSString* const badCharacterReplacement = @"-";
        [mutableEscapedString replaceCharactersInRange:rangeOfBadCharacter withString:badCharacterReplacement];
        
        const NSUInteger searchIndex = rangeOfBadCharacter.location+[badCharacterReplacement length];
        rangeOfUnescapedCharacters = NSMakeRange(searchIndex, [escapedString length]-searchIndex);
    }
}

- (NSString*)stringEscapedForLowercaseFriendlyFilename
{
    return [[self stringEscapedForFriendlyFilename] lowercaseString];
}

- (NSString*)stringEscapedForInclusionInSingleQuotedPHPString
{
    static NSCharacterSet* cachedQuotesAndBackslashCharacterSet = nil;
    if(cachedQuotesAndBackslashCharacterSet == nil) cachedQuotesAndBackslashCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\\'"];
    
    NSString* escapedString = self;
    NSRange rangeOfUnescapedCharacters = NSMakeRange(0, [self length]);
    
    for (;;){
        const NSRange rangeOfBadCharacter = [escapedString rangeOfCharacterFromSet:cachedQuotesAndBackslashCharacterSet options:0 range:rangeOfUnescapedCharacters];
        
        if (NSEqualRanges(rangeOfBadCharacter, nilRange)){
            if (escapedString == self) return [self copy];
            else return escapedString;
        }
        
        if (escapedString == self) escapedString = [self mutableCopy];
        NSMutableString* mutableEscapedString = (NSMutableString*) escapedString;
        
        NSString* quotedBadCharacters = [@"\\" stringByAppendingString:[escapedString substringWithRange:rangeOfBadCharacter]];
        [mutableEscapedString replaceCharactersInRange:rangeOfBadCharacter withString:quotedBadCharacters];
        
        const NSUInteger searchIndex = rangeOfBadCharacter.location+[quotedBadCharacters length];
        rangeOfUnescapedCharacters = NSMakeRange(searchIndex, [escapedString length]-searchIndex);
    }
}

@end

