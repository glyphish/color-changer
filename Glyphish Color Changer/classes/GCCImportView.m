//
//  GCCImportView.m
//  Glyphish Color Changer
//
//  Created by Rudd Fawcett on 7/15/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import "GCCImportView.h"


@implementation GCCImportView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationGeneric;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    NSArray *draggedFiles = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CGPreferenceOverwriteOriginal]) {
        [self processFiles:draggedFiles toFolder:NULL];
    }
    else {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        panel.allowsMultipleSelection = NO;
        panel.canChooseDirectories = YES;
        panel.canChooseFiles = NO;
        
        NSString *iconTitle = [[[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType] count] == 1 ? @"icon" : @"icons";
        
        panel.title = [NSString stringWithFormat:@"Pick a folder to export your new %@.", iconTitle];
        
        long result = [panel runModal];
        
        if (result == NSOKButton) {
            NSString *folderPath = panel.URL.path;
            if (!folderPath) {
                // Paranoid check for folder path. Don't want to overwrite originals by mistake
                NSLog(@"Error - expected to have a folder path here");
                return;
            }
            
            [self processFiles:draggedFiles toFolder:folderPath];
        }
    }

}

/**
 *  Handles the files dragged onto the view.  Pass NULL as destination to overwrite original file path.
 *
 *  @param draggedFiles The array of paths for the dragged files.
 *  @param folderPath   The path to the output folder.
 */
-(void)processFiles:(NSArray *)draggedFiles toFolder:(NSString *)folderPath {
    for (NSString *path in draggedFiles) {
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            NSError *error;
            
            NSArray *foldercontents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
            if (!error) {
                for (NSString *eachIcon in foldercontents) {
                    NSString *iconPath = [path stringByAppendingPathComponent:eachIcon];
                    
                    if ([[iconPath pathExtension] isEqualToString:@"png"]) {
                        [self handlePNG:iconPath folderPath:folderPath];
                        
                    }
                    else if ([[path pathExtension] isEqualToString:@"svg"]) {
                        [self handleSVG:iconPath folderPath:folderPath];
                    }
                }
            }
        }
        
        if ([[path pathExtension] isEqualToString:@"png"]) {
            [self handlePNG:path folderPath:folderPath];

        }
        else if ([[path pathExtension] isEqualToString:@"svg"]) {
            [self handleSVG:path folderPath:folderPath];
        }
    }
}

/**
 *  Change the color of the PNG dragged onto the view.
 *
 *  @param path       The path to the PNG image.
 *  @param folderPath The path to the output folder.
 */
- (void)handlePNG:(NSString *)path folderPath:(NSString *)folderPath {
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:path];
    NSImage *originalImage = [[NSImage alloc] initWithData:imageData];
    
    NSImage *maskedImage = [NSImage maskedImage:originalImage withNSColor:self.colorWell.color];
    
    NSString *destination = path;
    if (folderPath) {
        destination = [folderPath stringByAppendingPathComponent:[path lastPathComponent]];
    }
    
    [self savePNGImage:maskedImage atPath:destination];
}

/**
 *  Change the color of the SVG dragged onto the view.
 *
 *  @param path       The path to the SVG.
 *  @param folderPath The path to the output folder.
 */
- (void)handleSVG:(NSString *)path folderPath:(NSString *)folderPath {
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([[NSFileManager defaultManager] copyItemAtPath:path toPath:[folderPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil]) {
        NSString *replacementString = [NSString stringWithFormat:@" fill=\"%@\"",[self hexadecimalValueOfAnNSColor:self.colorWell.color]];
        
        contents = [contents stringByReplacingOccurrencesOfString:@" fill=\"#000000\"" withString:replacementString];
        
        [[NSFileManager defaultManager] createFileAtPath:[folderPath stringByAppendingPathComponent:[path lastPathComponent]] contents:[contents dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        
        // Testing:
        
        /*
         NSData *data = [NSData dataWithContentsOfFile:[folderPath stringByAppendingPathComponent:[path lastPathComponent]]];
         NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         NSLog(@"%@",string);
         */
    }
}

/**
 *  Method to save the PNG image.
 *
 *  @param image The altered PNG image to save.
 *  @param path  The path to save the PNG.
 */
- (void)savePNGImage:(NSImage *)image atPath:(NSString *)path {
    CGImageRef cgImageRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *newRepresentation = [[NSBitmapImageRep alloc] initWithCGImage:cgImageRef];
    newRepresentation.size = CGSizeMake(image.size.width/2, image.size.height/2);
    
    NSData *png = [newRepresentation representationUsingType:NSPNGFileType properties:nil];
    if ([png writeToFile:path atomically:YES]) {
        return;
    };
}

/**
 *  Returns the hexadecimal value of a color.  Taken from
 *  https://developer.apple.com/library/mac/qa/qa1576/_index.html.
 *
 *  @param color The NSColor to convert to a hex string.
 *
 *  @return The hex string.
 */
- (NSString *)hexadecimalValueOfAnNSColor:(NSColor *)color {
    double redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;
    
    //Convert the NSColor to the RGB color space before we can access its components
    NSColor *convertedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    if (convertedColor) {
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue=redFloatValue * 255.99999f;
        greenIntValue=greenFloatValue * 255.99999f;
        blueIntValue=blueFloatValue * 255.99999f;
        
        // Convert the numbers to hex strings
        redHexValue=[NSString stringWithFormat:@"%02x", redIntValue];
        greenHexValue=[NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue=[NSString stringWithFormat:@"%02x", blueIntValue];
        
        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    
    return nil;
}

@end
