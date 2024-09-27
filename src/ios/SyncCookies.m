#import <Cordova/CDV.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

#import "SyncCookies.h"

@implementation SyncCookies


- (void) test:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"test"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void) SyncCookiesFromWK:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

        WKWebsiteDataStore* dataStore = [WKWebsiteDataStore defaultDataStore];
        WKHTTPCookieStore* cookieStore = dataStore.httpCookieStore;
        [cookieStore getAllCookies:^(NSArray* cookies) {
            NSHTTPCookie* cookie;
            for(cookie in cookies) {
                NSMutableDictionary* cookieDict = [cookie.properties mutableCopy];
                [cookieDict removeObjectForKey:NSHTTPCookieDiscard]; // Remove the discard flag. If it is set (even to false), the expires date will NOT be kept.
                NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:cookieDict];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
                
            }
        }];

     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void) SyncCookiesFromNS:(CDVInvokedUrlCommand*)command {
    @try {
        if (![self.webView isKindOfClass:[WKWebView class]]) {
            @throw [NSException exceptionWithName:@"InvalidWebViewType" reason:@"self.webView is not a WKWebView" userInfo:nil];
        }

        WKWebView* wkWebView = (WKWebView*) self.webView;
        if (!wkWebView.configuration || !wkWebView.configuration.websiteDataStore || !wkWebView.configuration.websiteDataStore.httpCookieStore) {
            @throw [NSException exceptionWithName:@"InvalidWebViewConfiguration" reason:@"WKWebView configuration or httpCookieStore is nil" userInfo:nil];
        }

        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookies];

        for (NSHTTPCookie* cookie in cookies) {
            NSMutableDictionary* cookieDict = [cookie.properties mutableCopy];
            [cookieDict removeObjectForKey:NSHTTPCookieDiscard];
            NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:cookieDict];
            [wkWebView.configuration.websiteDataStore.httpCookieStore setCookie:newCookie completionHandler:^{NSLog(@"Cookies synced");}];
        }
    } @catch (NSException *e) {
        CDVPluginResult* pluginResult2 = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:e.reason];
        [self.commandDelegate sendPluginResult:pluginResult2 callbackId:command.callbackId];
        return;
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end