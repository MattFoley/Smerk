//
//  SMKViewController.m
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "SMKViewController.h"
#import "SMKDetectionCamera.h"
#import "GPUImageGammaFilter.h"

@interface SMKViewController ()

@property SMKDetectionCamera *detector;

@property (strong, nonatomic) UIView * faceFeatureTrackingView;
@property (strong, nonatomic) UIView * faceMetaTrackingView;

@end

@implementation SMKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFaceTrackingViews];
    
    self.detector = [[SMKDetectionCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    [self.detector setOutputImageOrientation:UIInterfaceOrientationPortrait];
    [self.detector addTarget:self.cameraView];
    
    self.cameraView.fillMode = kGPUImageFillModePreserveAspectRatio;
    
    NSInteger outputHeight = [[self.detector.captureSession.outputs[0] videoSettings][@"Height"] integerValue];
    NSInteger outputWidth = [[self.detector.captureSession.outputs[0] videoSettings][@"Width"] integerValue];
    
    if (UIInterfaceOrientationIsPortrait(self.detector.outputImageOrientation)) {
        NSInteger temp = outputWidth;
        outputWidth = outputHeight;
        outputHeight = temp;
    }

    // Use self.view because self.cameraView is not resized at this point (if 3.5" device)
    CGFloat previewHeight = self.view.frame.size.height;
    CGFloat previewWidth = self.view.frame.size.width;
    
    /*
     * Calculate the scale and offset of the preview vs the camera
     */
    CGFloat scale;
    CGAffineTransform frameTransform;
    switch (self.cameraView.fillMode) {
        case kGPUImageFillModePreserveAspectRatio:
            scale = MIN(previewWidth / outputWidth, previewHeight / outputHeight);
            frameTransform = CGAffineTransformMakeScale(scale, scale);
            frameTransform = CGAffineTransformTranslate(frameTransform, -(outputWidth * scale - previewWidth)/2, -(outputHeight * scale - previewHeight)/2 );
            break;
        case kGPUImageFillModePreserveAspectRatioAndFill:
            scale = MAX(previewWidth / outputWidth, previewHeight / outputHeight);
            frameTransform = CGAffineTransformMakeScale(scale, scale);
            frameTransform = CGAffineTransformTranslate(frameTransform, -(outputWidth * scale - previewWidth)/2, -(outputHeight * scale - previewHeight)/2 );
            break;
        case kGPUImageFillModeStretch:
            frameTransform = CGAffineTransformMakeScale(previewWidth / outputWidth, previewHeight / outputHeight);
            break;
    }
    
    CGAffineTransform RotationCompensationMatrix;
    if (UIInterfaceOrientationIsPortrait(self.detector.outputImageOrientation)) {
        // Interchange x & y
        RotationCompensationMatrix = CGAffineTransformMake(0, 1, 1, 0, 0, 0);
    }
    else {
        RotationCompensationMatrix = CGAffineTransformIdentity;
    }

 
    [self.detector beginDetecting:kFaceFeatures | kMachineAndFaceMetaData
                        codeTypes:@[AVMetadataObjectTypeQRCode]
               withDetectionBlock:^(SMKDetectionOptions detectionType, NSArray *detectedObjects, CGRect clapOrRectZero) {
                   if (detectedObjects.count) {
                       NSLog(@"Detected objects %@", detectedObjects);
                   }
                   
                   if (detectionType & kFaceFeatures) {
                       if (!detectedObjects.count) {
                           self.faceFeatureTrackingView.hidden = YES;
                       }
                       else {
                           CIFaceFeature * feature = detectedObjects[0];
                           CGRect face = feature.bounds;
 
                           face = CGRectApplyAffineTransform(face, RotationCompensationMatrix);
                           face = CGRectApplyAffineTransform(face, frameTransform);
                           self.faceFeatureTrackingView.frame = face;
                           self.faceFeatureTrackingView.hidden = NO;
                       }
                   }
                   else if (detectionType | kFaceMetaData) {
                       if (!detectedObjects.count) {
                           self.faceMetaTrackingView.hidden = YES;
                       }
                       else {
                           AVMetadataFaceObject * metadataObject = detectedObjects[0];
                           
                           CGRect face = metadataObject.bounds;
                           
                           // Flip the Y coordinate to compensate for coordinate difference
                           face.origin.y = 1.0 - face.origin.y - face.size.height;
                           
                           // Transform to go from texels, which are relative to the image size to pixel values
                           CGAffineTransform metaTexelToPixelTransform = CGAffineTransformMakeScale(outputWidth, outputHeight);
                           face = CGRectApplyAffineTransform(face, RotationCompensationMatrix);
                           face = CGRectApplyAffineTransform(face, metaTexelToPixelTransform);
                           face = CGRectApplyAffineTransform(face, frameTransform);
                           self.faceMetaTrackingView.frame = face;
                           self.faceMetaTrackingView.hidden = NO;
                       }
                   }
               }];
    
    [self.detector startCameraCapture];
}

- (void)setupFaceTrackingViews {
    self.faceFeatureTrackingView = [[UIView alloc] initWithFrame:CGRectZero];
    self.faceFeatureTrackingView.layer.borderColor = [[UIColor redColor] CGColor];
    self.faceFeatureTrackingView.layer.borderWidth = 3;
    self.faceFeatureTrackingView.backgroundColor = [UIColor clearColor];
    self.faceFeatureTrackingView.hidden = YES;
    
    self.faceMetaTrackingView = [[UIView alloc] initWithFrame:CGRectZero];
    self.faceMetaTrackingView.layer.borderColor = [[UIColor greenColor] CGColor];
    self.faceMetaTrackingView.layer.borderWidth = 3;
    self.faceMetaTrackingView.backgroundColor = [UIColor clearColor];
    self.faceMetaTrackingView.hidden = YES;
    
    [self.cameraView addSubview:self.faceMetaTrackingView];
    [self.cameraView addSubview:self.faceFeatureTrackingView];
}

- (IBAction)rotateCamera:(id)sender
{
    [self.detector rotateCamera];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
