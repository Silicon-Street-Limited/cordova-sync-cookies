#import <Cordova/CDV.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@interface SyncCookies : CDVPlugin {
    
}

@property (nonatomic) NSMutableArray* stoppedTasks;

- (void)SyncCookiesFromWK:(CDVInvokedUrlCommand*)command;
- (void)SyncCookiesFromNS:(CDVInvokedUrlCommand*)command;

@property (nonatomic, strong) NSString* callbackId;
@end

@implementation SyncCookies

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
    

- (void)syncCookiesFromNS:(CDVInvokedUrlCommand*)command {
    NSHTTPCookieStorage *httpCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    WKHTTPCookieStore *wkCookieStore = webView.configuration.websiteDataStore.httpCookieStore;

    NSArray<NSHTTPCookie *> *cookies = httpCookieStorage.cookies;
    __block NSError *syncError = nil;

    for (NSHTTPCookie *cookie in cookies) {
        [wkCookieStore setCookie:cookie completionHandler:^(void) {
            // Check if the cookie was set successfully
            if (![wkCookieStore.cookies containsObject:cookie]) {
                syncError = [NSError errorWithDomain:@"com.example.cookieSync"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey: @"Failed to sync cookie"}];
            }
        }];
    }

    // Prepare the result to send back to Cordova
    CDVPluginResult *pluginResult = nil;
    if (syncError) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:syncError.localizedDescription];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }

    // Send the result back to Cordova
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end