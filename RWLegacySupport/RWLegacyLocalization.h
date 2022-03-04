//
//  RWLegacyLocalization.h
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#ifndef RMStringMacros_h
#define RMStringMacros_h

#define RMSelfBundle() ([NSBundle bundleForClass:[self class]])

static inline NSString* RMLocalizedStringForKeyInBundle(NSString *key, NSBundle *bundle)
{
    NSString *string = [bundle localizedStringForKey:key value:@"" table:nil];
    
    if ([string isEqualToString:key])
    {
        string = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
    }
    
    return string;
}

#define RMLocalizedStringInSelfBundle(key) (RMLocalizedStringForKeyInBundle(key, RMSelfBundle()))

#endif /* RMStringMacros_h */
