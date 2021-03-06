//
//  GCCImportView.h
//  Glyphish Color Changer
//
//  Created by Rudd Fawcett on 7/15/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NSImage+ImageMask.h"
#import "NSString+Additions.h"

#define CGPreferenceOverwriteOriginal @"CGPreferenceOverwriteOriginal"
#define CGPreferenceColor @"CGPreferenceColor"

@interface GCCImportView : NSView <NSDraggingDestination>

/**
 *  The colorwell to get the color to mask the icons.
 */
@property (strong, nonatomic) IBOutlet NSColorWell *colorWell;

@end
