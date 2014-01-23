//
//  SMKImageManipulation.m
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "SMKImageManipulation.h"

@implementation SMKImageManipulation

static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size)
{
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
	CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
	CVPixelBufferRelease(pixelBuffer);
}

// create a CGImage with provided pixel buffer, pixel buffer must be uncompressed kCVPixelFormatType_32ARGB or kCVPixelFormatType_32BGRA
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut)
{
	OSStatus err = noErr;
	OSType sourcePixelFormat;
	size_t width, height, sourceRowBytes;
	void *sourceBaseAddr = NULL;
	CGBitmapInfo bitmapInfo;
	CGColorSpaceRef colorspace = NULL;
	CGDataProviderRef provider = NULL;
	CGImageRef image = NULL;
    
	sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
	if (kCVPixelFormatType_32ARGB == sourcePixelFormat) {
		bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
	} else if (kCVPixelFormatType_32BGRA == sourcePixelFormat) {
		bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	} else {
		return -95014; // only uncompressed pixel formats
    }
    
	sourceRowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer);
	width = CVPixelBufferGetWidth(pixelBuffer);
	height = CVPixelBufferGetHeight(pixelBuffer);
    
	CVPixelBufferLockBaseAddress(pixelBuffer, 0);
	sourceBaseAddr = CVPixelBufferGetBaseAddress(pixelBuffer);
    
	colorspace = CGColorSpaceCreateDeviceRGB();
    
	CVPixelBufferRetain(pixelBuffer);
	provider = CGDataProviderCreateWithData((void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
	image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
    
bail:
	if (err && image) {
		CGImageRelease(image);
		image = NULL;
	}
    
	if (provider) {
        CGDataProviderRelease(provider);
    }
	if (colorspace) {
        CGColorSpaceRelease(colorspace);
    }
    
	*imageOut = image;
    
	return err;
}

// utility used by newSquareOverlayedImageForFeatures for
static CGContextRef CreateCGBitmapContextForSize(CGSize size)
{
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	int bitmapBytesPerRow;
    
	bitmapBytesPerRow = (size.width * 4);
    
	colorSpace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate(NULL,
	                                size.width,
	                                size.height,
	                                8,       // bits per component
	                                bitmapBytesPerRow,
	                                colorSpace,
	                                (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	CGContextSetAllowsAntialiasing(context, NO);
	CGColorSpaceRelease(colorSpace);
	return context;
}


@end
