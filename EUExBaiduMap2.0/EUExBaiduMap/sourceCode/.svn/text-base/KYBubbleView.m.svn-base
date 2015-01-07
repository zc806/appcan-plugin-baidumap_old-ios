//
//  KYBubbleView.m
//  DrugRef
//
//  Created by AppCan on 12-6-6.
//  Copyright (c) 2012年 AppCan. All rights reserved.
//

#import "KYBubbleView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+WebCache.h"
@implementation KYBubbleView

static const float kBorderWidth = 10.0f;
static const float kEndCapWidth = 20.0f;
static const float kMaxLabelWidth = 250.0f;

@synthesize infoDict = _infoDict;
@synthesize index;
@synthesize delgate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(UIColor *) getColor:(NSString *)hexColor
{
    unsigned int red, green, blue;
    NSRange range;
    range.length =2;
    range.location =0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    range.location =2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    range.location =4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green/255.0f)blue:(float)(blue/255.0f)alpha:1.0f];
}
//黑色
-(void)setStyle2 {
    titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [titleLabel setTextColor:[UIColor blackColor]];
    [self addSubview:titleLabel];
    
    detailLabel = [[UILabel alloc] init];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.numberOfLines = 0;
    detailLabel.font = [UIFont systemFontOfSize:14.0f];
    [detailLabel setTextColor:[UIColor grayColor]];
    [self addSubview:detailLabel];
           
    UIImage * imageNormal_0, *imageHighlighted_0;
    UIImage * imageNormal_1, *imageHighlighted_1;
    imageNormal_0 = [UIImage imageNamed:@"uexBaiduMap/style_1-left.png"];
    imageHighlighted_0 = [UIImage imageNamed:@"uexBaiduMap/style_0-left.png"];
    imageNormal_0 = [[self changeImage:imageNormal_0] stretchableImageWithLeftCapWidth:10 topCapHeight:13];
    imageHighlighted_0 = [[self changeImage:imageHighlighted_0] stretchableImageWithLeftCapWidth:10 topCapHeight:13];
    
    imageNormal_1 = [UIImage imageNamed:@"uexBaiduMap/style_1-right.png"];
    imageNormal_1 = [[self changeImage:imageNormal_1] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
    imageHighlighted_1 =[UIImage imageNamed:@"uexBaiduMap/style_0-right.png"];
    imageHighlighted_1 = [[self changeImage:imageHighlighted_1] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
    
    
    UIImageView * leftBgd = [[UIImageView alloc] initWithImage:imageNormal_0 highlightedImage:imageHighlighted_0];
    leftBgd.tag = 11;
    UIImageView * rightBgd = [[UIImageView alloc] initWithImage:imageNormal_1 highlightedImage:imageHighlighted_1];
    rightBgd.tag = 12;
    [self addSubview:leftBgd];
    [self sendSubviewToBack:leftBgd];
    [self addSubview:rightBgd];
    [self sendSubviewToBack:rightBgd];
    [leftBgd release];
    [rightBgd release];
}
//浅灰色
-(void)setStyle3{
    titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:titleLabel];
    
    detailLabel = [[UILabel alloc] init];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.numberOfLines = 0;
    detailLabel.font = [UIFont systemFontOfSize:14.0f];
    [detailLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:detailLabel];
    
    UIImage * imageNormal_0, *imageHighlighted_0;
    UIImage * imageNormal_1, *imageHighlighted_1;
    imageNormal_0 = [UIImage imageNamed:@"uexBaiduMap/style_2-left.png"];
    imageHighlighted_0 = [UIImage imageNamed:@"uexBaiduMap/style_3-left.png"];
    imageNormal_0 = [[self changeImage:imageNormal_0] stretchableImageWithLeftCapWidth:10 topCapHeight:13];
    imageHighlighted_0 = [[self changeImage:imageHighlighted_0] stretchableImageWithLeftCapWidth:10 topCapHeight:13];
    
    imageNormal_1 = [UIImage imageNamed:@"uexBaiduMap/style_2-right.png"];
    imageNormal_1 = [[self changeImage:imageNormal_1] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
    imageHighlighted_1 =[UIImage imageNamed:@"uexBaiduMap/style_3-right.png"];
    imageHighlighted_1 = [[self changeImage:imageHighlighted_1] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
    
    UIImageView *leftBgd = [[UIImageView alloc] initWithImage:imageNormal_0 highlightedImage:imageHighlighted_0];
    leftBgd.tag = 11;
    UIImageView *rightBgd = [[UIImageView alloc] initWithImage:imageNormal_1 highlightedImage:imageHighlighted_1];
    rightBgd.tag = 12;
    [self addSubview:leftBgd];
    [self sendSubviewToBack:leftBgd];
    [self addSubview:rightBgd];
    [self sendSubviewToBack:rightBgd];
    [leftBgd release];
    [rightBgd release];
}
-(UIImage *)changeImage:(UIImage *)image{
    CGSize size = CGSizeMake(20, 30);
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:thumbnailRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    return newImage;
}
//左边带图片，浅灰色
-(void)setStyle1{
    titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [titleLabel setTextColor:[UIColor blackColor]];
    [self addSubview:titleLabel];
    
    detailLabel = [[UILabel alloc] init];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.numberOfLines = 0;
    detailLabel.font = [UIFont systemFontOfSize:14.0f];
    [detailLabel setTextColor:[UIColor grayColor]];
    [self addSubview:detailLabel];

    CGRect rect = CGRectMake(kBorderWidth, kBorderWidth, 40, self.frame.size.height);
    rightButton = [[UIButton alloc] initWithFrame:rect];
//    [rightButton addTarget:self action:@selector(makeLineCall:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
//    rightButton.hidden = YES;
    
    UIImage * imageNormal_0, *imageHighlighted_0;
    UIImage * imageNormal_1, *imageHighlighted_1;
    

    imageNormal_0 = [UIImage imageNamed:@"uexBaiduMap/style_1-left.png"];
    imageHighlighted_0 = [UIImage imageNamed:@"uexBaiduMap/style_0-left.png"];
    imageNormal_0 = [[self changeImage:imageNormal_0] stretchableImageWithLeftCapWidth:10 topCapHeight:13];
    imageHighlighted_0 = [[self changeImage:imageHighlighted_0] stretchableImageWithLeftCapWidth:10 topCapHeight:13];

    imageNormal_1 = [UIImage imageNamed:@"uexBaiduMap/style_1-right.png"];
    imageNormal_1 = [[self changeImage:imageNormal_1] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
    imageHighlighted_1 =[UIImage imageNamed:@"uexBaiduMap/style_0-right.png"];
    imageHighlighted_1 = [[self changeImage:imageHighlighted_1] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
    
    UIImageView *leftBgd = [[UIImageView alloc] initWithImage:imageNormal_0 highlightedImage:imageHighlighted_0];
    leftBgd.tag = 11;
    UIImageView *rightBgd = [[UIImageView alloc] initWithImage:imageNormal_1 highlightedImage:imageHighlighted_1];
    rightBgd.tag = 12;
    [self addSubview:leftBgd];
    [self sendSubviewToBack:leftBgd];
    [self addSubview:rightBgd];
    [self sendSubviewToBack:rightBgd];
    [leftBgd release];
    [rightBgd release];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [titleLabel release];
    [detailLabel release];
    [rightButton release];
    [_infoDict release];
    [super dealloc];
}

- (BOOL)showFromRect:(CGRect)rect {
    if (self.infoDict == nil) {
        return NO;
    }
    
    titleLabel.text = [NSString stringWithFormat:@"%@", [_infoDict objectForKey:@"title"]];
    titleLabel.frame = CGRectZero;
    [titleLabel sizeToFit];
    CGRect rect1 = titleLabel.frame;
    rect1.origin = CGPointMake(rightButton.frame.size.width+kBorderWidth, kBorderWidth);
    if (rect1.size.width > kMaxLabelWidth) {
        rect1.size.width = kMaxLabelWidth;
    }
    titleLabel.frame = rect1;
    
    NSString *addr = [_infoDict objectForKey:@"conctent"];
    detailLabel.text = [NSString stringWithFormat:@"%@", addr];
    detailLabel.frame = CGRectZero;
    [detailLabel sizeToFit];
    CGRect rect2 = detailLabel.frame;
    if (rightButton) {
        rect2.origin.x = kBorderWidth+rightButton.frame.origin.x+rightButton.frame.size.width-10;
    }else{
        rect2.origin.x = kBorderWidth;
    }
    rect2.origin.y = rect1.size.height + 2*kBorderWidth;
    if (rect2.size.width > kMaxLabelWidth) {
        rect2.size.width = kMaxLabelWidth;
    }
    detailLabel.frame = rect2;
    
    CGFloat longWidth = (titleLabel.frame.size.width > detailLabel.frame.size.width) ? titleLabel.frame.size.width : detailLabel.frame.size.width;
    CGRect rect0 = self.frame;
    rect0.size.height = rect1.size.height + rect2.size.height + 2*kBorderWidth + kEndCapWidth;
    rect0.size.width = longWidth + 2*kBorderWidth+rightButton.frame.size.width;

    self.frame = rect0;
   
    CGFloat halfWidth = rect0.size.width/2;
    UIView *image = [self viewWithTag:11];
    CGRect iRect = CGRectZero;
    iRect.size.width = halfWidth;
    iRect.size.height = rect0.size.height;
    image.frame = iRect;
    image = [self viewWithTag:12];
    iRect.origin.x = halfWidth;
    image.frame = iRect;
    UIImage *placeholderImage = [UIImage imageNamed:@"uexBaiduMap/head1.png"];
    NSString *urlString = [[NSString stringWithFormat:@"%@", [_infoDict objectForKey:@"ImageUrl"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([urlString hasPrefix:@"http"]) {
        NSURL *url = [NSURL URLWithString:urlString];
        [rightButton setImageWithURL:url placeholderImage:placeholderImage];
    }else {
        NSString *urlString_ = [[NSString stringWithFormat:@"%@",urlString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        UIImage   *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:urlString_]];
        CGSize size = CGSizeMake(40, 40);
        UIGraphicsBeginImageContext(size);
        CGRect thumbnailRect = CGRectMake(0, 0, size.width, size.height);
        [image drawInRect:thumbnailRect];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        [rightButton setImage:newImage forState:UIControlStateNormal];
    }
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.delgate!=nil&&[self.delgate respondsToSelector:@selector(makeNextBtnClicked:)]) {
        NSString *strId = [_infoDict objectForKey:@"id"];
        [self.delgate makeNextBtnClicked:strId];
    }
}
//- (void)makeLineCall:(UIButton *)sender{
//    if (self.delgate!=nil&&[self.delgate respondsToSelector:@selector(makeLineCallBtnClicked:)]) {
//        [self.delgate makeLineCallBtnClicked:self.infoDict];
//    }
//}
@end
