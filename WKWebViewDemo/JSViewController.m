//
//  JSViewController.m
//  WKWebViewDemo
//
//  Created by mosquito on 2017/8/19.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "JSViewController.h"
#import <WebKit/WebKit.h>

@interface JSViewController ()
<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation JSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // 图片缩放的js代码
    NSString *js = @"var count = document.images.length;for (var i = 0; i < count; i++) {var image = document.images[i];image.style.width=320;};window.alert('找到' + count + '张图');";
    
    // 根据JS字符串初始化WKUserScript对象
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    // 根据生成的WKUserScript对象，初始化WKWebViewConfiguration
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addUserScript:script];
    
    NSString *jsString = @"<head></head><img src='http://www.nsu.edu.cn/v/2014v3/img/background/3.jpg' />";
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.webView loadHTMLString:jsString baseURL:nil];
    [self.view addSubview:self.webView];
}


// 从web界面中接收到一个脚本时调用
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@"%@", message);
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
