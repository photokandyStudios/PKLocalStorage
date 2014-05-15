# PKLocalStorage

Version 1.1.0, Kerri Shotts (kerrishotts@gmail.com)

`localStorage` is not synchronized or flushed to disk during `pause` events on iOS. Furthermore, no native operations are permitted during a `pause` event, which means that there is no mechanism, *what-so-ever* that supports the saving of app state during a `pause` event in order to prevent data loss should the app be terminated while in the background.

This is described [here](https://groups.google.com/forum/#!msg/PhoneGap/wsP4w3Sm0YQ/fAnyUu_sZosJ) in the PhoneGap Google Group.

Although incredibly ugly, this plugin attempts to rectify that problem in an easy-to-use plugin. It does two things:

* It can call `pause` and `resume` handlers that are guaranteed to execute during the event. That is, you can do any JavaScript you desire during the handler *except* `setTimeout` or any native operations. While this initially sounds limiting, it *does* permit the writing of data to `localStorage`.
* It will save any changes made to `localStorage` during these `pause` events to the app's cache directory in a file named `localStorageCache.json`. If the app is resumed without an intervening termination, the file is then deleted. But if the app is terminated prior to being resumed, the file is read and loaded back into `localStorage`. This means that by your app can check `localStorage` and know that data has been persisted.

## Caveats

It would be far better if there was a mechanism by which we could force the sqlite database that backs `localStorage` to `synchronize` or `flush` its contents with/to persistent storage. Instead, the following occurs:

* `JSON.stringify(localStorage)` - this is a hack from moment one. Should `localStorage` contain a lot of data, this operation may become problematic.
* `JSON.parse(atob(data))` - when starting up, the cached `localStorage` data is passed over to JavaScript in **base 64**. This is a second hack on top of the first, but it ensures that the data is transferred without having to worry about escaping symbols. It *does* double the memory requirements. Therefore, if the cache has stored `5mb` of data, then JavaScript is passed a string that's a little over `10mb` large. Probably not going to work.
* `for ... in` - once the data is passed to JavaScript, it is iterated over in order to insert the data into `localStorage`. If there are a lot of items, this is going to take awhile.
* This plugin does not attempt to do anything should the app be forcibly terminated (or crash) in any other situation. That is to say, this plugin works only with the backgrounding of the application, not the forcible termination of the application.

For the above reasons, this plugin is probably best used in the following situations:

* Games or other apps that don't need to store a lot of user settings, but do want to persist those changes should the application be paused.
* Games or other apps that store their content using the File API (or some other persistent storage) but need a mechanism for tracking any unsaved changes should the app be paused.

## Usage

`localStorage` is persisted by default, with no further action on your part. However, it is important to recognize that the Cordova `pause` event has probably *not* fired by the time this plugin runs, and so you can't use it to store data to `localStorage`.

To do that (or be notified when the app has resumed), do the following:

```
PKLocalStorage.addPauseHandler ( function () { localStorage["editInProgress"] = someData; } );
PKLocalStorage.addResumeHandler ( function () { localStorage.removeItem("editInProgress"); } );
```

Do **NOT** exeute any native operations or any operation that uses `setTimeout` or the like. They will not execute until the app is resumed.

To remove handlers, you can use `removePausehandler` and `removeResumeHandler`.

## Repository

Available on [Github](https://github.com/photokandyStudios/PKLocalStorage). Contributions welcome!

## LICENSE

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

## Change Log

```
1.0.0  First Release
1.1.0  iOS 6 would crash due to lack of base64EncodedStringWithOptions on NSData. Fixed. 
```