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

  createActionButton("addIdent", function () {
    window.CallDirectory.addIdent(addIdentSuccess, addIdentError);

    function addIdentSuccess(result) {
      console.log(result);
      alert("CallDirectory available (" + result + ")");
    }

    function addIdentError(message) {
      alert(message);
    }
  });
};
