//
//  NBMKPolylineView.m
//  AppCan
//
//  Created by hongbao.cui on 13-1-5.
//
//

#import "NBMKPolylineView.h"

@implementation NBMKPolylineView
@synthesize stringId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)dealloc{
    if (stringId) {
        self.stringId = nil;
    }
    [super dealloc];
}
@end
