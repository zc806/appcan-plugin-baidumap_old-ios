//
//  MyAnnotationPoint.m
//  BDMapPluginApp
//
//  Created by AppCan on 12-6-1.
//  Copyright (c) 2012年 AppCan. All rights reserved.
//

#import "MyAnnotationPoint.h"

@implementation MyAnnotationPoint
@synthesize pointId;
@synthesize  annotationImageUrl;
@synthesize imgSize;
-(void)dealloc{
    if (self.annotationImageUrl) {
        self.annotationImageUrl = nil;
    }
    [super dealloc];
}
@end
