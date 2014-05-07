//
//  PKLocalStorage.m
//  Created by Kerri Shotts on 5/6/14.
//  Version 1.0.0
//
/*
Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

#import "PKLocalStorage.h"
#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"

@implementation PKLocalStorage

-(void) pluginInitialize
{
  // add listeners for pause/resume
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationWillEnterForegroundNotification  object:nil];
 

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:self.webView];
}
-(void)pageDidLoad: (NSNotification *) notice
{
  // check localStorage cache
  NSArray *dirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesPath = dirList[0];
  NSString *localStorageCache = [cachesPath stringByAppendingFormat:@"/localStorageCache.json"];
  NSError *err = nil;
  UIWebView *webView;
  if (notice) { webView = [notice object]; } else { webView = self.webView; }
  
  NSString *localStorage = @"";
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:localStorageCache isDirectory:NO])
  {
    localStorage = [NSString stringWithContentsOfFile:localStorageCache encoding:NSUTF8StringEncoding error:&err];

    NSData *localStorageData = [localStorage dataUsingEncoding:NSUTF8StringEncoding];
    NSString *localStorageBase64 = [localStorageData base64EncodedStringWithOptions:0];
    
    NSMutableString *js = [[NSMutableString alloc] init];
    [js appendFormat:@"(function() { var x = JSON.parse(atob('%@')); var c=0; for (var i in x) { if (x.hasOwnProperty(i)) { localStorage[i] = x[i]; c++; } } console.log('LocalStorage Restore Complete'); return c;})();", localStorageBase64];
    NSString * result = [webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"LocalStorage Restore Complete.");
    
    [[NSFileManager defaultManager] removeItemAtPath:localStorageCache error:&err];
  }
}

-(void) onPause
{
  NSArray *dirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesPath = dirList[0];
  NSError *err = nil;

  NSString *localStorage = [self.webView stringByEvaluatingJavaScriptFromString:@"window.PKLocalStorage.notifyOfPause();  JSON.stringify(localStorage)"];
  [localStorage writeToFile:[cachesPath stringByAppendingFormat:@"/localStorageCache.json"] atomically:YES encoding:NSUTF8StringEncoding error:&err];
}

-(void) onResume
{
  [self.webView stringByEvaluatingJavaScriptFromString:@"window.PKLocalStorage.notifyOfResume();"];
  NSArray *dirList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesPath = dirList[0];
  NSString *localStorageCache = [cachesPath stringByAppendingFormat:@"/localStorageCache.json"];
  NSError *err = nil;
  if ([[NSFileManager defaultManager] fileExistsAtPath:localStorageCache isDirectory:NO])
  {
    [[NSFileManager defaultManager] removeItemAtPath:localStorageCache error:&err];
  }
}

@end

