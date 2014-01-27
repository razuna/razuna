Razuna-Receiver
===============

This is a standalone NodeJS application that you have to have running when you want your users to be able to upload with the Razuna Desktop Uploader.

Installation
------------

Install NodeJS. 

On Ubuntu this would be:

sudo apt-get update
sudo apt-get install -y python-software-properties python g++ make
sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install nodejs

Then within the razuna-receiver directory run:

npm install

In order to run the server use:

node app.js

or, if you want to keep the server running, you should use forver. Install forever first with:

npm install -g forever

Once done you can start the application with (this will run the razuna-receiver application in the background):

forever start -l forever.log -o out.log -e err.log app.js

Ubuntu Upstart Script
---------------------

The attached razuna-receiver file is a upstart script file. But it in the /etc/init.d/ directory and set the path correctly in the script. Then set it to execute with:

chmod +x /etc/init.d/razuna-receiver

and add it to upstart with:

update-rc.d razuna-receiver defaults

All commands are available as in:

service razuna-receiver start
service razuna-receiver status
service razuna-receiver restart
service razuna-receiver stop

The script starts forever automatically, so at the same time all forever commands work as well!

Configuration
-------------

You need to set the absolute path to the "uploaderfiles" folder in the config.json. Additionally, you can set the port this node server should run on.

That's it.
