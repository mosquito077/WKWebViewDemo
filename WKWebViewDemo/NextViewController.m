//
//  NextViewController.m
//  WKWebViewDemo
//
//  Created by mosquito on 2017/8/19.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "NextViewController.h"
#import "JSViewController.h"
#import <WebKit/WebKit.h>

@interface NextViewController ()

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 80)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"JS测试" forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(btnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnTapped {
    JSViewController *jsVC = [[JSViewController alloc]init];
    [self.navigationController pushViewController:jsVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
