/* global cordova */

function SyncCookies() {
}


SyncCookies.prototype.SyncCookies = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookies", []);
}

module.exports = new SyncCookies();