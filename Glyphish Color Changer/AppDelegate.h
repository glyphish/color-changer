//
//  AppDelegate.h
//  Glyphish Color Changer
//
//  Created by Rudd Fawcett on 7/15/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GCCImportView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

/**
 *  The main window.
 */
@property (assign)            IBOutlet NSWindow      *window;

/**
 *  The import view to drag the icons.
 */
@property (strong, nonatomic) IBOutlet GCCImportView *importView;

@end
