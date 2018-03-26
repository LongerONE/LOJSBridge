//
//  UIWebViewController.m
//  LOJSBridge-OC
//
//  Created by 唐万龙 on 2017/6/14.
//  Copyright © 2017年 唐万龙. All rights reserved.
//

#import "UIWebViewController.h"
#import "LOJSBridge.h"


@interface UIWebViewController ()<UIWebViewDelegate> {
    LOJSBridge *_loJSBridge;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation UIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.webView loadHTMLString:[self getHtml] baseURL:nil];

    self.webView.delegate = self;
    
    _loJSBridge = [LOJSBridge instanceWithVarName:@"iOSNative"];
    [_loJSBridge addJSFunctionName:@"close" target:self selector:@selector(close)];
    [_loJSBridge addJSFunctionName:@"setInfo" target:self selector:@selector(setInfo:)];
    [_loJSBridge addJSFunctionName:@"setInfo3" target:self selector:@selector(setInfo3:b:c:)];
    [_loJSBridge addReturnJSFunctionName:@"getData" value:@"This is from UIWebView"];
}



- (NSString *)getHtml {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    return [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:nil];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([_loJSBridge handleRequest:request]) return NO;
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_loJSBridge injectJSFunctions:webView];
}


- (void)setInfo:(NSString *)info {
    NSLog(@"%@",info);
}

- (void)setInfo3:(NSString *)a b:(NSString *)b c:(NSString *)c {
    NSLog(@"%@",a);
    NSLog(@"%@",b);
    NSLog(@"%@",c);
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
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
