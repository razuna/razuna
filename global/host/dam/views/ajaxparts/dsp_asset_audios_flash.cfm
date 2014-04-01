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
<!--- If asset has expired then show appropriate message --->
<cfif isdefined("qry_detail_aud.detail.expiry_date_actual") AND isdate(qry_detail_aud.detail.expiry_date_actual) AND qry_detail_aud.detail.expiry_date_actual lt now()>
	Asset has expired. Please contact administrator to gain access to this asset.<cfabort>
</cfif>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<cfoutput>
<script type="text/javascript" src="#dynpath#/global/js/AC_QuickTime.js"></script>
<script type="text/javascript" src="#dynpath#/global/videoplayer/js/flowplayer-3.2.6.min.js"></script>
<style>
body { 
	text-align: center; /* for IE */ 
}

div##wrapper { 
	text-align: left; /* reset text alignment */ 
	margin-left: auto; 
	margin-right: auto;
	width: 450px;
	margin-top: 100px;
}
</style>
</head>
<body>
<div id="wrapper">
	<!--- Storage Decision --->
	<!---
<cfif application.razuna.storage EQ "nirvanix">
		<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
	<cfelse>
--->
		<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<!--- </cfif> --->
	<!--- Path to the audio file --->
	<cfif attributes.link_kind EQ "">
		<cfset audiopath = "#thestorage##attributes.path_to_asset#/#attributes.aud_name#">
	<cfelseif attributes.link_kind EQ "url">
		<cfset audiopath = attributes.link_path_url>
	<cfelseif attributes.link_kind EQ "lan">
		<cfset thefinalname = listfirst(attributes.aud_name,".")>
		<cfset audiopath = "#thestorage##attributes.path_to_asset#/#thefinalname#.mp3">
		<cfset attributes.aud_extension = "mp3">
	</cfif>
	<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
		<cfset audiopath = attributes.cloud_url_org>
	<cfelseif application.razuna.storage EQ "akamai">
		<cfset audiopath = arguments.thestruct.akaurl & arguments.thestruct.akaaud & "/" & attributes.aud_name>
	</cfif>
	<!--- Switch --->
	<cfswitch expression="#attributes.aud_extension#">
		<!--- Flash Player --->
		<cfcase value="mp3">
			<div class="flowplayerdetail" style="display:block;width:450px;height:20px;" href="#urlencodedformat(audiopath)#"></div>
			<script language="javascript" type="text/javascript">
				// this simple call does the magic
				flowplayer("div.flowplayerdetail", "#dynpath#/global/videoplayer/flowplayer-3.2.7.swf", { 
				     // fullscreen button not needed here 
					plugins: { 
					    controls: { 
					        fullscreen: false, 
					        height: 20
					    } 
					}, 
					clip: { 
					    autoPlay: false, 
					    // optional: when playback starts close the first audio playback 
					    onBeforeBegin: function() { 
					        $f("player").close(); 
					    } 
					} 
				});
			</script>
		</cfcase>
		<!--- OGG / HTML5 default player --->
		<cfcase value="ogg">
			<audio controls="controls">
				<source src="#audiopath#" type="audio/ogg" />
			  	<!--- <source src="song.mp3" type="audio/mp3" /> --->
			  	Your browser does not support the <code>HTML5 video</code> element. Please download the file!
			</audio>
			<br>
			If the audio above does not play, you can also <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud" target="_blank">get it directly from here.</a>
		</cfcase>
		<!--- Quicktime --->
		<cfcase value="wav,m4a,m4b,m4p,au,amr">
			<script language="JavaScript" type="text/javascript">
			QT_WriteOBJECT('#audiopath#','450','30','',
			'target','myself',
			'controller','true',
			'autoplay', 'false',
			'loop','false',
			'bgcolor','##FFFFFF'
			);
			</script>
		</cfcase>
		<!--- Nothing above --->
		<cfdefaultcase>
			<cfif NOT structkeyexists(attributes,"fromdetail")>
				<cflocation url="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud">
			</cfif>
		</cfdefaultcase>
	</cfswitch>
</cfoutput>
</div>
</body>
</html>