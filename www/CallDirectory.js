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

module.exports = new CallDirectory();
