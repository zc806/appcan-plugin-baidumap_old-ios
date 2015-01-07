//
//  KYBubbleView.h
//  DrugRef
//
//  Created by AppCan on 12-6-6.
//  Copyright (c) 2012年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "makeNextDelegate.h"
@interface KYBubbleView : UIView {
    NSDictionary *_infoDict;
    UILabel         *titleLabel;
    UILabel         *detailLabel;
    UIButton        *rightButton;
    NSUInteger      index;
    id<makeNextDelegate>delgate;
}

@property (nonatomic, retain) NSDictionary * infoDict;
@property NSUInteger index;
@property(nonatomic,assign) id<makeNextDelegate> delgate;
- (BOOL)showFromRect:(CGRect)rect;
- (void)setStyle1;
- (void)setStyle2;
- (void)setStyle3;
@end
