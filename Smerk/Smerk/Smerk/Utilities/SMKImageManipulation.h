//
//  SMKImageManipulation.h
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMKImageManipulation : NSObject

static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);
static CGContextRef CreateCGBitmapContextForSize(CGSize size);

@end
