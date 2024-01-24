//
//  JPImageProcessingSettings.m
//  JPImageresizerView
//
//  Created by aa on 2024/1/23.
//

#import "JPImageProcessingSettings.h"

@implementation JPImageProcessingSettings

- (BOOL)isNeedProcessing {
    if (self.cornerRadius > 0) return YES;
    if (self.backgroundColor) return YES;
    if (self.borderColor && self.borderWidth >= 1) return YES;
    if (self.outlineStrokeColor && (self.outlineStrokeWidth >= 1 || self.isOnlyDrawOutline)) return YES;
    if (self.padding.top >= 1 || 
        self.padding.left >= 1 ||
        self.padding.bottom >= 1 ||
        self.padding.right >= 1) return YES;
    return NO;
}

@end
