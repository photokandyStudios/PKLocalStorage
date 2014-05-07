//
//  PKAppState.m
//  FilerV7
//
//  Created by Kerri Shotts on 5/6/14.
//
//

#import "PKAppState.h"
#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"

@implementation PKAppState

-(void) pluginInitialize
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationDidBecomeActiveNotification  object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:self.webView];
}
-(void)pageDidLoad: (NSNotification *) notice
{
  // check localStorage cache
  NSArray *dirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesPath = dirList[0];
  NSString *localStorageCache = [cachesPath stringByAppendingFormat:@"/localStorageCache.json"];
  NSError *err = nil;
  UIWebView *webView = [notice object];
  
  NSString *localStorage = @"";
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:localStorageCache isDirectory:NO])
  {
    localStorage = [NSString stringWithContentsOfFile:localStorageCache encoding:NSUTF8StringEncoding error:&err];
//    localStorage = [localStorage stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
//    localStorage = [localStorage stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
//    localStorage = [localStorage stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
//    localStorage = [localStorage stringByReplacingOccurrencesOfString:@"\r" withString:@""];

    NSData *localStorageData = [localStorage dataUsingEncoding:NSUTF8StringEncoding];
    NSString *localStorageBase64 = [localStorageData base64EncodedStringWithOptions:0];
    
    NSMutableString *js = [[NSMutableString alloc] init];
    [js appendFormat:@"(function() { var x = JSON.parse(atob('%@')); for (var i in x) { if (x.hasOwnProperty(i)) { localStorage[i] = x[i]; } } console.log('LocalStorage Restore Complete'); })();", localStorageBase64];
    [webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"LocalStorage Restore Complete.");
    
    [[NSFileManager defaultManager] removeItemAtPath:localStorageCache error:&err];
  }
}

-(void) onPause
{
  NSArray *dirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesPath = dirList[0];
  NSError *err = nil;

  NSString *localStorage = [self.webView stringByEvaluatingJavaScriptFromString:@"window.PKLocalStorage.notifyOnPause();  JSON.stringify(localStorage)"];
  [localStorage writeToFile:[cachesPath stringByAppendingFormat:@"/localStorageCache.json"] atomically:YES encoding:NSUTF8StringEncoding error:&err];
}

-(void) onResume
{
  NSArray *dirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesPath = dirList[0];
  NSString *localStorageCache = [cachesPath stringByAppendingFormat:@"/localStorageCache.json"];
  NSError *err = nil;
  if ([[NSFileManager defaultManager] fileExistsAtPath:localStorageCache isDirectory:NO])
  {
    [[NSFileManager defaultManager] removeItemAtPath:localStorageCache error:&err];
  }
  [self.webView stringByEvaluatingJavaScriptFromString:@"window.PKLocalStorage.notifyOnResume();"];
}

@end
