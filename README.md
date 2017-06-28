#### iOS中JavaScript与原生方法桥接框架

# 使用: 

# Web

```
window.iOSNative.setInfo('12321232');
window.iOSNative.setInfo3('aaaa','bbbb','ccccc');
window.iOSNative.close();
var string =  window.iOSNative.getData();
...
```

# 初始化

```
- (void)viewDidLoad {
    [super viewDidLoad];

    _loJSBridge = [LOJSBridge instanceWithVarName:@"iOSNative"];
    [_loJSBridge addJSFunctionName:@"close" target:self selector:@selector(close)];
    [_loJSBridge addJSFunctionName:@"setInfo" target:self selector:@selector(setInfo:)];
    [_loJSBridge addJSFunctionName:@"setInfo3" target:self selector:@selector(setInfo3:b:c:)];
    [_loJSBridge addReturnJSFunctionName:@"getData" value:@"This is from UIWebView"];
    
    ...
}
```


# 注入JavaScript

* UIWebView

```
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_loJSBridge injectJSFunctions:webView];
    ...
}
```

* WKWebView

```
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [_loJSBridge injectJSFunctions:webView];
    ...
}
```


# 处理

* UIWebView

```
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([_loJSBridge handleRequest:request]) return NO;
    ...
    return YES;
}
```

* WKWebView 

```
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([_loJSBridge handleRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        ...
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
```


# Objective-C 
```
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
```


