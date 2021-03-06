//
//  BBKitFunctions.m
//  BBFrameworks
//
//  Created by William Towe on 1/24/16.
//  Copyright © 2016 Bion Bilateral, LLC. All rights reserved.
//

#import "BBKitFunctions.h"

CGSize BBCGSizeAdjustedForMainScreenScale(CGSize size) {
    return BBCGSizeAdjustedForScreenScale(size, nil);
}
#if (TARGET_OS_IPHONE)
CGSize BBCGSizeAdjustedForScreenScale(CGSize size, UIScreen * _Nullable screen) {
    if (screen == nil) {
        screen = [UIScreen mainScreen];
    }

    return CGSizeMake(size.width * screen.scale, size.height * screen.scale);
}
#else
CGSize BBCGSizeAdjustedForScreenScale(CGSize size, NSScreen * _Nullable screen) {
    if (screen == nil) {
        screen = [NSScreen mainScreen];
    }
    
    return CGSizeMake(size.width * screen.backingScaleFactor, size.height * screen.backingScaleFactor);
}
#endif
