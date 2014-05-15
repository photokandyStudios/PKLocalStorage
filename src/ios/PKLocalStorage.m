//
//  PKLocalStorage.m
//  Created by Kerri Shotts on 5/6/14.
//  Version 1.1.0
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

//ios6 base64 support from http://stackoverflow.com/questions/13245300/base64-encoding-for-nsstring
+ (NSString*)base64forData:(NSData*)theData 
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];

    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
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
    NSString *localStorageBase64;
    if ( [localStorage respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
      localStorageBase64 = [localStorageData base64EncodedStringWithOptions:0];
    } else {
      localStorageBase64 = [PKLocalStorage base64forData:localStorageData];
    }
    
    
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

