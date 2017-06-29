//
//  LOJSBridge.m
//  LOJSBridge-OC
//
//  Created by 唐万龙 on 2017/6/14.
//  Copyright © 2017年 唐万龙. All rights reserved.
//

#import "LOJSBridge.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef void (^BOOLBlock)(BOOL boolResult);

#define URL_Header @"iosselector:"
#define Header_Seperator @"//"
#define Function_Seperator @"&JsRvUhcf03CgnwrI&"
#define Param_Seperator @"&Aue8i7yi0qfcfUCf&"

@interface LOJSBridge () {
    NSString *_varName;
    NSMutableDictionary *_targetDict;
    NSMutableDictionary *_selDict;
}

@property (nonatomic, copy) NSString *jsFunctionString;

@end

@implementation LOJSBridge

#pragma mark - Init
+ (instancetype)instanceWithVarName:(NSString *)varname {
    return [[self alloc] initWithVarName:varname];
}

- (instancetype)initWithVarName:(NSString *)var {
    _varName = var;
    _jsFunctionString = [NSString stringWithFormat:@"var %@={};",_varName];
    _targetDict = [NSMutableDictionary dictionary];
    _selDict = [NSMutableDictionary dictionary];
    return self;
}


#pragma mark - addJSFunctionName
- (void)addJSFunctionName:(NSString *)functionName target:(id)target selector:(SEL)action {
    //缓存
    [_targetDict setObject:target forKey:functionName];
    [_selDict setObject:NSStringFromSelector(action) forKey:functionName];
    
    //判断iOS方法参数个数
    NSArray *param = [NSStringFromSelector(action) componentsSeparatedByString:@":"];
    
    NSString *jsParamString = @"";   //JS方法中的参数格式
    NSString *urlParamString = @"";  //连接中的参数格式
    if (param.count - 1) {
        //有参数
        urlParamString = @"+";
        for (int i = 0; i < param.count - 1; i++) {
            if (i != 0) {
                jsParamString = [jsParamString stringByAppendingString:@","];
                NSString *urlParmSeperator = [NSString stringWithFormat:@" + '%@' + ",Param_Seperator];
                urlParamString = [urlParamString stringByAppendingString:urlParmSeperator];
            }
            
            NSString *param = [NSString stringWithFormat:@"parameter%d",i + 1];
            jsParamString = [jsParamString stringByAppendingString:param];
            urlParamString = [urlParamString stringByAppendingString:param];
        }
        
        NSString *actionJS = [NSString stringWithFormat:@"%@.%@=function(%@){window.location.href='%@%@%@%@'%@};",_varName,functionName,jsParamString,URL_Header,Header_Seperator,functionName,Function_Seperator,urlParamString];
        
        
        self.jsFunctionString = [self.jsFunctionString stringByAppendingString:actionJS];
    } else{
        //无参数
        NSString *actionJS = [NSString stringWithFormat:@"%@.%@=function(%@){window.location.href='%@%@%@'};",_varName,functionName,jsParamString,URL_Header,Header_Seperator,functionName];
        self.jsFunctionString = [self.jsFunctionString stringByAppendingString:actionJS];
    }
}


#pragma mark - addReturnJSFunctionName
- (void)addReturnJSFunctionName:(NSString *)functionName value:(id)value {
    NSString *actionJS = [NSString stringWithFormat:@"%@.%@=function(){return '%@'};",_varName,functionName,value];
    self.jsFunctionString = [self.jsFunctionString stringByAppendingString:actionJS];
}


#pragma mark - InjectFunctionJS
- (void)injectJSFunctions:(id)webView {
    //注入功能JS
    [self inject:_jsFunctionString in:webView];
}

- (void)inject:(NSString *)jsString in:(id)webView {
    
    if (jsString.length == 0) {
        return;
    }
    
    if ([webView isKindOfClass:[UIWebView class]]) {
        UIWebView *uiWebView = (UIWebView *)webView;
        [uiWebView stringByEvaluatingJavaScriptFromString:jsString];
    }
    
    if ([webView isKindOfClass:[WKWebView class]]) {
        WKWebView *wkWebView = (WKWebView *)webView;
        
        [wkWebView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"(LOJSBridge)Inject  JS error: %@", error);
            }
        }];
    }
}

#pragma mark - Handle Request
- (BOOL)handleRequest:(NSURLRequest *)request {
    if (!request) return NO;
    
    NSString *requstString = [[[request URL] absoluteString] stringByRemovingPercentEncoding];
    
    if ([requstString hasPrefix:URL_Header]) {
        NSString *actionString = [[requstString componentsSeparatedByString:Header_Seperator] lastObject];
        
        NSArray *functionParamList = [actionString componentsSeparatedByString:Function_Seperator];
        
        NSString *functionName = [functionParamList firstObject];
        //方法名
        
        id target = [_targetDict objectForKey:functionName];
        SEL selector = NSSelectorFromString([_selDict objectForKey:functionName]);
        
        NSArray *params;
        if (functionParamList.count > 1) {
            //有参数
            params = [[functionParamList lastObject] componentsSeparatedByString:Param_Seperator]; //iOS方法的参数
        } else {
            //无参数
            params = @[];
        }
        
        if ([target respondsToSelector:selector]) {
            [self performtarget:target selector:selector withObjects:params];
        }
        
        return YES;
    } else {
        return NO;
    }
}


- (id)performtarget:(id)target selector:(SEL)selector withObjects:(NSArray *)args {
    NSMethodSignature *sig = [target methodSignatureForSelector:selector];
    
    if (sig) {
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
        [invo setTarget:target];
        [invo setSelector:selector];
        
        //设置参数
        for (int i = 0; i < args.count; i++) {
            id obj = args[i];
            [invo setArgument:&obj atIndex:i + 2];
            
        }
        [invo invoke];
        
        if (sig.methodReturnLength) {
            id anObject;
            [invo getReturnValue:&anObject];
            return anObject;
        }  else {
            return nil;
        }
    } else {
        return nil;
    }
}



@end
