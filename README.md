Smerk
=====

Smerk is designed to make implementing either Face Detection or QR Code/Bar Code/Machine Readable Code detection incredibly simple.

Smerk is built with a dependency on [GPUImage](https://github.com/BradLarson/GPUImage) for ease of setting up camera capture and display, as well as for the many options for camera and display customization afforded by GPUImage. Many thanks to Brad Larson for all the work he's done on that library!

SMKDetectionCamera is a subclass of GPUImageStillCamera, giving you the ability to use all of the features Brad Larson has put into GPUImageVideoCamera and GPUImageStillCamera such filters, image capture, raw data output/input, and much more.

###Sample Project

The included sample project gives an example of how to setup the detector to detect Faces, Face Metadata Objects, or Machine Readable Code objects such as QR Codes, and UPC Codes. Detection data is logged to the console, as I thought UI for signifying detection of some object would be entirely custom for any given implementation. 

<b>You can find examples of the more complicated CIFaceFeature UI implementations in [GPUImage's Filter Showcase example](https://github.com/BradLarson/GPUImage/tree/master/examples/iOS/FilterShowcase), or in [Apple's SquareCam Demo](https://developer.apple.com/library/ios/samplecode/SquareCam/Introduction/Intro.html).</b>


###Smerk Documentation

Full documentation can be found inside SMKDetectionCamera.h.

####Smerk Implementation

Here's the four lines it takes to set up camera capture, detection, and display using the block method:

    self.detector = [[SMKDetectionCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    [self.detector beginDetecting:kFaceFeatures | kMachineAndFaceMetaData
                        codeTypes:@[AVMetadataObjectTypeQRCode]
               withDetectionBlock:^(SMKDetectionOptions detectionType, NSArray *detectedObjects, CGRect clapOrRectZero) {
                   NSLog(@"Detected objects %@", detectedObjects);
               }];
  
    [self.detector startCameraCapture];
    
    [self.detector addTarget:self.cameraView];
    
    
    
Smerk offers the ability to use a delegate protocol as well, simply implement the callback methods for your detection choices and use the following method to begin detection:

    [self.detector beginDetecting:kFaceFeatures | kMachineAndFaceMetaData 
                     withDelegate:self
                        codeTypes:@[AVMetadataObjectTypeQRCode]];

####Smerk Detection Types

    kFaceFeatures
  
  This option will output CIFaceFeatures in order to detect angle of head, bounds of head, position of mouth, eyes and nose, as well as smiles and blinks.
    
    kFaceMetaData
    
  This option will output AVMetadataFaceObjects in order to detect bounds, yaw and roll of faces. Used in 3D Facial Tracking examples at WWDC 2012.
    
    kMachineReadableMetaData
  
  This option will output AVMetadataMachineReadableCodeObject in order to read objects such as QR Codes, Bar Codes and UPC Codes. All types supported by AVMetadataMachineReadableCodeObject are supported by Smerk.
    
    kMachineAndFaceMetaData 
  This option will output both AVMetadataMachineReadableCodeObject and AVMetadataFaceObjects. AVCaptureSession will not allow two AVCaptureMetadataOutput objects to be added to one AVCaptureSession, and so we combine both detection types into on object using this option.
  
#####Combination Detection
  
  These options can be combined like so to provide multiple levels of detection simultaneously with one SMKDetectionCamera object:
  
     SMKDetectionOptions detectionOptions = (kFaceMetaData | kFaceFeatures);

                             
####SMKDetectionDelegate

Depending on the type of detection you would like to do, you will implement one or multiple of these four methods:

     - (void)detectorWillOuputFaceFeatures:(NSArray *)faceFeatureObjects inClap:(CGRect)clap;

     - (void)detectorWillOuputFaceMetadata:(NSArray *)faceMetadataObjects;

     - (void)detectorWillOuputMachineReadableMetadata:(NSArray *)machineReadableMetadataObjects;

     - (void)detectorWillOuputMachineAndFaceMetadata:(NSArray *)mixedMetadataObjects;
                             
They are described in detail in the documentation SMKDetectionCamera.h

####NOTES: Depending on the options used, this library supports at minimum iOS 5 and up for CIFaceFeature detection, iOS 6 and up for AVMetadataFaceObject detection and iOS 7 and up for AVMetadataMachineReadableCodeObject detection.

####WARNING: Do not supply both kFaceMetaData and kMachineReadableMetaData, instead use kMachineAndFaceMetaData.
    
