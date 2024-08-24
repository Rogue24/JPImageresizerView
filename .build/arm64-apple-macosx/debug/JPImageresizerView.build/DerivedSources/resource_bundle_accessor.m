#import <Foundation/Foundation.h>

NSBundle* JPImageresizerView_SWIFTPM_MODULE_BUNDLE() {
    NSURL *bundleURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"JPImageresizerView_JPImageresizerView.bundle"];

    NSBundle *preferredBundle = [NSBundle bundleWithURL:bundleURL];
    if (preferredBundle == nil) {
      return [NSBundle bundleWithPath:@"/Users/aa/Desktop/JPKit/JPImageresizerView/.build/arm64-apple-macosx/debug/JPImageresizerView_JPImageresizerView.bundle"];
    }

    return preferredBundle;
}