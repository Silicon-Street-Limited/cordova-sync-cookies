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
    @try {
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
    } @catch (NSException *e) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:e.reason];
    } @finally {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void) SyncCookiesFromNS:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
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
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
    } @catch (NSException *e) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:e.reason];
    } @finally {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)SyncCookiesFromNS2:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    @try {
        // Ensure self.webView is a WKWebView
        if (![self.webView isKindOfClass:[WKWebView class]]) {
            @throw [NSException exceptionWithName:@"InvalidWebViewType" reason:@"self.webView is not a WKWebView" userInfo:nil];
        }

        WKWebView* wkWebView = (WKWebView*) self.webView;
        WKHTTPCookieStore* cookieStore = wkWebView.configuration.websiteDataStore.httpCookieStore;

        // Ensure cookieStore is not nil
        if (!cookieStore) {
            @throw [NSException exceptionWithName:@"InvalidWebViewConfiguration" reason:@"WKWebView configuration or httpCookieStore is nil" userInfo:nil];
        }

        // Retrieve all cookies from NSHTTPCookieStorage
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookies];

        // Create a dispatch group to wait for all cookies to be set
        dispatch_group_t group = dispatch_group_create();

        // Iterate through each cookie and set it in WKHTTPCookieStore
        for (NSHTTPCookie* cookie in cookies) {
            NSMutableDictionary* cookieDict = [cookie.properties mutableCopy];
            [cookieDict removeObjectForKey:NSHTTPCookieDiscard];
            NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:cookieDict];

            // Enter the dispatch group
            dispatch_group_enter(group);

            [cookieStore setCookie:newCookie completionHandler:^{
                NSLog(@"Cookie synced: %@", newCookie.name);
                // Leave the dispatch group
                dispatch_group_leave(group);
            }];
        }

        // Wait for all cookies to be set
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Cookies moved successfully"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });
    } @catch (NSException *e) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:e.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end