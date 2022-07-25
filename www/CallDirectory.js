/* global cordova */

function CallDirectory() {
}

CallDirectory.prototype.isAvailable = function (successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "isAvailable",
    [{}]
  );
};

CallDirectory.prototype.addIdentification = function (objects, successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "addIdentification",
    [objects]
  );
};

CallDirectory.prototype.removeIdentification = function (objects, successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "removeIdentification",
    [objects]
  );
};

CallDirectory.prototype.removeAllIdentification = function (successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "removeAllIdentification",
    [{}]
  );
};

CallDirectory.prototype.getAllItems = function (successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "getAllItems",
    [{}]
  );
};

CallDirectory.prototype.reloadExtension = function (successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "reloadExtension",
    [{}]
  );
};

CallDirectory.prototype.getLog = function (successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "getLog",
    [{}]
  );
};

CallDirectory.prototype.openCallSettings = function (successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "openCallSettings",
    [{}]
  );
};

module.exports = new CallDirectory();
