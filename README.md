# cordova-plugin-call-directory

[![Build Status](https://travis-ci.org/GEDYSIntraWare/cordova-plugin-call-directory.svg?branch=master)](https://travis-ci.org/GEDYSIntraWare/cordova-plugin-call-directory)

## Installation

`cordova plugin add cordova-plugin-call-directory --variable EXT_NAME="Cordova-Directory" --variable ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES="NO"`

## API & Examples

Global object `CallDirectory`

### isAvailable

```javascript
CallDirectory.isAvailable(null, (value) => {
          console.log("Calldirectory available", value);
          resolve(value);
        }, (err) => {
          reject(err);
        });
```

### addIdentification
Make sure to not add duplicate numbers.

```javascript
let indexItems = [{label: "Test", number: "001123456"}];

CallDirectory.addIdentification(indexItems, (value) => {
          console.log("Adding to call directory", value);
          resolve(value);
        }, (err) => {
          reject(err);
        });
```

### removeIdentification

```javascript
let indexItems = [{label: "Test", number: "001123456"}];

CallDirectory.removeIdentification(indexItems, (value) => {
                            console.log("Removing from call directory", value);
                            resolve(value);
                          }, (err) => {
                            reject(err);
                          });
```

### removeAllIdentification

```javascript
CallDirectory.removeAllIdentification(null, (value) => {
          console.log("Calldirectory remove All", value);
          resolve(value);
        }, (err) => {
          console.error(err);
          resolve(); //TODO ignore delete all error
        });
```

### reloadExtension

```javascript
CallDirectory.reloadExtension(undefined, (value) => {
          console.log("Refresh call directory", value);
          resolve(value);
        }, (err) => {
          console.error(err);
          reject(err);
        });
```

## Upcoming features

* Ionic Native support
* Testing
* Blocking numbers

## Error Codes
[Apple documentation](https://developer.apple.com/documentation/callkit/cxerrorcodecalldirectorymanagererror.code)

## Fix build problems in Xcode build settings

Run path: @executable_path/../../Frameworks for extension

Always embedd swift standard libraries: NO for extension

## Acknowledgements
Thanks to [David Strausz](https://github.com/DavidStrausz) whos [plugin](https://github.com/DavidStrausz/cordova-plugin-today-widget) is the base of all hooks, which add the extension during `cordova platform add ios`