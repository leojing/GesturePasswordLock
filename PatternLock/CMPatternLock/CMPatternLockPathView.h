//
//  CMPatternLockPathView.h
//  PatternLock
//
//  Created by Xinling on 14-2-17.
//  Copyright (c) 2014年 Xinling All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMPatternLockPathView : UIView
/**
 *  已选中点
 */
@property (nonatomic, strong) NSMutableArray* finishedPatternPoint;

/**
 *  当前正在移动的点
 */
@property (nonatomic, assign) CGPoint currentPoint;


/**
 *  颜色
 */
@property (nonatomic, strong) UIColor* lineColor;

/**
 *  线宽度
 */
@property (nonatomic, assign) CGFloat lineWidth;

@end
