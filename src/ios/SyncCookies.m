#import <Cordova/CDV.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@interface SyncCookies : CDVPlugin {
    
}

@property (nonatomic) NSMutableArray* stoppedTasks;

- (void)SyncCookiesFromWK:(CDVInvokedUrlCommand*)command;
- (void)SyncCookiesFromNS:(CDVInvokedUrlCommand*)command;
- (void)SyncCookiesFromNS2:(CDVInvokedUrlCommand*)command;

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

- (void) SyncCookiesFromNS2:(CDVInvokedUrlCommand*)command {

    @try{


   

    WKWebView* wkWebView = (WKWebView*) self.webView;

         NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

        // Retrieve all cookies
        NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookies];
  
            NSHTTPCookie* cookie;
            for(cookie in cookies) {
                NSMutableDictionary* cookieDict = [cookie.properties mutableCopy];
                [cookieDict removeObjectForKey:NSHTTPCookieDiscard]; // Remove the discard flag. If it is set (even to false), the expires date will NOT be kept.
                NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:cookieDict];
                [wkWebView.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:^{NSLog(@"Cookies synced");}];    
            }
       
         } @catch(NSException *e) {
           CDVPluginResult*   pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown exception"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }

  CDVPluginResult*   pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
 
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)SyncCookiesFromNS:(CDVInvokedUrlCommand*)command {
    @try {
        WKWebView* wkWebView = (WKWebView*) self.webView;
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

        // Retrieve all cookies
        NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookies];
        __block NSError *syncError = nil;
        __block NSInteger remainingCookies = cookies.count;

        for (NSHTTPCookie *cookie in cookies) {
            NSMutableDictionary *cookieDict = [cookie.properties mutableCopy];
            [cookieDict removeObjectForKey:NSHTTPCookieDiscard]; // Remove the discard flag. If it is set (even to false), the expires date will NOT be kept.
            NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieDict];

            [wkWebView.configuration.websiteDataStore.httpCookieStore setCookie:newCookie completionHandler:^{
                remainingCookies--;
                if (![wkWebView.configuration.websiteDataStore.httpCookieStore.cookies containsObject:newCookie]) {
                    syncError = [NSError errorWithDomain:@"com.example.cookieSync"
                                                    code:1
                                                userInfo:@{NSLocalizedDescriptionKey: @"Failed to sync cookie"}];
                }
                if (remainingCookies == 0) {
                    CDVPluginResult *pluginResult = nil;
                    if (syncError) {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:syncError.localizedDescription];
                    } else {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
                    }
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            }];
        }
    } @catch (NSException *e) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown exception"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end