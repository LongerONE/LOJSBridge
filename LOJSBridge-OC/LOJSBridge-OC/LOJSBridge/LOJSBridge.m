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

@interface LOJSBridge () {
    NSString *_varName;
    NSMutableDictionary *_targetDict;
    NSMutableDictionary *_selDict;
}


@property (nonatomic, copy) NSString *jsStartString;
@property (nonatomic, copy) NSString *jsFinishString;

@end

@implementation LOJSBridge

#pragma mark - Init
+ (instancetype)instanceWithVarName:(NSString *)varname {
    return [[self alloc] initWithVarName:varname];
}

- (instancetype)initWithVarName:(NSString *)var {
    _varName = var;
    _jsStartString = [NSString stringWithFormat:@"window.%@={};",_varName];
    _jsFinishString = @"";
    _targetDict = [NSMutableDictionary dictionary];
    _selDict = [NSMutableDictionary dictionary];
    return self;
}


#pragma mark - addJSFunctionName
- (void)addJSFunctionName:(NSString *)name target:(id)target selector:(SEL)action type:(InjectionType)type {
    //缓存
    [_targetDict setObject:target forKey:name];
    [_selDict setObject:NSStringFromSelector(action) forKey:name];
    
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
                urlParamString = [urlParamString stringByAppendingString:@"+':://:'+"];
            }
            
            NSString *param = [NSString stringWithFormat:@"parameter%d",i + 1];
            
            jsParamString = [jsParamString stringByAppendingString:param];
            
            
            urlParamString = [urlParamString stringByAppendingString:param];
        }
        
        NSString *actionJS = [NSString stringWithFormat:@"%@.%@=function(%@){window.location.href='iossel://///%@:///:'%@};",_varName,name,jsParamString,name,urlParamString];
        
        if (type == InjectionTypeStart) {
            self.jsStartString = [self.jsStartString stringByAppendingString:actionJS];
        } else if (type == InjectionTypeFinish) {
            self.jsFinishString = [self.jsFinishString stringByAppendingString:actionJS];
        }
        
    } else{
        //无参数
        NSString *actionJS = [NSString stringWithFormat:@"%@.%@=function(%@){window.location.href='iossel://///%@'};",_varName,name,jsParamString,name];
        
        if (type == InjectionTypeStart) {
            self.jsStartString = [self.jsStartString stringByAppendingString:actionJS];
        } else if (type == InjectionTypeFinish) {
            self.jsFinishString = [self.jsFinishString stringByAppendingString:actionJS];
        }
    }
}


#pragma mark - addReturnJSFunctionName
- (void)addReturnJSFunctionName:(NSString *)name value:(id)value type:(InjectionType)type {
    NSString *actionJS = [NSString stringWithFormat:@"%@.%@=function(){return '%@'}",_varName,name,value];
    if (type == InjectionTypeStart) {
        self.jsStartString = [self.jsStartString stringByAppendingString:actionJS];
    } else if (type == InjectionTypeFinish) {
        self.jsFinishString = [self.jsFinishString stringByAppendingString:actionJS];
    }
}


#pragma mark - InjectStartJS
- (void)injectStartJSIn:(id)webView {
    if ([webView isKindOfClass:[UIWebView class]]) {
        UIWebView *uiWebView = (UIWebView *)webView;
        [uiWebView stringByEvaluatingJavaScriptFromString:_jsStartString];
    }
    
    if ([webView isKindOfClass:[WKWebView class]]) {
        WKWebView *wkWebView = (WKWebView *)webView;
        [wkWebView evaluateJavaScript:_jsStartString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Inject start JS error: %@", error);
            }
        }];
    }
}

#pragma mark - InjectFinishJS
- (void)injectFinishJSIn:(id)webView {
    if ([webView isKindOfClass:[UIWebView class]]) {
        UIWebView *uiWebView = (UIWebView *)webView;
        [uiWebView stringByEvaluatingJavaScriptFromString:_jsFinishString];
    }
    
    if ([webView isKindOfClass:[WKWebView class]]) {
        WKWebView *wkWebView = (WKWebView *)webView;
        [wkWebView evaluateJavaScript:_jsFinishString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Inject finish JS error: %@", error);
            }
        }];
    }
}




#pragma mark - Handle Request
- (BOOL)handleRequestString:(NSString *)string {
    if ([string hasPrefix:@"iossel://///"]) {
        NSString *actionString = [[string componentsSeparatedByString:@"/////"] lastObject];
        
        NSArray *actionParamList = [actionString componentsSeparatedByString:@":///:"];
        
        NSString *actionName = [actionParamList firstObject];
        //方法名
        
        id target = [_targetDict objectForKey:actionName];
        SEL selector = NSSelectorFromString([_selDict objectForKey:actionName]);
        
        NSArray *params;
        if (actionParamList.count > 1) {
            //有参数
            params = [[actionParamList lastObject] componentsSeparatedByString:@":://:"]; //iOS方法的参数
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
