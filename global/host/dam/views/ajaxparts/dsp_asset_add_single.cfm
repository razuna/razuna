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
<!---
<cfif cgi.http_user_agent CONTAINS "windows" OR cgi.http_user_agent CONTAINS "safari" AND cgi.http_user_agent DOES NOT CONTAIN "chrome">
	<cfset session.pluploadruntimes = "flash,html5,silverlight">
<cfelse>
--->
	<cfset session.pluploadruntimes = "html5,flash,silverlight">
<!--- </cfif> --->
<cfif structkeyexists(attributes,"pluploadruntimes")>
	<cfset session.pluploadruntimes = attributes.pluploadruntimes>
</cfif>
<cfdump var="#session.pluploadruntimes#">
<!--- The url to this page --->
<cfif structkeyexists(attributes,"_w")>
	<cfset theaddurl = "document.location.href='#myself#c.asset_add_single&folder_id=#session.fid#&_w=t">
<cfelse>
	<cfset theaddurl = "#myself#c.asset_add_single&folder_id=#attributes.folder_id#&nopreview=#attributes.nopreview#">
</cfif>
<cfoutput>
<div>
	<iframe src="#myself#c.asset_add_upload&folder_id=#attributes.folder_id#&nopreview=#attributes.nopreview#&av=#attributes.av#" frameborder="false" scrolling="false" style="border:0px;width:100%;height:400px;padding:0px;margin:0px;"></iframe>
	<cfif attributes.nopreview EQ 0>		
		<cfif structkeyexists(attributes,"_w")>
			<a href="##" onclick="#theaddurl#';" style="float:right;">
		<cfelse>
			<a href="##" onclick="$('##addsingle').load('#theaddurl#');" style="float:right;">
		</cfif>Restart uploading again</a>
	</cfif>
	<br />
	If the uploader does not perform well then maybe switching to another runtime could help?<br />Switch to: 
<cfif structkeyexists(attributes,"_w")>
	<a href="##" onclick="#theaddurl#&pluploadruntimes=html5&v=#createuuid()#';">Html5</a> | <a href="##" onclick="#theaddurl#&pluploadruntimes=flash&v=#createuuid()#';">Flash</a> | <a href="##" onclick="#theaddurl#&pluploadruntimes=silverlight&v=#createuuid()#';">Silverlight</a> | <a href="##" onclick="#theaddurl#&pluploadruntimes=html4&v=#createuuid()#';">Html4</a>
<cfelse>
	<a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=html5&v=#createuuid()#');">Html5</a></cfif> | <a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=flash&v=#createuuid()#');">Flash</a> | <a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=silverlight&v=#createuuid()#');">Silverlight</a> | <a href="##" onclick="$('##addsingle').load('#theaddurl#&pluploadruntimes=html4&v=#createuuid()#');">Html4</a>
</div>
</cfoutput>