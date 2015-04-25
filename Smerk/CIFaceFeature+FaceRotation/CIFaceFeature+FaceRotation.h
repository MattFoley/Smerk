//
//  CIFaceFeature+FaceRotation.h
//
//  Created by Ben Harris on 4/21/12, improved by Tj Fallon 4/15/15
//

#import <CoreImage/CoreImage.h>

@interface CIFaceFeature (FaceRotation)

- (CGFloat)faceRotation;
- (CGFloat)manualAngleCalculation;
@end
