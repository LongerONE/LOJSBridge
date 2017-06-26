//
//  WKWebViewController.m
//  LOJSBridge-OC
//
//  Created by 唐万龙 on 2017/6/14.
//  Copyright © 2017年 唐万龙. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import "LOJSBridge.h"

@interface WKWebViewController ()<WKNavigationDelegate> {
    WKWebView *_wkWebView;
    LOJSBridge *_loJSBridge;
}

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.size.height -= 64;
    _wkWebView = [[WKWebView alloc] initWithFrame:frame];
    _wkWebView.navigationDelegate = self;
    [self.view addSubview:_wkWebView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1"]];
    [_wkWebView loadRequest:request];
    
    
    _loJSBridge = [LOJSBridge instanceWithVarName:@"iOSNative"];
    [_loJSBridge addJSFunctionName:@"setInfo" target:self selector:@selector(setInfo:) type:InjectionTypeFinish];
    [_loJSBridge addReturnJSFunctionName:@"getData" value:@"This is from iOS Native!" type:InjectionTypeFinish];
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [_loJSBridge injectStartJSIn:webView];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [_loJSBridge injectFinishJSIn:webView];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([_loJSBridge handleRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}


- (void)setInfo:(NSString *)info {
    NSLog(@"%@",info);
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
