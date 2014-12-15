//
//  NSString+Additions.m
//  Glyphish Color Changer
//
//  Created by Rudd Fawcett on 12/15/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

// http://stackoverflow.com/questions/4002360/get-string-between-two-other-strings-in-objc
- (NSString *) stringBetweenString:(NSString *)start andString:(NSString *)end {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

@end
