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

@end

@implementation SMKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detector = [[SMKDetectionCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    [self.detector beginDetecting:kFaceFeatures | kMachineAndFaceMetaData
                        codeTypes:@[AVMetadataObjectTypeQRCode]
               withDetectionBlock:^(SMKDetectionOptions detectionType, NSArray *detectedObjects, CGRect clapOrRectZero) {
                   NSLog(@"Detected objects %@", detectedObjects);
               }];
    
    [self.detector setOutputImageOrientation:UIInterfaceOrientationPortrait];
    [self.detector startCameraCapture];
    [self.detector addTarget:self.cameraView];
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
