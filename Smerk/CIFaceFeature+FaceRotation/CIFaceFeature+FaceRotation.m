//
//  CIFaceFeature+FaceRotation.h
//
//  Created by Ben Harris on 4/21/12, improved by Tj Fallon 4/15/15
//

#import "CIFaceFeature+FaceRotation.h"

@implementation CIFaceFeature (FaceRotation)

- (CGFloat)faceRotation
{
    /*if (self.hasFaceAngle) {
        NSLog(@"CIDetector %f", self.faceAngle);
        return self.faceAngle;
    } else*/ if (self.hasLeftEyePosition && self.hasRightEyePosition && self.hasMouthPosition) {
        NSLog(@"Manual %f", [self manualAngleCalculation]);
        return [self manualAngleCalculation];
    } else {
        NSLog(@"None found");
        return 0;
    }
}

- (CGFloat)manualAngleCalculation
{
    CGPoint eyesMidPoint = CGPointMake((self.rightEyePosition.x + self.leftEyePosition.x) / 2,
                                       (self.rightEyePosition.y + self.leftEyePosition.y) / 2);

    CGPoint originEndPoint = CGPointMake(self.mouthPosition.x, eyesMidPoint.y);

    CGFloat angle1 = atan2f(self.mouthPosition.y - eyesMidPoint.y, self.mouthPosition.x - eyesMidPoint.x);
    CGFloat angle2 = atan2f(self.mouthPosition.y - originEndPoint.y, self.mouthPosition.x - originEndPoint.x);

    CGFloat rawAngle = angle1 - angle2;

    //if (rawAngle > 0) {
        return rawAngle;
    //} else {
      //  return rawAngle + 2;
    //}
}

@end
