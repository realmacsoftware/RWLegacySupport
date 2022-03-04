//
//  RWLegacyEntityConversion.mm
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import "RWLegacyEntityConversion.h"

#import <map>
#import <fstream>

@implementation RWCharacterConverter

typedef std::map< unsigned long, std::string > EntityMappingTable;

static const EntityMappingTable& mappingTable(){
    
    static EntityMappingTable mappingTable;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* path = [[NSBundle bundleForClass:[RWCharacterConverter class]] pathForResource:@"HTMLEncodings" ofType:@"txt"];
        if([path length] == 0) {
            return;
        }
        
        try
        {
            std::ifstream mappingFile([path fileSystemRepresentation]);
            while(mappingFile.good())
            {
                std::string dummy;
                std::string entity;
                unsigned long unicode;
                
                // expecting a line looking like "quot    =    34    ;"
                mappingFile >> entity;
                mappingFile >> dummy;
                mappingFile >> unicode;
                mappingFile >> dummy;
                
                if(!mappingFile.good()) break;
                mappingTable[unicode] = entity;
            }
        }
        catch(...)
        {
            NSLog(@"Exception reading in entity mapping table");
        }
    });
    
    return mappingTable;
}

static inline bool isHTMLTag(const unichar uc)
{
    switch(uc)
    {
        case '<':
            // Fallthrough
        case '>':
            // Fallthrough
        case '&':
            // Fallthrough
        case '"':
            // Fallthrough
        case '\'':
            return true;
        default:
            return false;
    }
}

+ (NSString*)encodeUnicodeForHTML:(NSString*)html skipTags:(BOOL)skipTags
{
    const int length = [html length];
    NSMutableString* output = [NSMutableString stringWithCapacity:length];

    int i;
    for (i = 0; i < length; i++){
    
        const unichar uc = [html characterAtIndex:i];
        
        const EntityMappingTable& mapping = mappingTable();
        const EntityMappingTable::const_iterator& it = mapping.find(uc);
        
        if ( it == mapping.end() || (skipTags && isHTMLTag(uc))){
            [output appendFormat:@"%C", (unichar)uc];
        }else{
            [output appendFormat:@"&%s;",(*it).second.c_str()];
        }
    }
    
    return output;
}

@end


@implementation NSString (EntityConversion)

- (NSString *)convertToEntities
{
    return [RWCharacterConverter encodeUnicodeForHTML:self skipTags:YES];
}

@end
