//
//  NKBMKOverlayView.m
//  AppCan
//
//  Created by AppCan on 13-1-28.
//
//

#import "NKBMKOverlayView.h"
#import "UIImageView+WebCache.h"
@implementation NKBMKOverlayView

NSString * strId;
NSString * urlString;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
+ (void)setStrId:(NSString *)Id{
    if (strId!=Id) {
        [strId release];
        strId = [Id retain];
    }
}
+ (NSString *)getStrId{
    return strId;
}
+ (void)setUrlString:(NSString *)url{
    if (urlString!=url) {
        [urlString release];
        urlString = [url retain];
    }
}
+ (NSString *)getUrlString{
    return urlString;
}
- (id)initWithOverlay:(id <BMKOverlay>)overlay
{
    if (self = [super initWithOverlay:overlay]) {
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:rect];
        [self addSubview:imageView];
    }else{
        [imageView setFrame:rect];
    }
    NSString * urlStr = [NKBMKOverlayView getUrlString];
    if ([urlStr hasPrefix:@"http"]) {
        NSURL * url = [NSURL URLWithString:urlStr];
        [imageView setImageWithURL:url placeholderImage:imageView.image];
    }else {
        UIImage  * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:urlStr]];
        CGSize size = CGSizeMake(40, 40);
        UIGraphicsBeginImageContext(size);
        CGRect thumbnailRect = CGRectMake(0, 0, size.width, size.height);
        [image drawInRect:thumbnailRect];
        UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
        [imageView setImage:newImage];
    }
}
-(void)dealloc{
//    if (urlString) {
//        self.urlString = nil;
//    }
    if (imageView) {
        [imageView release];
        imageView = nil;
    }
    [super dealloc];
}
@end
