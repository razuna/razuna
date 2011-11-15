<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    Matt Woodward - matt@mattwoodward.com

    This file is part of the Open BlueDragon Administrator.

    The Open BlueDragon Administrator is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Open BlueDragon Administrator is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License 
    along with the Open BlueDragon Administrator.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfsilent>
  <cfscript>
    contextPath = getPageContext().getRequest().getContextPath();
    
    if (contextPath is "/") {
      contextPath = "";
    }
    
    theSection = ListGetAt(CGI.SCRIPT_NAME, listLen(CGI.SCRIPT_NAME, "/") - 1, "/");
    thePage = ListLast(CGI.SCRIPT_NAME, "/");
  </cfscript>
</cfsilent>
<cfoutput>
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <title>Open BlueDragon Administrator</title>
      <meta http-equiv="X-UA-Compatible" content="IE-edge">
      <link rel="shortcut icon" href="#contextPath#/bluedragon/administrator/images/favicon.ico" />
      <link rel="stylesheet" href="#contextPath#/bluedragon/administrator/css/bootstrap.css" type="text/css" />
      <script src="#contextPath#/bluedragon/administrator/js/jquery-1.6.4.min.js" type="text/javascript"></script>      
      <script src="#contextPath#/bluedragon/administrator/js/bootstrap-alerts.js" type="text/javascript"></script>
    </head>

    <body style="padding-top:50px;">
      <div class="container">
	<div class="topbar-wrapper" style="z-index: 5;">
	  <div class="topbar">
	    <div class="topbar-inner">
              <div class="container">
		<a class="brand" href="#contextPath#/bluedragon/administrator/index.cfm" style="padding:0;">
		  <img src="#contextPath#/bluedragon/administrator/images/sd_openBD_32.png" border="0" height="32" width="32" style="border:0px; margin-top:5px; margin-left:20px; padding:0;" />
		</a>
		<span class="brand" style="margin-top:2px;">Open BlueDragon Administrator</span>
	      </div>
	    </div>
	  </div>
	</div>
	<div class="content">
	  #request.content#
	</div>
      </div>
    </body>
  </html>
</cfoutput>
