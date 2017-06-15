//
//  LOJSBridge.h
//  LOJSBridge-OC
//
//  Created by 唐万龙 on 2017/6/14.
//  Copyright © 2017年 唐万龙. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,InjectionType) {
    InjectionTypeStart = 0,  //在网页开始加载时注入
    InjectionTypeFinish = 1  //在网页加载结束后注入
};

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
                 selector:(SEL _Nonnull)action
                     type:(InjectionType)type;


/**
 添加返回参数的JS
 
 @param functionName 方法名
 @param value 返回值
 */
- (void)addReturnJSFunctionName:(NSString *_Nonnull )functionName
                          value:(id _Nonnull)value
                           type:(InjectionType)type;



/**
 注入网页开始加载时的JS

 @param webView webView对象 支持 UIWebView 和 WKWebView
 */
- (void)injectStartJSIn:(id _Nonnull )webView;


/**
 注入网页加载完毕时的JS

 @param webView webView对象 支持 UIWebView 和 WKWebView
 */
- (void)injectFinishJSIn:(id _Nonnull )webView;



/**
 处理Web内部请求，映射到 iOS 方法中

 @param webView webView对象
 @return 是否满足映射
 */
- (BOOL)handleRequest:(NSURLRequest *)request;


@end
