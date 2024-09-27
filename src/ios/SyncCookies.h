

#import <Cordova/CDVPlugin.h>

@interface SyncCookies : CDVPlugin 

- (void)SyncCookiesFromWK:(CDVInvokedUrlCommand*)command;
- (void)SyncCookiesFromNS:(CDVInvokedUrlCommand*)command;
- (void)SyncCookiesFromNS2:(CDVInvokedUrlCommand*)command;
- (void)test:(CDVInvokedUrlCommand*)command;

@end