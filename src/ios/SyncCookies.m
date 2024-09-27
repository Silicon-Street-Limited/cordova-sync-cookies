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
    
   NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
    WKHTTPCookieStore *cookieStore = dataStore.httpCookieStore;

    NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        WKHTTPCookie *wkCookie = [[WKHTTPCookie alloc] initWithProperties:cookie.properties];
        [cookieStore setCookie:wkCookie completionHandler:^{
            NSLog(@"Cookie %@ set in WKHTTPCookieStore", cookie.name);
        }];
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end