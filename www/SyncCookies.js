/* global cordova */

function SyncCookies() {
}


SyncCookies.prototype.SyncCookiesWK = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookiesWK", []);
}


SyncCookies.prototype.SyncCookiesNS = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookiesNS", []);
}


module.exports = new SyncCookies();