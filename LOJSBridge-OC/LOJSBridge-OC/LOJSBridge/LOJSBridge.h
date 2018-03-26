//
//  LOJSBridge.h
//  LOJSBridge-OC
//
//  Created by 唐万龙 on 2017/6/14.
//  Copyright © 2017年 唐万龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LOJSBridge : NSObject

NS_ASSUME_NONNULL_BEGIN

/**
 需要注入的 JS 代码
 */
@property (nonatomic, copy) NSString *jsFunctionString;

/**
 初始化
 
 @param varname 变量名 windows.native 则为native
 @return instancetype
 */
+ (instancetype _Nonnull)instanceWithVarName:(NSString *)varname;

/**
 添加JS与iOS方法
 
 @param functionName JS方法名 Windows.native.close 为 close
 @param target target
 @param action OC 方法
 */
- (void)addJSFunctionName:(NSString *)functionName target:(id)target selector:(SEL)action;

/**
 添加返回参数的JS
 
 @param functionName 方法名
 @param value 返回值
 */
- (void)addReturnJSFunctionName:(NSString *)functionName
                          value:(id)value;

/**
 注入JS代码

 WKWebView 注入：
 WKUserScript *userScript = [[WKUserScript alloc] initWithSource:self.jsBridge.jsFunctionString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
 WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
 [config.userContentController addUserScript:userScript];
 self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
 
 
 @param webView UIWebView
 */
- (void)injectJSFunctions:(UIWebView *)webView;


/**
 处理请求映射

 @param request 请求
 @return 是否可以映射
 */
- (BOOL)handleRequest:(NSURLRequest *)request;

NS_ASSUME_NONNULL_END

@end
