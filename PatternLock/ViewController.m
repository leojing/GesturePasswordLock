//
//  ViewController.m
//  PatternLock
//
//  Created by Xinling on 14-2-17.
//  Copyright (c) 2014年 Xinling All rights reserved.
//

#import "ViewController.h"
#import "GesturePasswordController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *setPw = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-80, 100, 160, 50)];
    [setPw setTitle:@"set GesturePassword" forState:UIControlStateNormal];
    [setPw setBackgroundColor:[UIColor greenColor]];
    [setPw addTarget:self action:@selector(setPwAction) forControlEvents:UIControlEventTouchUpInside];
    [setPw.titleLabel setNumberOfLines:0];
    [setPw.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:setPw];
    
    UIButton *verityPw = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-80, 200, 160, 50)];
    [verityPw setTitle:@"confirm GesturePassword" forState:UIControlStateNormal];
    [verityPw setBackgroundColor:[UIColor redColor]];
    [verityPw addTarget:self action:@selector(verityPwAction) forControlEvents:UIControlEventTouchUpInside];
    [verityPw.titleLabel setNumberOfLines:0];
    [verityPw.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:verityPw];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPwAction {
    GesturePasswordController *vc = [[GesturePasswordController alloc] init];
    vc.gesPaswdType = 1;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)verityPwAction {
    GesturePasswordController *vc = [[GesturePasswordController alloc] init];
    vc.gesPaswdType = 0;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
