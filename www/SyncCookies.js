var  SyncCookies = {

SyncCookiesWK : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookiesWK", []);
},

SyncCookiesNS : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookiesNS", []);
}

}

module.exports = SyncCookies;