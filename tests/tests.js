/* global CallDirectory */
/* eslint-disable no-alert, no-console */

exports.defineAutoTests = function() {
  describe("CallDirectory Object", function () {
    it("should exist", function() {
      expect(window.CallDirectory).toBeDefined();
    });
  });
};

exports.defineManualTests = function (contentEl, createActionButton) {

  createActionButton("isAvailable", function () {
    window.CallDirectory.isAvailable(isAvailableSuccess, isAvailableError);

    function isAvailableSuccess(result) {
      console.log(result);
      alert("CallDirectory available (" + result + ")");
    }

    function isAvailableError(message) {
      alert(message);
    }
  });
};
