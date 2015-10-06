The OpenBD Manual is located for public consumption at [http://openbd.org/manual/](http://openbd.org/manual/)

 

Getting Started
---------------

As the manual runs on top of the WWW site of OpenBD there is a couple items you'll need to do in order to get this running locally. A couple of simple steps and you can be up and running.

The OpenBD manual is mainly powered by the engine itself. If you download this code and put it on top your current install of OpenBD, you'll only get the functions and tags related to the build of OpenBD that you are running. The main manual located at [http://openbd.org/manual/](http://openbd.org/manual/) is running from the most recent nightly build of OpenBD, so you may see some tags that are not in your build.

There are two ways to run this code:

1. Clone/download this repostory and put the content on top of an exisiting
    running OpenBD web app. Just put the contents inside a folder of your web
    app, say {Your-Root}/manual
2. Clone/download this repository and have it as a standalone web app


### Standalone Web App Instructions

If you wish to run the manual on it's own you'll need to:

1. Have the ability to run an OpenBD server. We suggest using the [JettyDesktop launcher](https://github.com/aw20/jettydesktop) - instructions on use located at the [JettyDesktop Wiki](https://github.com/aw20/jettydesktop/wiki)
2. Clone/Download the repository
3. Download a copy of [OpenBD](http://openbd.org/downloads/), preferably the nightly build war file
    1. Download the war file
    2. Rename to openbd.zip
    3. Take a copy of the WEB-INF and place in the root of your cloned manual folder


Contributing
------------

All contributions are welcome to this manual and we hope you can take time to add valuable items that other developers will find useful.

To contribute to the manual, make a fork of the code and create pull requests for each item you wish to contribute. Pull requests will be reviewed and merged, or feedback maybe given. We will acknowledge every person who contributes to the
manual.

We also recommend an issue be created before you embark on anything major, so any discussion around the item can be had before hand and also to track comments, etc.


As previously stated a majority of the manual is powered from the engine itself, so you may not be able to make changes to certain items in the manual. But you can add additional information to the manual via include files that are included after the built output in corresponding tag or function outputs.

For example:

The [arrayEach() function](http://openbd.org/manual/?/function/arrayeach) shows the heading extra on the page after the
calling section. This page is powered by the include file /pages/functioncode/arrayeach.inc
