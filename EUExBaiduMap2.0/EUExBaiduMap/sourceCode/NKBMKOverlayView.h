//
//  NKBMKOverlayView.h
//  AppCan
//
//  Created by AppCan on 13-1-28.
//
//

#import "BMKOverlayView.h"
#import "BMKOverlayPathView.h"
@interface NKBMKOverlayView : BMKOverlayPathView{
    CGColorRef * colors;
    UIImageView * imageView;
    NSString  * urlString;
}

+ (void)setStrId:(NSString *)Id;
+ (NSString *)getStrId;
+ (void)setUrlString:(NSString *)url;
+ (NSString *)getUrlString;
@end
