var  SyncCookies = {

SyncCookiesWK : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookiesWK", []);
},

SyncCookiesNS : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "SyncCookiesNS", []);
},

test : function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "SyncCookies", "test", []);
}

}

module.exports = SyncCookies;