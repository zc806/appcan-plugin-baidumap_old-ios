//
//  MKAnnotationView+WebCache.h
//  SDWebImage
//
//  Created by Olivier Poitrey on 14/03/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "SDWebImageCompat.h"
#import "SDWebImageManagerDelegate.h"
#import "SDWebImageManager.h"

@interface BMKAnnotationView (WebCache) <SDWebImageManagerDelegate>

/**
 * Set the imageView `image` with an `url`.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 */
- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)cancelCurrentImageLoad;

@end