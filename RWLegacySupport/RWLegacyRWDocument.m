//
//  RWLegacyRWDocument.m
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import "RWLegacyRWDocument.h"

id <RWDocumentProtocol> RWDocumentForPlugin(RWAbstractPlugin *plugin) {
    return plugin.document;
}
