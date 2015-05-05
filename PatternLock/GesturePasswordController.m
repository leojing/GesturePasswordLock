//
//  GesturePasswordController.m
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//


#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#import "GesturePasswordController.h"
#import "KeychainItemWrapper/KeychainItemWrapper.h"

@interface GesturePasswordController ()<UIAlertViewDelegate>

@end

@implementation GesturePasswordController {
    NSString * previousString;
    NSString * password;
    CustomPatternLock* lockView;
    UIView *confirmView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.gesPaswdType == 1) {
        [self clear];
    }
    // Do any additional setup after loading the view.
    previousString = [NSString string];
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];
    [self creatLockView];
    if (self.gesPaswdType == 1) {
        [self creatConfirmView]; // 创建确认密码形状的view
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - pattern lock delegate
- (BOOL)patternLock:(CustomPatternLock *)patternLock didEndWithPattern:(NSArray *)patterns
{
    NSString *result = @"";
    for (NSInteger i = 0; i < patterns.count; i ++) {
        if (i == patterns.count-1) {
            result = [result stringByAppendingString:[NSString stringWithFormat:@"%@", [patterns objectAtIndex:i]]];
        } else {
            result = [result stringByAppendingString:[NSString stringWithFormat:@"%@,", [patterns objectAtIndex:i]]];
        }
    }
    NSLog(@"%@",result);
    if (self.gesPaswdType == 0) {
        if ([result isEqualToString:password]) {
            NSLog(@"输入正确");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bingo!" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alertView show];
            
            return YES;
        }
        NSLog(@"手势密码错误");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GesturePassword wrong!" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    } else {
        if ([previousString isEqualToString:@""]) {
            previousString = result;
            NSLog(@"请验证输入密码");
            [self showSettedGesPw:YES Password:result];
            
            return YES;
        }
        else {
            if ([result isEqualToString:previousString]) {
                KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
                [keychin setObject:@"<帐号>" forKey:(__bridge id)kSecAttrAccount];
                [keychin setObject:result forKey:(__bridge id)kSecValueData];
                
                password = [keychin objectForKey:(__bridge id)kSecValueData];
                NSLog(@"已保存手势密码");
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GesturePassword set succeed!" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alertView show];

                return YES;
            }
            else{
                previousString = @"";
                NSLog(@"两次密码不一致，请重新输入");
                [self showSettedGesPw:NO Password:result];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GesturePassword set failed, please set it again!" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alertView show];

                return NO;
            }
        }
    }
    return NO;
}

#pragma mark - 创建手势密码页面
- (void)creatLockView{
    lockView = [[CustomPatternLock alloc] initWithRow:3 col:3];
    lockView.frame = self.view.bounds;
    lockView.contentInset = UIEdgeInsetsMake(220, 50, 100, 40);
    lockView.delegate = self;
    lockView.isShowArrow = YES;
    [self.view addSubview:lockView];
}

- (void)creatConfirmView {
    confirmView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-65)/2, 120, 65, 65)];
    confirmView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:confirmView];
    
    CGFloat smallCircleWidth = 17;
    CGFloat dis = (confirmView.frame.size.width-smallCircleWidth*3)/2;
    for (NSInteger row = 0; row < 3; row ++) {
        for (NSInteger col = 0; col < 3; col ++) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(col*(smallCircleWidth+dis), row*(smallCircleWidth+dis), smallCircleWidth, smallCircleWidth)];
            imageView.tag = row * 3 + col +11;
            [imageView setImage:[UIImage imageNamed:@"gesPw_normal"]];
            [confirmView addSubview:imageView];
        }
    }
}

#pragma mark - 显示设置的手势密码

- (void)showSettedGesPw:(BOOL)succees Password:(NSString *)passWord{
    for (NSInteger i = 0; i < 9; i ++) {
        UIImageView *view = (UIImageView *)[confirmView viewWithTag:i+11];
        if ([passWord containsString:[NSString stringWithFormat:@"%ld", (long)i]]) {
            if (succees) {
                [view setImage:[UIImage imageNamed:@"gesPw_succeed"]];
            } else {
                [view setImage:[UIImage imageNamed:@"gesPw_fail"]];
            }
        } else {
            [view setImage:[UIImage imageNamed:@"gesPw_normal"]];
        }
    }
}

#pragma mark - 判断是否已存在手势密码
- (BOOL)exist{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];
    if (password == nil)return NO;
    return YES;
}

#pragma mark - 清空记录
- (void)clear{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    [keychin resetKeychainItem];
}

#pragma mark - 忘记手势密码
- (void)forget{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"忘记手势密码？" message:@"忘记手势密码需要重新登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新登录", nil];
    alertView.tag = 11;
    [alertView show];
}

#pragma mark - Navigation

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            [self clear];
            // 这里需要进行登录验证，登录成功后，方可进入设置
            self.gesPaswdType = 1;
        }
    }
}

@end
