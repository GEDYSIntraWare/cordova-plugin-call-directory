/* global cordova */

function CallDirectory() {
}

CallDirectory.prototype.isAvailable = function (objects, successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "isAvailable",
    [objects]
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

CallDirectory.prototype.removeAllIdentification = function (objects, successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "removeAllIdentification",
    [objects]
  );
};

CallDirectory.prototype.reloadExtension = function (objects, successCallback, errorCallback) {
  cordova.exec(
    successCallback,
    errorCallback,
    "CallDirectory",
    "reloadExtension",
    [objects]
  );
};

module.exports = new CallDirectory();
