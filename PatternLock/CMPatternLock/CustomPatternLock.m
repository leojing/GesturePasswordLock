//
//  CMPatternLock.m
//  PatternLock
//
//  Created by Xinling on 14-2-17.
//  Copyright (c) 2014年 Xinling All rights reserved.
//

#import "CustomPatternLock.h"
#import "CMPatternLockPathView.h"
#import "CMPatternLockCirleView.h"

NSInteger const KDefalutPatternRow = 3;
NSInteger const KDefalutPatternCol = 3;

@interface CustomPatternLock () {
    BOOL success; // 判断手势密码是否正确
}

@property (nonatomic, strong) CMPatternLockCirleView* backgroundCirlesView;
@property (nonatomic, strong) CMPatternLockCirleView* foregroundCirlesView;
@property (nonatomic, strong) CMPatternLockPathView* pathView;

@end

@implementation CustomPatternLock
- (void)setPatterns:(NSMutableArray *)patterns
{
    _patterns = patterns;
    for ( NSNumber* selectedIndex in _patterns )
    {
        [self.backgroundCirlesView setCirclehighlighteded:YES index:[selectedIndex integerValue]];
        [self.foregroundCirlesView setCirclehighlighteded:YES index:[selectedIndex integerValue]];
    }
}

- (id)initWithRow:(NSInteger)patternRow col:(NSInteger)patternCol
{
    self = [super init];
    if ( self )
    {
        self.contentInset = UIEdgeInsetsZero;
        
        _patternRow = patternRow;
        _patternCol = patternCol;
        
        self.patterns = [[NSMutableArray alloc] init];
        
        //先画圆
        self.backgroundCirlesView = [[CMPatternLockCirleView alloc] initWithRow:patternRow col:patternCol];
        [self.backgroundCirlesView setCircleImage:[UIImage imageNamed:@"gesPw_normal"] highlightedImage:nil];
        [self.backgroundCirlesView setCircleSize:CGSizeMake(65, 65) cornerRadius:65/2];
        [self addSubview:self.backgroundCirlesView];
        
        //画线
        self.pathView = [[CMPatternLockPathView alloc] init];
        [self addSubview:self.pathView];
        
        self.foregroundCirlesView = [[CMPatternLockCirleView alloc] initWithRow:patternRow col:patternCol];
        [self.foregroundCirlesView setCircleSize:CGSizeMake(65, 65) cornerRadius:65/2];
        [self addSubview:self.foregroundCirlesView];
        
        [self addGestureRecognizer];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect newframe = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    self.backgroundCirlesView.frame = newframe;
    self.pathView.frame = newframe;
    self.foregroundCirlesView.frame = CGRectInset(self.backgroundCirlesView.frame, 0, 0);
}


#pragma mark - path
- ( NSInteger )cirleForPoint:(CGPoint)point
{
    return [self.backgroundCirlesView indexForPoint:point containhighlighteded:NO];
}

- (BOOL)addSelectPatternWithTouchPoint:(CGPoint)point
{
    //判断是否在cirle中
    NSInteger circleIndex = [self cirleForPoint:point];
    if ( -1 == circleIndex )
    {
        return NO;
    }
    
    CGPoint centerPoint = [self.backgroundCirlesView circlecenterWithIndex:circleIndex];
    if ( -1 == centerPoint.x || -1 == centerPoint.y )
    {
        return NO;
    }
    
    NSValue* finishedPointValue = [NSValue valueWithCGPoint:centerPoint];
    if ( ![self.pathView.finishedPatternPoint containsObject:finishedPointValue] )
    {
        [self.pathView.finishedPatternPoint addObject:finishedPointValue];
        [self.patterns addObject:@(circleIndex)];
    }
    [self.backgroundCirlesView setCirclehighlighteded:YES index:circleIndex];
    [self.foregroundCirlesView setCirclehighlighteded:YES index:circleIndex];
    return YES;
}

- (void)clearPattern
{
    [self.pathView.finishedPatternPoint removeAllObjects];
    [self.patterns removeAllObjects];
    self.pathView.currentPoint = CGPointMake(-1, -1);
    [self.backgroundCirlesView clear];
    [self.foregroundCirlesView clear];
    [self.pathView setNeedsDisplay];
}

#pragma - Gesture Handler
- (void)addGestureRecognizer
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestured:)];
    [self addGestureRecognizer:pan];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestured:)];
    [self addGestureRecognizer:tap];
}

- (void)tapGestured:(UITapGestureRecognizer *)gesture
{
    //清除所有
    [self clearPattern];
}


