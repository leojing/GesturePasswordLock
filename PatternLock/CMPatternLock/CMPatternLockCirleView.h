//
//  CMPatternLockCirleView.h
//  PatternLock
//
//  Created by Xinling on 14-2-17.
//  Copyright (c) 2014年 Xinling All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMPatternLockCirleView : UIView

@property (nonatomic, assign, readonly) NSInteger patternRow;
@property (nonatomic, assign, readonly) NSInteger patternCol;
//@property (nonatomic, strong) NSMutableArray* patterns;

#pragma mark - set attribute
- (void)setCircleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;
- (void)setCircleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage index:(NSInteger)index;
- (void)setCircleColor:(UIColor *)color highlightedColor:(UIColor *)highlightedColor;
- (void)setCircleSize:(CGSize)size cornerRadius:(CGFloat)radius;

#pragma mark - operate
- (void)clear;
- (void)setCirclehighlighteded:(BOOL)highlighted index:(NSInteger)index;
- (NSInteger)indexForPoint:(CGPoint)point containhighlighteded:(BOOL)contain;
- (CGPoint)circlecenterWithIndex:(NSInteger)index;

#pragma mark - init method
- (id)initWithRow:(NSInteger)patternRow col:(NSInteger)patternCol;

@end
