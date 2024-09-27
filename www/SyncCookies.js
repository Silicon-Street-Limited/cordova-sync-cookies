var  SyncCookies = {

SyncCookiesWK : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookiesWK", []);
},

SyncCookiesFromNS : function (successCallback, errorCallback) {
     cordova.exec(successCallback, errorCallback, "SyncCookies", "syncCookiesFromNS", []);
},

test : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "test", []);
}

}

module.exports = SyncCookies;