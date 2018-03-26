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

@interface WKWebViewController ()<WKNavigationDelegate, WKUIDelegate> {
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
    
    _loJSBridge = [LOJSBridge instanceWithVarName:@"iOSNative"];
    [_loJSBridge addJSFunctionName:@"close" target:self selector:@selector(close)];
    [_loJSBridge addJSFunctionName:@"setInfo" target:self selector:@selector(setInfo:)];
    [_loJSBridge addJSFunctionName:@"setInfo3" target:self selector:@selector(setInfo3:b:c:)];
    [_loJSBridge addReturnJSFunctionName:@"getData" value:@"This is from WKWebView"];
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:_loJSBridge.jsFunctionString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addUserScript:userScript];
    
    _wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:config];

    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    
    _wkWebView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:_wkWebView];
    
    [_wkWebView loadHTMLString:[self getHtml] baseURL:nil];
}



- (NSString *)getHtml {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    return [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:nil];
}



- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    
    if (navigationAction.targetFrame == nil) {
        //打开新的空白页
        /**  <a href = "http://xxx" target = "_blank">  */
        [webView loadRequest:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([_loJSBridge handleRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        
        
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}



- (void)setInfo:(NSString *)info {
    NSLog(@"%@",info);
}


- (void)setInfo3:(NSString *)a b:(NSString *)b c:(NSString *)c {
    NSLog(@"%@",a);
    NSLog(@"%@",b);
    NSLog(@"%@",c);
}


#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    //提示框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    //输入框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //确定或取消框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}



- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)dealloc {

    
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
