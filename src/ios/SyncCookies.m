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

}

- (void)syncCookiesFromNS:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    @try {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
        WKHTTPCookieStore *cookieStore = dataStore.httpCookieStore;

        NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookies];
        for (NSHTTPCookie *cookie in cookies) {
            NSMutableDictionary *cookieProperties = [cookie.properties mutableCopy];
            [cookieProperties removeObjectForKey:NSHTTPCookieDiscard];

            NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];

            [cookieStore setCookie:newCookie completionHandler:^{
                NSLog(@"Cookie %@ set in WKHTTPCookieStore", newCookie.name);
            }];
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Cookies moved successfully"];
    } @catch (NSException *e) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:e.reason];
    } @finally {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
@end