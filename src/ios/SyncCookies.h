

#import <Cordova/CDVPlugin.h>

@interface SyncCookies : CDVPlugin 

- (void)SyncCookiesFromWK:(CDVInvokedUrlCommand*)command;
- (void)SyncCookiesFromNS:(CDVInvokedUrlCommand*)command;

@end