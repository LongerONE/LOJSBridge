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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1"]];
    [self.webView loadRequest:request];
    
    self.webView.delegate = self;
    
    _loJSBridge = [LOJSBridge instanceWithVarName:@"iOSNative"];
    [_loJSBridge addJSFunctionName:@"setInfo" target:self selector:@selector(setInfo:) type:InjectionTypeStart];
    [_loJSBridge addReturnJSFunctionName:@"getData" value:@"This is from iOS Native!" type:InjectionTypeStart];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"%@",request.URL.absoluteString);
    
    if ([_loJSBridge handleRequest:request]) return NO;
    
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_loJSBridge injectStartJSIn:webView];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_loJSBridge injectFinishJSIn:webView];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}



- (void)setInfo:(NSString *)info {
    NSLog(@"%@",info);
}


- (NSString *)getData {
    return @"This is from iOS Native!";
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
