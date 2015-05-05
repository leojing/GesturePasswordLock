//
//  CMPatternLock.h
//  PatternLock
//
//  Created by Xinling on 14-2-17.
//  Copyright (c) 2014年 Xinling All reserved.
//

#import <UIKit/UIKit.h>

@class CustomPatternLock;

@protocol CMPatternLockDelegate <NSObject>

- (BOOL)patternLock:(CustomPatternLock *)patternLock didEndWithPattern:(NSArray *)patterns;  // 进行结果判断，验证手势密码是否正确

@end

@interface CustomPatternLock : UIView

@property (nonatomic, strong) NSMutableArray* patterns;

@property (nonatomic, weak) id<CMPatternLockDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger patternRow;
@property (nonatomic, assign, readonly) NSInteger patternCol;

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic) BOOL isShowArrow; // 当处于设置手势密码时，需要显示手势滑动的路径，即箭头

- (id)initWithRow:(NSInteger)patternRow col:(NSInteger)patternCol;
- (void)clearPattern;

@end
