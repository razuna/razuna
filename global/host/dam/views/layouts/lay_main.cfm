<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfoutput>
<cfcontent reset="true">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
<head>
<title>Razuna Enterprise Digital Asset Management</title>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<!---
<cfheader name="Expires" value="#GetHttpTimeString(DateAdd('d', 1, Now()))#">
<cfheader name="PRAGMA" value="#GetHttpTimeString(DateAdd('d', 1, Now()))#">
--->
<cfheader name="Expires" value="#GetHttpTimeString(Now())#">
<cfheader name="CACHE-CONTROL" value="NO-CACHE, no-store, must-revalidate">
<cfheader name="PRAGMA" value="#GetHttpTimeString(Now())#">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<script language="JavaScript" type="text/javascript">var dynpath = '#dynpath#';</script>
<cfif application.razuna.isp>
<!--- JS --->
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jquery-1.6.4.min.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jquery.validate.min.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jquery.form.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jquery-ui-1.8.16.custom/js/jquery-ui-1.8.16.custom.min.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jqtree/jquery.tree.min.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jqtree/lib/jquery.cookie.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jqtree/plugins/jquery.tree.cookie.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/tag/js/tag-it.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/AC_QuickTime.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/flowplayer-3.2.6.min.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/global.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/notification/sticky.min.js" type="text/javascript"></script>
<script src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/chosen/chosen.jquery.min.js" type="text/javascript"></script>
<!--- CSS --->
<link rel="stylesheet" type="text/css" href="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jquery-ui-1.8.16.custom/css/smoothness/jquery-ui-1.8.16.custom.css" />
<link rel="stylesheet" type="text/css" href="//d3jcwo7gahoav9.cloudfront.net/razuna/css/main.css" />
<link rel="stylesheet" type="text/css" href="//d3jcwo7gahoav9.cloudfront.net/razuna/css/error.css" />
<link rel="stylesheet" type="text/css" href="//d3jcwo7gahoav9.cloudfront.net/razuna/css/tagit.css" />
<link rel="stylesheet" type="text/css" href="//d3jcwo7gahoav9.cloudfront.net/razuna/css/multiple-instances.css" />
<link rel="stylesheet" type="text/css" href="//d3jcwo7gahoav9.cloudfront.net/razuna/js/tag/css/jquery.tagit.css" />
<link rel="stylesheet" type="text/css" href="//d3jcwo7gahoav9.cloudfront.net/razuna/js/notification/sticky.min.css" />
<link rel="stylesheet" type="text/css" href="//d3jcwo7gahoav9.cloudfront.net/razuna/js/chosen/chosen.css" />
<!--- Favicon --->
<link rel="SHORTCUT ICON" href="//d3jcwo7gahoav9.cloudfront.net/razuna/favicon.ico" />
<cfelse>
<!--- JS --->
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.6.4.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.validate.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.form.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-ui-1.8.16.custom/js/jquery-ui-1.8.16.custom.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/videoplayer/js/flowplayer-3.2.6.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/AC_QuickTime.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jqtree/lib/jquery.cookie.js"></script>
<script type="text/javascript" src="#dynpath#/global/host/dam/js/global.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jqtree/jquery.tree.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jqtree/plugins/jquery.tree.cookie.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/tag/js/tag-it.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/notification/sticky.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/chosen/chosen.jquery.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.formparams.js"></script>
<!--- CSS --->
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/jquery-ui-1.8.16.custom/css/smoothness/jquery-ui-1.8.16.custom.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/main.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/error.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/videoplayer/css/multiple-instances.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/tag/css/jquery.tagit.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/tagit.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/notification/sticky.min.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/chosen/chosen.css" />
<!--- Favicon --->
<link rel="SHORTCUT ICON" href="#dynpath#/global/host/dam/images/favicon.ico" />
</cfif>
<!--- tooltip styling --->
<style>
##demotip {
	display:none;
	background:url(#dynpath#/global/js/tooltip_images/black.png);
	font-size:12px;
	height:60px;
	width:160px;
	padding:25px 25px 27px 25px;
	color:##fff;
	z-index: 10000;
}
.ui-widget { font-family: Helvetica Neue,Helvetica,Arial,Nimbus Sans L,sans-serif; font-size: 12px; }
.ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button { font-family: Helvetica Neue,Helvetica,Arial,Nimbus Sans L,sans-serif; font-size: 1em; }
##chromebar {
	height:30px;
	width:100%;
	background-color:yellow;
	font-family:'Lucida Grande', Helvetica, Arial, sans-serif;
	font-size:13px;
	color;grey;
}
.chzn-container .chzn-drop .chzn-results {
	height: 150px;
}
</style>
</head>
<body>
<cfif cgi.user_agent CONTAINS "chrome" AND structkeyexists(cookie,"razgc") AND cookie.razgc NEQ "off">
<div id="chromebar">
	<div style="float:left;padding:7px 0px 0px 20px;">Hey there, Google Chrome user. Check out the <a href="https://chrome.google.com/webstore/detail/gliobkpjddpabnjilfghpnkghmigjjcn" target="_blank">Razuna extension on the Chrome Web Store</a> to access your Razuna library directly.</div>
	<div style="float:right;padding:7px 15px 0px 0px;"><a href="##" onclick="document.cookie='razgc=off; expires=#dateformat(dateadd('m',3,now()), 'dddd, dd-mmm-yyyy')# 00:00:00 GMT; path=/';location.href='#myself#c.main&v=#createuuid()#';" style="padding-right:15px;">Don't notify me anymore</a> <a href="##" onclick="document.cookie='razgc=off; expires=#dateformat(dateadd('yyyy',1,now()), 'dddd, dd-mmm-yyyy')# 00:00:00 GMT; path=/';location.href='#myself#c.main&v=#createuuid()#';window.open('https://chrome.google.com/webstore/detail/gliobkpjddpabnjilfghpnkghmigjjcn');">Yes, install it</a></div>
