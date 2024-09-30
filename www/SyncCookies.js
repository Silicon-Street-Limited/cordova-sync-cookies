var  SyncCookies = {

SyncCookiesFromWK : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookiesFromWK", []);
},

SyncCookiesFromNS : function (successCallback, errorCallback) {
     cordova.exec(successCallback, errorCallback, "SyncCookies", "syncCookiesFromNS", []);
},

test : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "test", []);
}

}

module.exports = SyncCookies;