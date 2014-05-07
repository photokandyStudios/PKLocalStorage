
var pkLocalStorage = {
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
    }
  },
  notifyOfPause: function() {
    this._notify ( "pause", this._onPauseHandlers );
  },
  notifyOfResume: function() {
    this._notify ( "resume", this._onResumeHandlers );
  }
}

module.exports = pkLocalStorage;
