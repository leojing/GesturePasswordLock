//
//  GesturePasswordController.h
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//




#import <UIKit/UIKit.h>
#import "CustomPatternLock.h"

@interface GesturePasswordController : UIViewController <CMPatternLockDelegate>

- (void)clear;

- (BOOL)exist;

@property (nonatomic) NSInteger gesPaswdType;  // 0为解锁手势密码   //  1为设置(重置)手势密码

@end
