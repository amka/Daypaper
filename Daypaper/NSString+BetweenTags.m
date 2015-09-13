//
//  NSString+BetweenTags.m
//  
//
//  Created by Andrey M on 13.09.15.
//
//

#import "NSString+BetweenTags.h"

@implementation NSString (BetweenTags)


- (NSString *)stringBetweenString:(NSString *)start andString:(NSString *)end {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString *result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

@end
