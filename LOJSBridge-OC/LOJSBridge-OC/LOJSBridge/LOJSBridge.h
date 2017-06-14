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
 
 @param name JS方法名 Windows.heikuai.close 为 close
 @param action iOS 方法
 */
- (void)addJSFunctionName:(NSString * _Nonnull)name target:(id _Nonnull )target selector:(SEL _Nonnull)action type:(InjectionType)type;



/**
 添加返回参数的JS
 
 @param name 方法名
 @param value 返回值
 */
- (void)addReturnJSFunctionName:(NSString *_Nonnull )name value:(id _Nonnull)value type:(InjectionType)type;




- (void)injectStartJSIn:(id)webView;


- (void)injectFinishJSIn:(id)webView;




/**
 处理Web内部请求，映射到 iOS 方法中
 _Nonnull
 @param string 请求地址，本类内部已定义
 */
- (BOOL)handleRequestString:(NSString *_Nonnull)string;


@end
