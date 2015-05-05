//
//  CMPatternLockCirleView.m
//  PatternLock
//
//  Created by Xinling on 14-2-17.
//  Copyright (c) 2014年 Xinling All rights reserved.
//

#import "CMPatternLockCirleView.h"

#define KDefaultCircleSize CGSizeMake(65, 65)

NSInteger const KCircleTagOffset = 0X10010000;

@interface CMPatternLockCirleView ()
@property (nonatomic, assign) CGFloat circleCornerRadius;
@property (nonatomic, assign) CGSize circleSize;

@property (nonatomic, strong) UIColor* circleColor;
@property (nonatomic, strong) UIColor* circlehighlightedColor;
@end

@implementation CMPatternLockCirleView

#pragma mark - init method
- (id)initWithRow:(NSInteger)patternRow col:(NSInteger)patternCol
{
    self = [super init];
    if ( self )
    {
        self.backgroundColor = [UIColor clearColor];
        _patternRow = patternRow;
        _patternCol = patternCol;
        _circleSize = KDefaultCircleSize;
        _circleCornerRadius = 0;
        self.userInteractionEnabled = YES;
        
        for ( NSInteger row = 0; row < self.patternRow; row ++ )
        {
            for ( NSInteger col = 0; col < self.patternCol; col ++ )
            {
                UIImageView* imageView = [[UIImageView alloc] init];
                imageView.tag = row * self.patternCol + col + KCircleTagOffset;
                //                [imageView addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
                [self addSubview:imageView];
            }
        }
        
    }
    return self;
}

- (void)clear
{
    for ( UIImageView* circle in self.subviews )
    {
        [circle setHighlighted:NO];
    }
}

- (NSInteger)indexForPoint:(CGPoint)point containhighlighteded:(BOOL)contain
{
    for ( UIImageView* circle in self.subviews )
    {
        if ( CGRectContainsPoint(circle.frame, point))
        {
            if ( !circle.highlighted || (circle.highlighted && contain)  )
            {
                return circle.tag - KCircleTagOffset;
            }
            return -1;
        }
    }
    return -1;
}

- (void)setCirclehighlighteded:(BOOL)highlighted index:(NSInteger)index
{
    UIImageView* imageView = (UIImageView *)[self viewWithTag:index + KCircleTagOffset];
    [imageView setHighlighted:highlighted];
}


- (CGPoint)circlecenterWithIndex:(NSInteger)index
{
    UIImageView* imageView = (UIImageView *)[self viewWithTag:index + KCircleTagOffset];
    if ( imageView )
    {
        return imageView.center;
    }
    return CGPointMake(-1, -1);
}

#pragma mark - set attribute
- (void)setCircleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    for ( UIImageView* circle in self.subviews )
    {
        circle.image = image;
        circle.highlightedImage = highlightedImage;
    }
}

- (void)setCircleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage index:(NSInteger)index {
    UIImageView* circle = (UIImageView *)[self viewWithTag:index + KCircleTagOffset];
    circle.image = image;
    circle.highlightedImage = highlightedImage;
    //    circle.transform = CGAffineTransformMakeRotation(M_PI*1.75);
}

- (void)setCircleColor:(UIColor *)color highlightedColor:(UIColor *)highlightedColor
{
    self.circleColor = color;
    self.circlehighlightedColor = highlightedColor;
    for ( UIImageView* circle in self.subviews )
    {
        circle.backgroundColor = circle.isHighlighted ? highlightedColor : color;
    }
}

- (void)setCircleSize:(CGSize)size cornerRadius:(CGFloat)radius
{
    self.circleCornerRadius = radius;
    self.circleSize = size;
    for ( UIImageView* circle in self.subviews )
    {
        circle.layer.cornerRadius = radius;
    }
    [self setNeedsLayout];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect newframe = CGRectMake(0, 0, self.circleSize.width, self.circleSize.height);
    CGSize marginSize =
    CGSizeMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(newframe) * self.patternCol) / (self.patternCol - 1),
               (CGRectGetHeight(self.bounds) - CGRectGetHeight(newframe) * self.patternRow) / ( self.patternRow - 1));
    
    for ( UIView* circle in self.subviews )
    {
        NSInteger tag = circle.tag - KCircleTagOffset;
        circle.frame = CGRectMake((marginSize.width + CGRectGetWidth(newframe)) * (tag  % self.patternCol),
                                  (marginSize.height + CGRectGetHeight(newframe)) * (tag / self.patternCol),
                                  CGRectGetWidth(newframe),
                                  CGRectGetHeight(newframe));
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ( [keyPath isEqualToString:@"highlighted"] )
    {
        UIImageView* imageView = object;
        imageView.backgroundColor = imageView.highlighted ? self.circlehighlightedColor : self.circleColor;
    }
}

@end
