//
//  UIImage+InternalMethod.m
//  EUExBaiduMap
//
//  Created by AppCan on 13-1-18.
//  Copyright (c) 2013年 AppCan. All rights reserved.
//

#import "UIImage+InternalMethod.h"
BOOL isRetina = FALSE;
@implementation UIImage (InternalMethod)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
	CGSize rotatedSize = self.size;
	if (isRetina) {
		rotatedSize.width *= 2;
		rotatedSize.height *= 2;
	}
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	CGContextRotateCTM(bitmap, M_PI);
	CGContextScaleCTM(bitmap, -1.0, 1.0);
	CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
@end
