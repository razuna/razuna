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
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
<head>
<title><cfif application.razuna.whitelabel>#wl_html_title#<cfelse>Razuna Enterprise Digital Asset Management</cfif></title>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<!---
<cfheader name="Expires" value="#GetHttpTimeString(DateAdd('d', 1, Now()))#">
<cfheader name="PRAGMA" value="#GetHttpTimeString(DateAdd('d', 1, Now()))#">
--->
<!---
<cfheader name="Expires" value="#GetHttpTimeString(Now())#">
<cfheader name="CACHE-CONTROL" value="NO-CACHE, no-store, must-revalidate">
<cfheader name="PRAGMA" value="#GetHttpTimeString(Now())#">
--->
<cfset cacheTimeSeconds = 60*60*24>
<cfheader name="Expires" value="#GetHttpTimeString(DateAdd('s', cacheTimeSeconds, Now()))#">
<cfheader name="CACHE-CONTROL" value="max-age=#cacheTimeSeconds#">
<cfheader name="PRAGMA" value="public">
<cfheader name="P3P" value="CP=\\\"IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\\\"">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<script language="JavaScript" type="text/javascript">var dynpath = '#dynpath#';</script>
<!--- CSS --->
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/jquery-ui-1.10.3.custom/css/smoothness/jquery-ui-1.10.3.custom.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/chosen/chosen.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/main.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/videoplayer/css/multiple-instances.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/tag/css/jquery.tagit.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/tagit.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/notification/sticky.min.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/markitup/markitup/skins/simple/style.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/markitup/markitup/sets/html/style.css?_v=#attributes.cachetag#" />
<!--- JS --->
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-migrate-1.2.1.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.validate.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.form.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-ui-1.10.3.custom/js/jquery-ui-1.10.3.custom.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/videoplayer/js/flowplayer-3.2.6.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/AC_QuickTime.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jqtree/lib/jquery.cookie.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/host/dam/js/global.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jqtree/jquery.tree.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jqtree/plugins/jquery.tree.cookie.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/tag/js/tag-it.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/notification/sticky.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/chosen/chosen.jquery.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.formparams.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.lazyload.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.scrollstop.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/markitup/markitup/jquery.markitup.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/markitup/markitup/sets/html/set.js?_v=#attributes.cachetag#"></script>
<!--- Favicon --->
<cfif fileexists("#ExpandPath("../../")#global/host/favicon/#session.hostid#/favicon.ico")>
	<link rel="SHORTCUT ICON" href="#dynpath#/global/host/favicon/#session.hostid#/favicon.ico" />
<cfelse>
	<link rel="SHORTCUT ICON" href="#dynpath#/global/host/dam/images/favicon.ico" />
</cfif>
<link rel="apple-touch-icon" href="#dynpath#/global/host/dam/images/razuna_icon_114.png" />
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
.ui-autocomplete {
	max-height: 300px;
	overflow-y: auto;
	/* prevent horizontal scrollbar */
	overflow-x: hidden;
	/* add padding to account for vertical scrollbar */
	padding-right: 20px;
}
/* IE 6 doesn't support max-height
 * we use height instead, but this forces the menu to always be this tall
 */
* html .ui-autocomplete {
	height: 300px;
}
.ui-autocomplete-loading { background: white url('#dynpath#/global/host/dam/images/ui-anim_basic_16x16.gif') right center no-repeat; }
##chromebar {
	height:30px;
	width:100%;
	background-color:yellow;
	font-family:'Lucida Grande', Helvetica, Arial, sans-serif;
	font-size:13px;
	color:grey;
}
.chzn-container .chzn-drop .chzn-results {
	overflow: auto;
	max-height: 75px;
}
<cfif !cs.show_top_part>
##apDiv3, ##apDiv4 {
	top: 0px;
}
</cfif>
<!--- Custom CSS --->
<cfif application.razuna.whitelabel AND isdefined("wl_thecss")>
#wl_thecss#
</cfif>
</style>
</head>
<body>
<cfif cgi.http_host CONTAINS "razuna.com" AND res_account.account_type EQ 0>
	<div id="container">
		<div id="outer">
			<div class="debt">
				<h2>Thanks for trying Razuna! Your free trial has ended.</h2>
				<p>Don&##039;t worry &ndash; all your stuff is safe. Simply choose a plan to pick up right were you left off.</p>
				<p><a href="https://razuna.com/account.cfm?userid=#session.theuserid#&hostid=#session.hostid#">Go to my account and pick a plan</a></p>
				<p>If you have any questions please contact us at <a href="mailto:sales@razuna.com">sales@razuna.com</a></p>
			</div>
		</div>
	</div>
	</body>
	</html>
	<cfabort>
</cfif>
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
				<p>Click on the link below to get to your account settings and resolve your outstanding invoices now. Thank you!</p>
				<p><!--- <a href="##" onclick="showwindow('#myself#ajax.account&userid=#session.theuserid#&hostid=#session.hostid#','Account',700,1);return false;"> ---><a href="https://razuna.com/account.cfm?userid=#session.theuserid#&hostid=#session.hostid#">Go to Account & Invoices</a></p>
				<p><i>(After payment, you will be able to to access Razuna immediately again).</i></p>
				<p>If you have any questions please contact us at <a href="mailto:sales@razuna.com">sales@razuna.com</a></p>
			</div>
		</div>
	<cfelse>
		<cfif cs.show_top_part>
			<div id="apDiv1">#trim( headercontent )#</div>
		</cfif>
		<div style="padding-top:50px;">
			<div id="slide_off">
				<a href="##" onclick="hideshow('off');"><img src="#dynpath#/global/host/dam/images/arrow_slide_left.gif" border="0" width="15" height="15"></a>
			</div>
			<div id="slide_on" style="display:none;">
				<a href="##" onclick="hideshow('on');">
					<img src="#dynpath#/global/host/dam/images/arrow_slide_right.gif" border="0" width="15" height="15">
				</a>
			</div>
		</div>
		<div id="apDiv3">#trim( leftcontent )#</div>
		<div id="apDiv4">#trim( maincontent )#</div>
		<!--- <div id="apDiv5">#trim( showcontent )#</div> --->
	</div>
	<!--- <cfif cs.show_basket_part OR cs.show_favorites_part> --->
		<div id="footer_drop">#trim( footerdrop )#</div>
	<!--- </cfif> --->
</cfif>
<!--- <div id="footer">#trim( footercontent )#</div> --->
<!--- Window Div --->
<div id="thewindowcontent1" style="padding:10px;display:none;"></div>
<div id="thewindowcontent2" style="padding:10px;display:none;"></div>
<div id="thewindowcontent3" style="padding:10px;display:none;"></div>
<div id="videoPlayerDiv" style="display:none;">
<iframe id="introRazVideo" src="" width="800" height="450" frameborder="0" webkitallowfullscreen="" allowfullscreen="" mozallowfullscreen=""></iframe>
</div>
<!--- Tooltip Div --->
<div id="demotip">&nbsp;</div>
<div id="div_forall" style="display:none;"></div>
<style>
/* override the arrow image of the tooltip */
##demotip.right {
	background:url(#dynpath#/global/js/tooltip_images/black.png);	
	/*padding-top:40px;*/
	height:60px;
}
##demotip.right {
	background:url(#dynpath#/global/js/tooltip_images/black.png);
}
</style>
<cfif cgi.http_host CONTAINS "razuna.com">
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