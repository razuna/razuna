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
	<!--- Storage Decision --->
	<!---
<cfif application.razuna.storage EQ "nirvanix">
		<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
	<cfelse>
--->
		<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<!--- </cfif> --->
	<!--- For Cloud Storage --->
	<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
		<cfset thevideourl = urldecode(attributes.cloud_url_org)>
		<cfset thevideourlnormal = attributes.cloud_url_org>
		<cfset thevideoimage = urldecode(attributes.cloud_url)>
	<cfelse>
		<cfset thevideourl = "#thestorage##attributes.path_to_asset#/#attributes.vid_filename#">
		<cfset thevideourlnormal = thevideourl>
		<cfset thevideoimage = "#thestorage##attributes.path_to_asset#/#attributes.vid_name_image#">
	</cfif>
	<cfswitch expression="#attributes.vid_extension#">
		<!--- Flash Player --->
		<cfcase value="mov,3gp,mpg4,m4v,swf,flv,f4v">
			<a class="flowplayerdetail" href="#thevideourl#" style="display:block;width:#attributes.vw#px;height:#attributes.vh#px;">
				<img src="#thevideoimage#" border="0">
			</a>
			<script language="javascript" type="text/javascript">
				// this simple call does the magic
				flowplayer("a.flowplayerdetail", "#dynpath#/global/videoplayer/flowplayer-3.2.7.swf", { 
				    clip: {
				    	autoBuffering: false, 
				    	autoPlay: true,
				    plugins: { 
				        controls: { 
				            all: false,  
				            play: true,  
				            scrubber: true,
				            volume: true,
				            mute: true,
				            time: true,
				            stop: true,
				            fullscreen: true
				        }
				    }
				}});
			</script>
			<br />
			Click on the image above to start watching the movie.<br>(If the video is not showing try to <a href="#thevideourlnormal#" target="_blank">watch it in QuickTime directly</a>.)
		</cfcase>
		<!--- HTML5 --->
		<cfcase value="mp4,ogv,webm">
			<video poster="#thevideoimage#" controls="true">
				<cfif attributes.vid_extension EQ "ogv">
					<source src="#thevideourl#" type="video/ogg" />
				<cfelseif attributes.vid_extension EQ "webm">
					<source src="#thevideourl#" type="video/webm" />
				<cfelseif attributes.vid_extension EQ "mp4">
					<source src="#thevideourl#" type="video/mp4" />
				</cfif>
			</video>
			<br />
			If the video does not play properly try to <a href="#thevideourlnormal#" target="_blank">watch it directly</a>.
		</cfcase>
		<!--- Not Flash Player compatible videos use the Quicktime player --->
		<cfdefaultcase>
			<a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#attributes.file_id#&v=o" target="_blank"><img src="#thevideoimage#" border="0" width="420" height="230"></a>
		</cfdefaultcase>
	</cfswitch>
</cfoutput>