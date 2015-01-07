//
//  BMKAnnotationView+WebCache.m
//  SDWebImage
//
//  Created by Olivier Poitrey on 14/03/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "BMKAnnotationView+WebCache.h"
#import "MyAnnotationPoint.h"
@implementation BMKAnnotationView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    self.image = placeholder;
    
    if (url)
    {
        [manager downloadWithURL:url delegate:self ];
    }

}
- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    NSLog(@"图片下载成功");
    if (  [self.annotation isKindOfClass:[MyAnnotationPoint class]]) {
        CGSize size = ((MyAnnotationPoint *)self.annotation).imgSize;
        UIGraphicsBeginImageContext(size); 
        CGRect thumbnailRect = CGRectMake(0, 0, size.width, size.height);
        [image drawInRect:thumbnailRect];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        self.image = newImage;
    }else {
        self.image = image;
    }
    [self setNeedsDisplay];
}

@end
