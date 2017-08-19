//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by mosquito on 2017/8/18.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "ViewController.h"
#import "NextViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()
<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

//webview
@property (nonatomic, strong) WKWebView *webView;
//progressview
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self createWebView];
    [self createProgressView];
    
    //添加KVO监听
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"前进"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(goFarward)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //移除监听
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)createWebView {
    
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.preferences = [WKPreferences new];
    configuration.preferences.minimumFontSize = 10;
    configuration.preferences.javaScriptEnabled = YES;
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    configuration.userContentController = [WKUserContentController new];
    // 注入JS对象名称senderModel，当JS通过senderModel来调用时，我们可以在WKScriptMessageHandler代理中接收到
    [configuration.userContentController addScriptMessageHandler:self name:@"senderModel"];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"WKWebViewText" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:path]];
    [self.view addSubview:self.webView];
    
}

- (void)createProgressView {
    self.progressView = [[UIProgressView alloc] initWithFrame:self.view.bounds];
    self.progressView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.progressView];
}

- (void)goBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        NSLog(@"webview goback");
    }
}

- (void)goFarward {
    if ([self.webView canGoForward]) {
        [self.webView canGoForward];
        NSLog(@"webview canGoForward");
    }
}

#pragma mark -- KVO监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"loading"]){
        NSLog(@"loading");
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
    }
    
    //加载完成
    if (!self.webView.loading) {
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0.0;
        }];
    }
}

#pragma mark -- WKScriptMessageHandle

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //通过name处理交互
    if ([message.name isEqualToString:@"senderModel"]) {
        //body只支持NSNumber, NSString, NSDate, NSArray, NSDictionary 和 NSNull类型
        NSString *bodyString = [message.body valueForKey:@"body"];
        if ([bodyString isEqualToString:@"jumpToNext"]) {
            NextViewController *nextVC = [[NextViewController alloc] init];
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }
}

#pragma mark -- WKNavigationDelegate
//发送请求之前决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *hostName = navigationAction.request.URL.host.lowercaseString;
    NSLog(@"hostName: %@", hostName);
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated && ![hostName containsString:@".jianshu.com"]) {
        //跨域需手动跳转
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        //不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
         
    } else {
        self.progressView.alpha = 1.0;
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"createWebViewWithConfiguration");
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

//接收到相应数据后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//接收到服务器跳转请求后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

//开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

//当内容开始返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

//页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"title:%@",webView.title);
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}


#pragma mark WKUIDelegate

//alert 警告框
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告"
                                                                   message:@"调用alert提示框"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    NSLog(@"alert message:%@",message);
    
}

//confirm 确认框
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框"
                                                                   message:@"调用confirm提示框"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"confirm message:%@", message);
    
}

//input 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"输入框"
                                message:@"调用输入框"
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
    }];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
