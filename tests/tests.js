/* global CallDirectory */
/* eslint-disable no-alert, no-console */

exports.defineAutoTests = function() {
  describe("CallDirectory Object", function () {
    it("should exist", function() {
      expect(window.CallDirectory).toBeDefined();
    });
  });

  //TODO fix for emulator
  /* describe("isAvailable", function () {
    it("isAvailable schould be defined", function () {
      expect(window.CallDirectory.isAvailable).toBeDefined();
    });

    it("isAvailable schould return an result or error in callback", function (done) {
      window.CallDirectory.isAvailable( function (result) {
        expect(result).toBeDefined()
        console.log(result);
        done();
      }, function(result) {
        expect(result).toBeDefined();
        console.log(result);
        done();
      });
    });
  }); */

  describe("addIdentification", function () {
    it("addIdentification schould be defined", function () {
      expect(window.CallDirectory.addIdentification).toBeDefined();
    });

    it("addIdentification schould return success in callback", function (done) {
      let testData = [{label: "test", number: "1234567"}]
      window.CallDirectory.addIdentification(testData, function (result) {
        expect(result).toEqual("Numbers added to queue");
        done();
      }, function(result) {
        console.log(result);
        fail("addIdentification Error");
        done();
      });
    });
  });

  describe("removeIdentification", function () {
    it("removeIdentification schould be defined", function () {
      expect(window.CallDirectory.removeIdentification).toBeDefined();
    });

    it("removeIdentification schould return success in callback", function (done) {
      let testData = [{label: "test", number: "1234567"}]
      window.CallDirectory.removeIdentification(testData, function (result) {
        expect(result).toEqual("Numbers added to queue");
        done();
      }, function(result) {
        console.log(result);
        fail("removeIdentification Error");
        done();
      });
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
