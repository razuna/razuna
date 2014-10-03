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
<cfif cgi.http_user_agent CONTAINS "chromeframe" OR cgi.http_user_agent CONTAINS "msie">
	<cfset session.pluploadruntimes = "flash,silverlight">
<cfelse>
	<cfset session.pluploadruntimes = "html5,flash,silverlight">
</cfif>
<cfif structkeyexists(attributes,"pluploadruntimes")>
	<cfset session.pluploadruntimes = attributes.pluploadruntimes>
</cfif>
<!--- The url to this page --->
<cfif structkeyexists(attributes,"_w")>
	<cfset theaddurl = "document.location.href='#myself#c.asset_add_single&folder_id=#session.fid#&_w=t">
<cfelse>
	<cfset theaddurl = "#myself#c.asset_add_single&folder_id=#attributes.folder_id#&nopreview=#attributes.nopreview#">
	<cfif structkeyexists(attributes,"fromshare")>
		<cfset theaddurl = "#theaddurl#&fromshare=true">
	</cfif>
</cfif>
<cfoutput>
<div>
	<!--- RAZ-2907 check the condition for bulk upload versions--->
	<cfif !structkeyexists(attributes,"file_id")>
	<iframe src="#myself#c.asset_add_upload&folder_id=#attributes.folder_id#&nopreview=#attributes.nopreview#&av=#attributes.av#&v=#createuuid()#<cfif structkeyexists(attributes,"fromshare")>&fromshare=true</cfif>" frameborder="false" scrolling="false" style="border:0px;width:100%;height:400px;padding:0px;margin:0px;"></iframe>
	<cfelse>
	<iframe src="#myself#c.asset_add_upload&folder_id=#attributes.folder_id#&file_id=#attributes.file_id#&nopreview=#attributes.nopreview#&extjs=T&tempid=#attributes.tempid#&type=#attributes.type#" frameborder="false" scrolling="false" style="border:0px;width:100%;height:400px;padding:0px;margin:0px;"></iframe>
	</cfif>
	<cfif attributes.nopreview EQ 0>
		<div  style="text-align:center;">
		<cfif structkeyexists(attributes,"_w")>
			<input type="button" onclick="#theaddurl#';" class="awesome medium grey" value="#myFusebox.getApplicationData().defaults.trans("uploader_restart")#" itle="#myFusebox.getApplicationData().defaults.trans("uploader_restart_info")#"/>
		<cfelse>
			<input type="button" onclick="$('##addsingle').load('#theaddurl#');" class="awesome medium grey" value="#myFusebox.getApplicationData().defaults.trans("uploader_restart")#" title="#myFusebox.getApplicationData().defaults.trans("uploader_restart_info")#"/>
		</cfif>
		</div>
	</cfif>

	<cfif cgi.http_user_agent DOES NOT CONTAIN "chromeframe" AND cgi.http_user_agent DOES NOT CONTAIN "msie">
		<br />
		#myFusebox.getApplicationData().defaults.trans("uploader_switch")#
		<cfif structkeyexists(attributes,"_w")>
			<a href="##" onclick="#theaddurl#&pluploadruntimes=html5';">Html5</a> | <a href="##" onclick="#theaddurl#&pluploadruntimes=flash';">Flash</a> | <a href="##" onclick="#theaddurl#&pluploadruntimes=silverlight';">Silverlight</a> | <a href="##" onclick="#theaddurl#&pluploadruntimes=html4';">Html4</a>
		<cfelse>
			<a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=html5');">Html5</a> | <a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=flash');">Flash</a> | <a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=silverlight');">Silverlight</a> | <a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=html4');">Html4</a>
		</cfif>
	<cfelse>
		<br />
		#myFusebox.getApplicationData().defaults.trans("uploader_switch")#
		<cfif structkeyexists(attributes,"_w")>
			<a href="##" onclick="#theaddurl#&pluploadruntimes=flash';">Flash</a> | <a href="##" onclick="#theaddurl#&pluploadruntimes=silverlight';">Silverlight</a> | <a href="##" onclick="#theaddurl#&pluploadruntimes=html4';">Html4</a>
		<cfelse>
			<a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=flash');">Flash</a> | <a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=silverlight');">Silverlight</a> | <a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=html4');">Html4</a>
		</cfif>
	</cfif>
</div>
<div style="clear:both;"></div>
</cfoutput>