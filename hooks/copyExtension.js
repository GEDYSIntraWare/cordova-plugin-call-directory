/* tslint:disable */

var fs = require('fs');
var path = require('path');

function log(logString, type) {
  var prefix;
  var postfix = '';
  switch (type) {
    case 'error':
      prefix = '\x1b[1m' + '\x1b[31m' + '💥 '; // bold, red
      throw new Error(prefix + logString + 'x1b[0m'); // reset
    case 'info':
      prefix =
        '\x1b[40m' +
        '\x1b[37m' +
        '\x1b[2m' +
        '☝️ [INFO] ' +
        '\x1b[0m\x1b[40m' +
        '\x1b[33m'; // fgWhite, dim, reset, bgBlack, fgYellow
      break;
    case 'start':
      prefix = '\x1b[40m' + '\x1b[36m'; // bgBlack, fgCyan
      break;
    case 'success':
      prefix = '\x1b[40m' + '\x1b[32m' + '✔ '; // bgBlack, fgGreen
      postfix = ' 🎉';
      break;
  }

  console.log(prefix + logString + postfix);
}

function getPreferenceValue (config, name) {
  var value = config.match(new RegExp('name="' + name + '" value="(.*?)"', "i"));
  if(value && value[1]) {
    return value[1];
  } else {
    return null;
  }
}

console.log('\x1b[40m');
log(
  'Running copyExtension hook, copying extension folder to platform ...',
  'start'
);

// http://stackoverflow.com/a/26038979/5930772
var copyFileSync = function(source, target) {
  var targetFile = target;

  // If target is a directory a new file with the same name will be created
  if (fs.existsSync(target)) {
    if (fs.lstatSync(target).isDirectory()) {
      targetFile = path.join(target, path.basename(source));
    }
  }

  fs.writeFileSync(targetFile, fs.readFileSync(source));
};
var copyFolderRecursiveSync = function(source, target) {
  var files = [];

  // Check if folder needs to be created or integrated
  var targetFolder = path.join(target, path.basename(source));
  if (!fs.existsSync(targetFolder)) {
    fs.mkdirSync(targetFolder);
  }

  // Copy
  if (fs.lstatSync(source).isDirectory()) {
    files = fs.readdirSync(source);
    files.forEach(function(file) {
      var curSource = path.join(source, file);
      if (fs.lstatSync(curSource).isDirectory()) {
        copyFolderRecursiveSync(curSource, targetFolder);
      } else {
        copyFileSync(curSource, targetFolder);
      }
    });
  }
};

function getCordovaParameter(variableName, contents) {
  var variable;
  if(process.argv.join("|").indexOf(variableName + "=") > -1) {
    var re = new RegExp(variableName + '=(.*?)(\||$))', 'g');
    variable = process.argv.join("|").match(re)[1];
  } else {
    variable = getPreferenceValue(contents, variableName);
  }
  return variable;
}

module.exports = function(context) {
  var Q = require('q');
  var deferral = new Q.defer();

  var contents = fs.readFileSync(
    path.join(context.opts.projectRoot, 'config.xml'),
    'utf-8'
  );

  var iosFolder = context.opts.cordova.project
    ? context.opts.cordova.project.root
    : path.join(context.opts.projectRoot, 'platforms/ios/');
  fs.readdir(iosFolder, function(err, data) {
    var projectFolder;
    var projectName;
    var srcFolder;
    // Find the project folder by looking for *.xcodeproj
    if (data && data.length) {
      data.forEach(function(folder) {
        if (folder.match(/\.xcodeproj$/)) {
          projectFolder = path.join(iosFolder, folder);
          projectName = path.basename(folder, '.xcodeproj');
        }
      });
    }

    if (!projectFolder || !projectName) {
      log('Could not find an .xcodeproj folder in: ' + iosFolder, 'error');
    }

    // Get the extension name and location from the parameters or the config file
    var EXT_NAME = getCordovaParameter("EXT_NAME", contents);
    var pluginPath = context.opts.plugin.dir;
    var extName = EXT_NAME || projectName.replace(/\s/g,'') + "Directory";

    if (pluginPath) {
        srcFolder = path.join(
          pluginPath,
          "src",
          "calldirectoryextension"
        );
    } else {
      log(
        'Missing plugin folder in ' + pluginPath + ' for: ' + extName,
        'error'
      );
    }
    if (!fs.existsSync(srcFolder)) {
      log(
        'Missing extension folder in ' + srcFolder + '. Should have the same name as your extension: ' + extName,
        'error'
      );
    }

    // Copy extension folder
    copyFolderRecursiveSync(
      srcFolder,
      path.join(context.opts.projectRoot, 'platforms', 'ios')
    );
    // Rename
    fs.renameSync(
      path.join(context.opts.projectRoot, 'platforms', 'ios', 'calldirectoryextension'),
      path.join(context.opts.projectRoot, 'platforms', 'ios', extName)
    );
    fs.renameSync(
      path.join(context.opts.projectRoot, 'platforms', 'ios', extName, 'calldirectory.entitlements'),
      path.join(context.opts.projectRoot, 'platforms', 'ios', extName, extName + '.entitlements')
    );
    fs.renameSync(
      path.join(context.opts.projectRoot, 'platforms', 'ios', extName, 'CallDirectory-Info.plist'),
      path.join(context.opts.projectRoot, 'platforms', 'ios', extName, extName + '-Info.plist')
    );
    log('Successfully copied extension folder!', 'success');
    console.log('\x1b[0m'); // reset

    deferral.resolve();
  });

  return deferral.promise;
};
