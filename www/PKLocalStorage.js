/*
Kerri Shotts, (C) 2014, Version 1.0.0

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

var PKLocalStorage = {
  _onPauseHandlers: [],
  _onResumeHandlers: [],
  _addHandler: function _addHandler ( fn, handlerArray ) {
    handlerArray.push (fn);
  },
  addPauseHandler: function addPauseHandler ( fn ) {
    this._addHandler ( fn, this._onPauseHandlers );
  },
  addResumeHandler: function addResumeHandler ( fn ) {
    this._addHandler ( fn, this._onResumeHandlers );
  },
  _removeHandler: function _removeHandler ( fn, handlerArray ) {
    var i = handlerArray.indexOf(fn);
    if (i>-1) {
      handlerArray.splice (i, 1);
    }
  },
  removePauseHandler: function removePauseHandler ( fn ) {
    this._removeHandler ( fn, this._onPauseHandlers );
  },
  removeResumeHandler: function removeResumeHandler ( fn ) {
    this._removeHandler ( fn, this._onResumeHandlers );
  },
  _notify: function _notify ( event, handlers ) {
    handlers.forEach ( function (handler) {
      handler(event);
    });
  },
  notifyOfPause: function() {
    this._notify ( "pause", this._onPauseHandlers );
  },
  notifyOfResume: function() {
    this._notify ( "resume", this._onResumeHandlers );
  }
};

module.exports = PKLocalStorage;
