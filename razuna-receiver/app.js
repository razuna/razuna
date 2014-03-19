// Require
var fs = require('fs');
var express = require('express');
var request = require('request');
var uuid = require('node-uuid');
var util = require('util');
// Grab config file and set path to upload into
var configjson = fs.readFileSync(__dirname + '/config.json');
var jsonData = JSON.parse(configjson);
var uploadFolder = jsonData.uploadFolder;
var serverPort = jsonData.serverPort;
var razunaServer = jsonData.razunaServer;
// Add express
var app = express();

global.current_timeout = 0;

var _MAX_TIMEOUT = 10000;
var _TIMEOUT_INTERVAL = 1000;


// Receive files from the Desktop
app.post('/', function (req, res, next) {

  // Set variables
  var original_filename = req.query.filename;
  var filename = original_filename;
  var apikey = req.query.apikey;
  var hostid = req.query.hostid;
  var folderid = req.query.folderid;
  var razurl = req.query.razurl;
  // What URL to call
  razurl = razunaServer;
  // Where to upload into
  var folder_path = uploadFolder + '/' + uuid.v4();
  // Create random folder
  try{
    fs.mkdirSync(folder_path, '775');
  } catch(e){}

  // TODO: This needs to be changed or as such that we pass the original file name to the Razuna API !!!!!!!!!!!!!
  // Grab the extension
  var posofdot = filename.lastIndexOf('.');
  var extension = (posofdot < 0) ? '' : filename.substr(posofdot);
  // Random id with extension
  var newname = uuid.v4() + extension;
  // Remove spaces
  newname = newname.replace(/\s/g, '');
  // Lowercase
  newname = newname.toLowerCase();

  var file_path = folder_path + '/' + newname;

  // writes the file to the file system
  req.pipe(fs.createWriteStream( file_path ));

  // When write is done
  req.on('end', function(){
    res.send();
    console.log('File Upload done: ' + filename + ' as ' + newname + ' at ' + file_path);
    console.log('Calling Razuna import!');
    // Post to Razuna server
    _postData(apikey, hostid, folderid, folder_path, filename, file_path, razurl, original_filename);

  });
});

var _postData = function(apikey, hostid, folderid, folder_path, filename, file_path, razurl, original_filename) {

    var _requestCallback = function(error, response, body) {
      // If there is no error and statuscode is 200
      if (!error && response.statusCode == 200) {
        console.log(util.format('Razuna URL called successfully, %s has been imported', original_filename));
        global.current_timeout = global.current_timeout <= 0 ? 0 : global.current_timeout - _TIMEOUT_INTERVAL;
        console.log('successful post to Razuna, now timeout set to : ', global.current_timeout);
        // Call to delete directories
        //deleteDirectories();
      } else{
        global.current_timeout = _MAX_TIMEOUT;
        console.log(util.format('error occurred while sending %s, time out set to : ', original_filename, global.current_timeout));
        // tryAgain
        _postData(apikey, hostid, folderid, folder_path, filename, file_path, razurl, original_filename);
        console.log('Razuna ERROR ', error);
      }
    };

    try{
      setTimeout( function() {
          var form = request.post(razurl, _requestCallback).form();
          form.append('fa' , 'c.w_import_from_uploader');
          form.append('apikey' , apikey);
          form.append('hostid' , hostid);
          form.append('theid' , folderid);
          form.append('folder_path' , folder_path);
          form.append('filename_org' , filename);
          form.append('file_path' , file_path);
          form.append('updater' , 'true');
        }, global.current_timeout);
      } catch(e) {
        console.log('Oops, something is wrong calling the Razuna server!');
      }
};

  // Remove directories
  function deleteDirectories() {
    var dirs = fs.readdirSync(uploadFolder);
    for (var d in dirs){
      fs.stat(uploadFolder + dirs[d], function(err, stats){
        if (err){
          console.log(err);
        }
        else{
          var livesUntil = new Date();
          if (stats.ctime < livesUntil.setHours(livesUntil.getHours() - 6)){
            // Call to recursivly remove files and folder
            rmDir(uploadFolder + dirs[d]);
            console.log('Deleted: ' + dirs[d]);
          }
        }
      });
    }
  }

  // Subfunction to remove directories
  function rmDir(dirPath) {
    try {
      var dirfiles = fs.readdirSync(dirPath);
    }
    catch(e) {
      return;
    }
    if (dirfiles.length > 0) {
      for (var i = 0; i < dirfiles.length; i++) {
        var filePath = dirPath + '/' + dirfiles[i];
        if (fs.statSync(filePath).isFile())
          fs.unlinkSync(filePath);
        else
          rmDir(filePath);
      }
    }
    fs.rmdirSync(dirPath);
  }


// Start Application
app.listen(serverPort);
console.log('Listening on port ' + serverPort + ' and waiting to receive files');
