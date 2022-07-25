# cordova-plugin-call-directory

[![Build Status](https://travis-ci.org/GEDYSIntraWare/cordova-plugin-call-directory.svg?branch=master)](https://travis-ci.org/GEDYSIntraWare/cordova-plugin-call-directory)

## Installation

`cordova plugin add cordova-plugin-call-directory --variable EXT_NAME="Cordova-Directory" --variable ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES="NO"  --variable DEVELOPMENT_TEAM="TEAMID" --variable PROVISIONING_PROFILE="prov-id-5677-67567567.."`

If you encounter problems during installation please remove the iOS platform, add the plugin and add the iOS platform again. This plugins creates some source files and modifies config files in the Xcode project with installation hooks.

## API & Examples

Global object `CallDirectory`

### isAvailable

```javascript
CallDirectory.isAvailable(
  (value) => console.log(value),
  (err) => console.error(err));
```

### addIdentification
Make sure to not add duplicate numbers.

```javascript
let indexItems = [{label: "Test", number: "001123456"}];

CallDirectory.addIdentification(indexItems, 
  (value) => console.log(value),
  (err) => console.error(err));
```

### removeIdentification

```javascript
let indexItems = [{label: "Test", number: "001123456"}];

CallDirectory.removeIdentification(indexItems,
  (value) => console.log(value),
  (err) => console.error(err));
```

### removeAllIdentification

```javascript
CallDirectory.removeAllIdentification(
  (value) => console.log(value),
  (err) => {console.error(err));
```

### getAllItems

Returns an array with items: `{ label: "Test", number: "1234567890"}`

```javascript
CallDirectory.getAllItems(
  (value) => console.log(value),
  (err) => console.error(err))
```

### reloadExtension

Reload the extenstion after adding or removing items.

```javascript
CallDirectory.reloadExtension(
  (value) => console.log(value),
  (err) => console.error(err));
```

### getLog

Returns an object with log entries by extension and plugin log: `{ plugin: ["Delete..."..], extension: ["1234567890"..]}`

```javascript
CallDirectory.getLog(
  (value) => console.log(value),
  (err) => console.error(err))
```

### openCallSettings

Opens the settings to enable the CallDirectory extension.

```javascript
CallDirectory.openCallSettings(
  (value) => console.log(value),
  (err) => console.error(err))
```

## Error Codes
[Apple documentation](https://developer.apple.com/documentation/callkit/cxerrorcodecalldirectorymanagererror.code)

## Fix build problems in Xcode build settings

Run path: `@executable_path/../../Frameworks` for extension

Always embedd swift standard libraries: ``NO`` for extension

## Acknowledgements
Thanks to [@David Strausz](https://github.com/DavidStrausz) whose [plugin](https://github.com/DavidStrausz/cordova-plugin-today-widget) is the base of all hooks, which add the extension during `cordova platform add ios`
