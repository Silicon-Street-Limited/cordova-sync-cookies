#import <Cordova/CDV.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@interface SyncCookies : CDVPlugin {
    
}

@property (nonatomic) NSMutableArray* stoppedTasks;

- (void)SyncCookies:(CDVInvokedUrlCommand*)command;

@end

@implementation SyncCookies

- (void) SyncCookies:(CDVInvokedUrlCommand*)command {
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

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