- (void)gestured:(UIGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.backgroundCirlesView];
    switch ( gesture.state )
    {
        case UIGestureRecognizerStateBegan:
        {
            //清除所有
            [self clearPattern];
            
            //判断是否在cirle中
            [self addSelectPatternWithTouchPoint:point];
            
            [self.pathView setLineColor:[UIColor colorWithRed:254/255.f green:200/255.f blue:61/255.0f alpha:0.7]];
            [self.foregroundCirlesView setCircleImage:nil highlightedImage:[UIImage imageNamed:@"gesPw_succeed"]];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if ( self.patterns > 0 )
            {
                if ( ![self addSelectPatternWithTouchPoint:point] )
                {
                    self.pathView.currentPoint = point;
                }
                else
                {
                    self.pathView.currentPoint = CGPointMake(-1, -1);
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if ( self.patterns > 0 )
            {
                if ( ![self addSelectPatternWithTouchPoint:point] )
                {
                    self.pathView.currentPoint = CGPointMake(-1, -1);
                }
            }
            if ( self.delegate )
            {
                // 将选中的手势编码转化为3x3的矩阵的坐标
                NSMutableArray *pathCoordinateArray = [[NSMutableArray alloc] initWithCapacity:100];
                for (NSNumber* selectedIndex in _patterns) {
                    NSInteger selectedNum = [selectedIndex integerValue];
                    CGPoint point = CGPointMake(selectedNum/3, selectedNum%3);
                    [pathCoordinateArray addObject:[NSValue valueWithCGPoint:point]];
                }
                
                success = [self.delegate patternLock:self didEndWithPattern:self.patterns];
                if (success) {
                    [self.pathView setLineColor:[UIColor colorWithRed:254/255.f green:200/255.f blue:61/255.0f alpha:0.7]];
                    
                    if (pathCoordinateArray.count > 0) {
                        // 最后一个位置没有箭头
                        NSValue *pointVale = [pathCoordinateArray objectAtIndex:pathCoordinateArray.count-1];
                        CGPoint lastPoint = [pointVale CGPointValue];
                        [self.foregroundCirlesView setCircleImage:nil highlightedImage:[UIImage imageNamed:@"gesPw_succeed"] index:lastPoint.x*3+lastPoint.y];
                    }
                    
                    // 基准图片 0度
                    UIImage *im_success_0 = [UIImage imageNamed:@"gesPw_succeed_0"];
                    UIImage *im_success_26 = [UIImage imageNamed:@"gesPw_succeed_26"];
                    UIImage *im_success_45 = [UIImage imageNamed:@"gesPw_succeed_45"];
                    UIImage *im_success_63 = [UIImage imageNamed:@"gesPw_succeed_63"];
                    UIImage *rotatedImage;
                    if (self.isShowArrow) {
                        // 判断前后两个选中的点处于什么相对方向，给相应的图片配对应方向的箭头
                        for (NSInteger i = 0; i < pathCoordinateArray.count-1; i ++) {
                            NSValue *pointVale = [pathCoordinateArray objectAtIndex:i];
                            CGPoint startPoint = [pointVale CGPointValue];
                            pointVale = [pathCoordinateArray objectAtIndex:i+1];
                            CGPoint endPoint = [pointVale CGPointValue];
                            // 斜率为 不存在
                            if ((endPoint.x-startPoint.x)==0) {
                                if (endPoint.y > startPoint.y) { // 右方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_0 CGImage] scale:1 orientation:UIImageOrientationRight];
                                } else { // 左方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_0 CGImage] scale:1 orientation:UIImageOrientationLeft];
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 1
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==1) {
                                if (endPoint.x > startPoint.x) { // 右下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_45 CGImage] scale:1 orientation:UIImageOrientationDownMirrored];
                                } else { // 左上方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_45 CGImage] scale:1 orientation:UIImageOrientationUpMirrored];
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 -1
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==-1) {
                                if (endPoint.x > startPoint.x) { // 左下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_45 CGImage] scale:1 orientation:UIImageOrientationDown];
                                } else { // 右上方
                                    rotatedImage = im_success_45;
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 0
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==0) {
                                if (endPoint.x > startPoint.x) { // 下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_0 CGImage] scale:1 orientation:UIImageOrientationDown];
                                } else { // 上方
                                    rotatedImage = im_success_0;
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 0.5
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==0.5) {
                                if (endPoint.x > startPoint.x) { // 右下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_26 CGImage] scale:1 orientation:UIImageOrientationDownMirrored];
                                } else { // 左上方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_26 CGImage] scale:1 orientation:UIImageOrientationUpMirrored];
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 -0.5
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==-0.5) {
                                if (endPoint.x > startPoint.x) { // 左下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_26 CGImage] scale:1 orientation:UIImageOrientationDown];
                                } else { // 右上方
                                    rotatedImage = im_success_26;
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 2
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==2) {
                                if (endPoint.x > startPoint.x) { // 右下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_63 CGImage] scale:1 orientation:UIImageOrientationDownMirrored];
                                } else { // 左上方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_63 CGImage] scale:1 orientation:UIImageOrientationUpMirrored];
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 -2
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==-2) {
                                if (endPoint.x > startPoint.x) { // 左下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_success_63 CGImage] scale:1 orientation:UIImageOrientationDown];
                                } else { // 右上方
                                    rotatedImage = im_success_63;
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            else {
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:[UIImage imageNamed:@"gesPw_succeed"] index:startPoint.x*3+startPoint.y];
                            }
                        }
                    } else {
                        [self.foregroundCirlesView setCircleImage:nil highlightedImage:[UIImage imageNamed:@"gesPw_succeed"]];
                    }
                } else {
                    [self.pathView setLineColor:[UIColor colorWithRed:251/255.f green:15/255.f blue:29/255.0f alpha:0.7]];
                    
                    if (pathCoordinateArray.count > 0) {
                        // 最后一个位置没有箭头
                        NSValue *pointVale = [pathCoordinateArray objectAtIndex:pathCoordinateArray.count-1];
                        CGPoint lastPoint = [pointVale CGPointValue];
                        [self.foregroundCirlesView setCircleImage:nil highlightedImage:[UIImage imageNamed:@"gesPw_fail"] index:lastPoint.x*3+lastPoint.y];
                    }
                    
                    // 基准图片 0度
                    UIImage *im_fail_0 = [UIImage imageNamed:@"gesPw_fail_0"];
                    UIImage *im_fail_26 = [UIImage imageNamed:@"gesPw_fail_26"];
                    UIImage *im_fail_45 = [UIImage imageNamed:@"gesPw_fail_45"];
                    UIImage *im_fail_63 = [UIImage imageNamed:@"gesPw_fail_63"];
                    UIImage *rotatedImage;
                    if (self.isShowArrow) {
                        // 判断前后两个选中的点处于什么相对方向，给相应的图片配对应方向的箭头
                        for (NSInteger i = 0; i < pathCoordinateArray.count-1; i ++) {
                            NSValue *pointVale = [pathCoordinateArray objectAtIndex:i];
                            CGPoint startPoint = [pointVale CGPointValue];
                            pointVale = [pathCoordinateArray objectAtIndex:i+1];
                            CGPoint endPoint = [pointVale CGPointValue];
                            // 斜率为 不存在
                            if ((endPoint.x-startPoint.x)==0) {
                                if (endPoint.y > startPoint.y) { // 右方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_0 CGImage] scale:1 orientation:UIImageOrientationRight];
                                } else { // 左方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_0 CGImage] scale:1 orientation:UIImageOrientationLeft];
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 1
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==1) {
                                if (endPoint.x > startPoint.x) { // 右下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_45 CGImage] scale:1 orientation:UIImageOrientationDownMirrored];
                                } else { // 左上方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_45 CGImage] scale:1 orientation:UIImageOrientationUpMirrored];
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 -1
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==-1) {
                                if (endPoint.x > startPoint.x) { // 左下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_45 CGImage] scale:1 orientation:UIImageOrientationDown];
                                } else { // 右上方
                                    rotatedImage = im_fail_45;
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 0
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==0) {
                                if (endPoint.x > startPoint.x) { // 下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_0 CGImage] scale:1 orientation:UIImageOrientationDown];
                                } else { // 上方
                                    rotatedImage = im_fail_0;
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 0.5
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==0.5) {
                                if (endPoint.x > startPoint.x) { // 右下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_26 CGImage] scale:1 orientation:UIImageOrientationDownMirrored];
                                } else { // 左上方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_26 CGImage] scale:1 orientation:UIImageOrientationUpMirrored];
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 -0.5
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==-0.5) {
                                if (endPoint.x > startPoint.x) { // 左下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_26 CGImage] scale:1 orientation:UIImageOrientationDown];
                                } else { // 右上方
                                    rotatedImage = im_fail_26;
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 2
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==2) {
                                if (endPoint.x > startPoint.x) { // 右下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_63 CGImage] scale:1 orientation:UIImageOrientationDownMirrored];
                                } else { // 左上方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_63 CGImage] scale:1 orientation:UIImageOrientationUpMirrored];
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            // 斜率为 -2
                            else if ((endPoint.y-startPoint.y)/(endPoint.x-startPoint.x)==-2) {
                                if (endPoint.x > startPoint.x) { // 左下方
                                    rotatedImage = [UIImage imageWithCGImage:[im_fail_26 CGImage] scale:1 orientation:UIImageOrientationDown];
                                } else { // 右上方
                                    rotatedImage = im_fail_26;
                                }
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:rotatedImage index:startPoint.x*3+startPoint.y];
                            }
                            else {
                                [self.foregroundCirlesView setCircleImage:nil highlightedImage:[UIImage imageNamed:@"gesPw_fail"] index:startPoint.x*3+startPoint.y];
                            }
                        }
                    } else {
                        [self.foregroundCirlesView setCircleImage:nil highlightedImage:[UIImage imageNamed:@"gesPw_fail"]];
                    }
                }
            }
            break;
        }
        default:
            break;
    }
    [self.pathView setNeedsDisplay];
}

@end
