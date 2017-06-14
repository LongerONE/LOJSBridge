//
//  ViewController.m
//  LOJSBridge-OC
//
//  Created by 唐万龙 on 2017/6/14.
//  Copyright © 2017年 唐万龙. All rights reserved.
//

#import "ViewController.h"
#import "LOJSBridge.h"

@interface ViewController ()<UIWebViewDelegate> {
    LOJSBridge *_loJSBridge;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1"]];
    [self.webView loadRequest:request];
    
    self.webView.delegate = self;
    
    
    _loJSBridge = [LOJSBridge instanceWithVarName:@"iOSNative"];
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([_loJSBridge handleRequestString:webView.request.URL.absoluteString]) return NO;
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
