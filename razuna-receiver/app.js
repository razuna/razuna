// Require
var fs = require('fs');
var express = require('express');
var request = require('request');
var uuid = require('node-uuid');
// Grab config file and set path to upload into
var configjson = fs.readFileSync(__dirname + '/config.json');
var jsonData = JSON.parse(configjson);
var uploadFolder = jsonData.uploadFolder;
var serverPort = jsonData.serverPort;
// Add express
var app = express();

// Receive files from the Desktop
app.post('/', function (req, res, next) {
  // Set variables
  var filename = req.query.filename;
  var apikey = req.query.apikey;
  var hostid = req.query.hostid;
  var folderid = req.query.folderid;
  var razurl = req.query.razurl;
  // What URL to call
  razurl = razurl + '/index.cfm';
  // Where to upload into
  var folder_path = uploadFolder + '/' + uuid.v4();
  // Create random folder
  try{
    fs.mkdirSync(folder_path, '775');
  } catch(e){}
  // Write to filesystem
  req.pipe(fs.createWriteStream( folder_path + '/' + filename ));
  // When write is done
  req.on('end', function(){
    res.send();
    console.log('File Upload done: ' + filename);
    console.log('Calling Razuna import!');
    // Post to Razuna server
    try{
      var form = request.post(razurl, requestCallback).form();
      form.append('fa' , 'c.w_import_from_uploader');
      form.append('apikey' , apikey);
      form.append('hostid' , hostid);
      form.append('theid' , folderid);
      form.append('folder_path' , folder_path);
      form.append('updater' , true);
    }
    catch(e){
      console.log('Oops, something is wrong calling the Razuna server!');
    }
    // Callback from post
    function requestCallback(error, response, body){
      // If there is no error and statuscode is 200
      if (!error && response.statusCode == 200) {
        console.log('Razuna URL called successfully');
        // Call to delete directories
        deleteDirectories();
      }
      else{
        console.log('Razuna ERROR ' + error);
      }
    }
  });
});

// Remove directories
function deleteDirectories(){
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
