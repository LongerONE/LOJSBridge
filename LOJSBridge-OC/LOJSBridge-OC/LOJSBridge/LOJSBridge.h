//
//  LOJSBridge.h
//  LOJSBridge-OC
//
//  Created by 唐万龙 on 2017/6/14.
//  Copyright © 2017年 唐万龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LOJSBridge : NSObject

/**
 初始化
 
 @param varname 变量名 windows.native 则为native
 @return instancetype
 */
+ (instancetype _Nonnull)instanceWithVarName:(NSString *_Nonnull)varname;


/**
 添加JS与iOS方法
 
 @param functionName JS方法名 Windows.native.close 为 close
 @param action iOS 方法
 */
- (void)addJSFunctionName:(NSString * _Nonnull)functionName
                   target:(id _Nonnull )target
                 selector:(SEL _Nonnull)action;


/**
 添加返回参数的JS
 
 @param functionName 方法名
 @param value 返回值
 */
- (void)addReturnJSFunctionName:(NSString *_Nonnull )functionName
                          value:(id _Nonnull)value;



/**
 注入JS代码

 @param webView webView(UIWebView or WKWebView)
 */
- (void)injectJSFunctions:(id _Nonnull)webView;


/**
 处理请求映射

 @param request 请求
 @return 是否可以映射
 */
- (BOOL)handleRequest:(NSURLRequest *_Nonnull)request;


@end
