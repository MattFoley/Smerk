//
//  SMKDetectorView_private.h
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "GPUImage.h"
#import "SMKDetectorView.h"
#import "SMKMacros.h"

#import <objc/runtime.h>

@interface SMKDetectorView ()

@property (nonatomic, strong) IBOutlet UIView *cameraLayer;

@property GPUImageVideoCamera *videoCamera;

@property CIDetector *faceDetector;
@property NSArray *latestFeatures;

@property CGRect clap;
@property NSInteger idleCount;
@property BOOL processingInProgress;

@end


