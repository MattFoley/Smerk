//
//  SMKDetectorView+BufferHandler.m
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "SMKDetectorView+BufferHandler.h"

@implementation SMKDetectorView (BufferHandler)
/*
#pragma mark - Face Detection Delegate Callback
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	if (!faceThinking && self.autoFaces.isOn) {
		CFAllocatorRef allocator = CFAllocatorGetDefault();
		CMSampleBufferRef sbufCopyOut;
		CMSampleBufferCreateCopy(allocator, sampleBuffer, &sbufCopyOut);
		[self performSelectorInBackground:@selector(grepFacesForSampleBuffer:) withObject:CFBridgingRelease(sbufCopyOut)];
	}
}

- (void)grepFacesForSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	faceThinking = TRUE;
    
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
	if (attachments) {
		CFRelease(attachments);
    }
    
	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    
	int exifOrientation;
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT          = 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT         = 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
	BOOL isUsingFrontFacingCamera = FALSE;
	AVCaptureDevicePosition currentCameraPosition = [self.videoCamera cameraPosition];
    
	if (currentCameraPosition != AVCaptureDevicePositionBack) {
		isUsingFrontFacingCamera = TRUE;
	}
    
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
            
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
            
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
            
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    
	lastFeaturesOutput = [[faceDetector featuresInImage:convertedImage options:imageOptions]mutableCopy];
    
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	_clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false ); //originIsTopLeft == false
    
    
	[self GPUVCWillOutputFeaturesforClap:self.clap andOrientation:curDeviceOrientation fromImage:convertedImage];
	faceThinking = FALSE;
}

#define oId @"originatingFeatureID"
#define tId @"toFeatureID"

- (void)GPUVCWillOutputFeaturesforClap:(CGRect)clap andOrientation:(UIDeviceOrientation)curDeviceOrientation fromImage:(CIImage *)image {
	NSArray *sublayers = [NSArray arrayWithArray:[_previewView.layer sublayers]];
	NSInteger sublayersCount = [sublayers count], featuresCount = [lastFeaturesOutput count];
	__block NSInteger currentFeature = 0, currentSublayer = 0;
    
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
	if (featuresCount == 0 || !detectFaces) {
		idleCount++;
		if (idleCount > 2) {
			for (CALayer *layer in sublayers) {
				NSRange range = [[layer name] rangeOfString:@"FaceLayer"
				                                    options:NSCaseInsensitiveSearch];
				DLog(@"%@", [layer name]);
				if (range.location != NSNotFound && [layer name] != NULL) {
					[layer setHidden:YES];
					[layer removeFromSuperlayer];
				}
			}
		}
		[CATransaction commit];
		return; // early bail.
	}
	else {
		idleCount = 0;
	}
    
	dispatch_async(dispatch_get_main_queue(), ^{
	    DLog(@"Did receive array");
        
        
	    CGRect previewBox = self.view.frame;
	    for (CIFaceFeature *faceFeature in lastFeaturesOutput) {
	        // find the correct position for the square layer within the previewLayer
	        // the feature box originates in the bottom left of the video frame.
	        // (Bottom right if mirroring is turned on)
	        DLog(@"%@", NSStringFromCGRect([faceFeature bounds]));
            
	        //Update face bounds for iOS Coordinate System
	        CGRect faceRect = [faceFeature bounds];
            
	        // flip preview width and height
	        CGFloat temp = faceRect.size.width;
	        faceRect.size.width = faceRect.size.height;
	        faceRect.size.height = temp;
	        temp = faceRect.origin.x;
	        faceRect.origin.x = faceRect.origin.y;
	        faceRect.origin.y = temp;
	        // scale coordinates so they fit in the preview box, which may be scaled
	        CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
	        CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
	        faceRect.size.width *= widthScaleBy;
	        faceRect.size.height *= heightScaleBy;
	        faceRect.origin.x *= widthScaleBy;
	        faceRect.origin.y *= heightScaleBy;
            
	        //enbiggen
	        faceRect.size.width = faceRect.size.width * 1.2;
	        faceRect.size.height = faceRect.size.height * 1.2;
	        faceRect.origin.x = faceRect.origin.x;
	        faceRect.origin.y = faceRect.origin.y - faceRect.size.height * .3;
            
	        faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            
            
	        DLog(@"%@", NSStringFromCGRect(faceRect));
	        CALayer *featureLayer = nil;
            
	        // re-use an existing layer if possible
	        while (!featureLayer && (currentSublayer < sublayersCount)) {
	            CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
                
	            NSRange range = [[currentLayer name] rangeOfString:@"FaceLayer"
	                                                       options:NSCaseInsensitiveSearch];
	            // DLog(@"%@",[currentLayer name]);
	            if (range.location != NSNotFound && [currentLayer name] != NULL) {
	                featureLayer = currentLayer;
	                [currentLayer setHidden:NO];
				}
			}
            
	        // create a new one if necessary
	        if (!featureLayer) {
	            featureLayer = [CALayer new];
                
	            objc_setAssociatedObject(featureLayer, (const void *)0x314, [NSNumber numberWithInt:0], OBJC_ASSOCIATION_RETAIN);
	            objc_setAssociatedObject(featureLayer, (const void *)0x315, [NSNumber numberWithInt:0], OBJC_ASSOCIATION_RETAIN);
	            [featureLayer setContents:(id)[square CGImage]];
	            [featureLayer setContentsGravity:kCAGravityResizeAspect];
	            [featureLayer setName:@"FaceLayer0"];
                
	            [_previewView.layer addSublayer:featureLayer];
			}
            
	        [featureLayer setFrame:faceRect];
            
	        int orientationDegrees = 0;
	        switch (curDeviceOrientation) {
				case UIDeviceOrientationPortrait:
					orientationDegrees = 90;
					break;
                    
				case UIDeviceOrientationPortraitUpsideDown:
					orientationDegrees = 270;
					break;
                    
				case UIDeviceOrientationLandscapeLeft:
					orientationDegrees = 90;
					break;
                    
				case UIDeviceOrientationLandscapeRight:
					orientationDegrees = -90;
					break;
                    
				case UIDeviceOrientationFaceUp:
					orientationDegrees = 90;
					break;
                    
				case UIDeviceOrientationFaceDown:
					orientationDegrees = 90;
					break;
                    
				default:
					break; // leave the layer in its last known orientation
			}
            
	        if ([faceFeature faceRotation] < 0 && !UIDeviceOrientationIsLandscape(curDeviceOrientation) && [faceFeature faceRotation] > -3) {
	            if (self.videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
	                [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(+orientationDegrees) + [faceFeature faceRotation])];
	                featureLayer.position = CGPointMake((featureLayer.position.x - self.view.frame.size.width) * -1.0, featureLayer.position.y);
				}
	            else {
	                [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-orientationDegrees) - [faceFeature faceRotation])];
				}
			}
	        else if (([faceFeature faceRotation] > 0 && [faceFeature faceRotation] < 3) || UIDeviceOrientationIsLandscape(curDeviceOrientation)) {
	            if (self.videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
	                if (!UIDeviceOrientationIsLandscape(curDeviceOrientation)) {
	                    [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-orientationDegrees) + [faceFeature faceRotation])];
	                    featureLayer.position = CGPointMake((featureLayer.position.x - self.view.frame.size.width) * -1.0, featureLayer.position.y);
					}
	                else {
	                    [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(+orientationDegrees) + [faceFeature faceRotation])];
	                    featureLayer.position = CGPointMake((featureLayer.position.x - self.view.frame.size.width) * -1.0, featureLayer.position.y);
					}
				}
	            else {
	                [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(+orientationDegrees) - [faceFeature faceRotation])];
				}
			}
            
            
            
	        currentFeature++;
		}
        
	    [CATransaction commit];
	});
    
	DLog(@"%i", curDeviceOrientation);
}
*/

@end
