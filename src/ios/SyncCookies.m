#import <Cordova/CDV.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

#import "SyncCookies.h"

@implementation SyncCookies

- (void)test:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"test"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)SyncCookiesFromWK:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    @try {
        WKWebsiteDataStore* dataStore = [WKWebsiteDataStore defaultDataStore];
        WKHTTPCookieStore* cookieStore = dataStore.httpCookieStore;
        [cookieStore getAllCookies:^(NSArray* cookies) {
            [self syncCookies:cookies toStorage:[NSHTTPCookieStorage sharedHTTPCookieStorage]];
        }];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
    } @catch (NSException *e) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:e.reason];
    } @finally {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)SyncCookiesFromNS:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    @try {
        if (![self.webView isKindOfClass:[WKWebView class]]) {
            @throw [NSException exceptionWithName:@"InvalidWebViewType" reason:@"self.webView is not a WKWebView" userInfo:nil];
        }

        WKWebView* wkWebView = (WKWebView*)self.webView;
        if (!wkWebView.configuration || !wkWebView.configuration.websiteDataStore || !wkWebView.configuration.websiteDataStore.httpCookieStore) {
            @throw [NSException exceptionWithName:@"InvalidWebViewConfiguration" reason:@"WKWebView configuration or httpCookieStore is nil" userInfo:nil];
        }

        NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray<NSHTTPCookie*>* cookies = [cookieStorage cookies];
        [self syncCookies:cookies toStorage:wkWebView.configuration.websiteDataStore.httpCookieStore];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
    } @catch (NSException *e) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:e.reason];
    } @finally {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)SyncCookiesFromNS2:(CDVInvokedUrlCommand*)command {
    __block CDVPluginResult* pluginResult = nil;
    @try {
        if (![self.webView isKindOfClass:[WKWebView class]]) {
            @throw [NSException exceptionWithName:@"InvalidWebViewType" reason:@"self.webView is not a WKWebView" userInfo:nil];
        }

        WKWebView* wkWebView = (WKWebView*)self.webView;
        WKHTTPCookieStore* cookieStore = wkWebView.configuration.websiteDataStore.httpCookieStore;

        if (!cookieStore) {
            @throw [NSException exceptionWithName:@"InvalidWebViewConfiguration" reason:@"WKWebView configuration or httpCookieStore is nil" userInfo:nil];
        }

        NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray<NSHTTPCookie*>* cookies = [cookieStorage cookies];

        if (cookies.count == 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"No cookies to move"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }

        dispatch_group_t group = dispatch_group_create();

        for (NSHTTPCookie* cookie in cookies) {
            NSMutableDictionary* cookieDict = [cookie.properties mutableCopy];
            [cookieDict removeObjectForKey:NSHTTPCookieDiscard];
            NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:cookieDict];

            if (!newCookie) {
                NSLog(@"Invalid cookie: %@", cookie);
                continue;
            }

            dispatch_group_enter(group);
            [cookieStore setCookie:newCookie completionHandler:^{
                NSLog(@"Cookie synced: %@", newCookie.name);
                dispatch_group_leave(group);
            }];
        }

        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Cookies moved successfully"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });

        dispatch_after(timeout, dispatch_get_main_queue(), ^{
            if (dispatch_group_wait(group, DISPATCH_TIME_NOW) != 0) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Timeout while moving cookies"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        });
    } @catch (NSException *e) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:e.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)syncCookies:(NSArray<NSHTTPCookie*>*)cookies toStorage:(id)storage {
    for (NSHTTPCookie* cookie in cookies) {
        NSMutableDictionary* cookieDict = [cookie.properties mutableCopy];
        [cookieDict removeObjectForKey:NSHTTPCookieDiscard];
        NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:cookieDict];
        if ([storage isKindOfClass:[NSHTTPCookieStorage class]]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
        } else if ([storage isKindOfClass:[WKHTTPCookieStore class]]) {
            [(WKHTTPCookieStore*)storage setCookie:newCookie completionHandler:^{
                NSLog(@"Cookie synced: %@", newCookie.name);
            }];
        }
    }
}

@end