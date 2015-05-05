//
//  CMPatternLockPathView.m
//  PatternLock
//
//  Created by Xinling on 14-2-17.
//  Copyright (c) 2014年 Xinling All rights reserved.
//

#import "CMPatternLockPathView.h"

CGFloat const KLineWidth = 2;

@implementation CMPatternLockPathView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.finishedPatternPoint = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
//        self.lineColor = KLineColor;
        self.lineWidth = KLineWidth;
        self.currentPoint = CGPointMake(-1, -1);
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    for ( NSInteger i = 0 ; i < self.finishedPatternPoint.count; i++ )
    {
        CGPoint point = CGPointZero;
        [self.finishedPatternPoint[i] getValue:&point];
        if ( i > 0 )
        {
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        else
        {
            CGContextMoveToPoint(context, point.x, point.y);
        }
    }
    if ( !CGPointEqualToPoint(self.currentPoint, CGPointMake(-1, -1)) )
    {
        CGContextAddLineToPoint(context, self.currentPoint.x, self.currentPoint.y);
    }
    CGContextStrokePath(context);
}

@end
