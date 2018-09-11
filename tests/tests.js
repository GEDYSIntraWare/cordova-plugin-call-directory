/* global CallDirectory */
/* eslint-disable no-alert, no-console */

exports.defineAutoTests = function() {
  describe("CallDirectory Object", function () {
    it("should exist", function() {
      expect(window.CallDirectory).toBeDefined();
    });
  });

  describe("isAvailable", function () {
    it("isAvailable schould be defined", function () {
      expect(window.CallDirectory.isAvailable).toBeDefined();
    });

    //TODO Test functions which require extension
    /* it("isAvailable schould return an result or error in callback", function (done) {
      window.CallDirectory.isAvailable( function (result) {
        expect(result).toBeDefined()
        console.log(result);
        done();
      }, function(result) {
        expect(result).toBeDefined();
        console.log(result);
        done();
      });
    }); */
  });

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

  describe("getAllItems", function () {
    it("getAllItems schould be defined", function () {
      expect(window.CallDirectory.getAllItems).toBeDefined();
    });

    it("getAllItems schould return success in callback", function (done) {
      let testData = [{label: "test", number: "1234567"}]
      window.CallDirectory.getAllItems(function (result) {
        console.log(result, testData);
        expect(result).toEqual(testData);
        done();
      }, function(result) {
        console.log(result);
        fail("getAllItems Error");
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
        expect(result).toEqual("Numbers added to delete queue");
        done();
      }, function(result) {
        console.log(result);
        fail("removeIdentification Error");
        done();
      });
    });
  });

  describe("removeAllIdentification", function () {
    it("removeAllIdentification schould be defined", function () {
      expect(window.CallDirectory.removeAllIdentification).toBeDefined();
    });
  });
  
  describe("reloadExtension", function () {
    it("reloadExtension schould be defined", function () {
      expect(window.CallDirectory.reloadExtension).toBeDefined();
    });
  });

  describe("getLog", function () {
    it("getLog schould be defined", function () {
      expect(window.CallDirectory.getLog).toBeDefined();
    });

    it("getLog schould return success in callback", function (done) {
      window.CallDirectory.getLog(function (result) {
        console.log(result);
        expect(result).toBeDefined()
        done();
      }, function (result) {
        console.log(result);
        fail("getLog Error");
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