</div>
</cfif>
<div id="container">
	<cfif session.indebt>
		<div id="outer">
			<div class="debt">
				<h2 style="color:red;">Account is locked</h2>
				<p>Unfortunately, your account is currently <span style="color:red;font-weight:bold;">locked due to unpaid invoices</span>. Before you can use Razuna again, your account has to be cleared with us.</p>
				<p>Until then, your account remains locked.</p>
				<p>If you are the account holder you will be able to pay the open invoices immediately otherwise please consult your account holder to clear the balance with us.</p>
				<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
					<p><!--- <a href="##" onclick="showwindow('#myself#ajax.account&userid=#session.theuserid#&hostid=#session.hostid#','Account',700,1);return false;"> ---><a href="https://secure.razuna.com/account.cfm?userid=#session.theuserid#&hostid=#session.hostid#" target="_blank">Go to Account & Invoices</a></p>
					<p><i>(After payment, simply refresh this page to access Razuna again)</i></p>
				</cfif>
			</div>
		</div>
	<cfelse>
		<div id="apDiv1">#trim( headercontent )#</div>
		<div id="apDiv3">#trim( leftcontent )#</div>
		<div id="apDiv4">#trim( maincontent )#</div>
		<!--- <div id="apDiv5">#trim( showcontent )#</div> --->
	</div>
	<div id="footer_drop">#trim( footerdrop )#</div>
</cfif>
<!--- <div id="footer">#trim( footercontent )#</div> --->
<!--- Window Div --->
<div id="thewindowcontent1" style="padding:10px;display:none;"></div>
<div id="thewindowcontent2" style="padding:10px;display:none;"></div>
<div id="thewindowcontent3" style="padding:10px;display:none;"></div>
<!--- Tooltip Div --->
<div id="demotip">&nbsp;</div>
<div id="div_forall" style="display:none;"></div>
<style>
/* override the arrow image of the tooltip */
##demotip.right {
	background:url(#dynpath#/global/js/tooltip_images/black.png);	
	//padding-top:40px;
	height:60px;
}
##demotip.right {
	background:url(#dynpath#/global/js/tooltip_images/black.png);
}
</style>
<!--- GS Code --->
<script type="text/javascript" charset="utf-8">
  var is_ssl = ("https:" == document.location.protocol);
  var asset_host = is_ssl ? "https://s3.amazonaws.com/getsatisfaction.com/" : "http://s3.amazonaws.com/getsatisfaction.com/";
  document.write(unescape("%3Cscript src='" + asset_host + "javascripts/feedback-v2.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript" charset="utf-8">
  var feedback_widget_options = {};
  feedback_widget_options.display = "overlay";  
  feedback_widget_options.company = "razuna";
  feedback_widget_options.placement = "hidden";
  feedback_widget_options.color = "##222";
  feedback_widget_options.style = "question";
  var feedback_widget = new GSFN.feedback_widget(feedback_widget_options);
</script>
<!--- Twitter --->
<script src="https://platform.twitter.com/widgets.js" type="text/javascript"></script>
<cfif application.razuna.isp>
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-27003876-1']);
  _gaq.push(['_setDomainName', 'razuna.com']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
</cfif>
</body>
</html>
</cfoutput>