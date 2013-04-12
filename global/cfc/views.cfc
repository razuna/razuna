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
<cfcomponent output="false" extends="extQueryCaching">
<!--- FUNCTION: INIT --->
<!--- in parent-cfc --->

<!--- Create RSS --->
<cffunction name="rss" output="true" access="public">
<cfargument name="thestruct" type="struct">
<!--- If collection we have qry structs --->
<cfif session.iscol EQ "t">
	<cfset arguments.thestruct.qry_files = arguments.thestruct.qry_files.qry_files>
</cfif>
<!--- Storage Decision --->
<cfset thestorage = "#session.thehttp##cgi.http_host#/#cgi.context_path#/assets/#session.hostid#/">
<!--- The local host --->
<cfset theurl = "#session.thehttp#" & cgi.HTTP_HOST>
<!--- Create the RSS --->
<cfsavecontent variable="view"><cfoutput><?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<title>Razuna Feed (<cfif session.iscol EQ "F">Folder<cfelse>Collection</cfif>: #url.folder_id#)</title>
<description>Razuna MultiMedia Feed of <cfif session.iscol EQ "F">Folder<cfelse>Collection</cfif>: #url.folder_id#</description>
<link>#xmlformat("#theurl#/#cgi.script_name#?#cgi.query_string#")#</link>
<atom:icon>#theurl#/global/host/dam/images/razuna_logo-200.png</atom:icon>
<atom:link href="#xmlformat("#theurl#/#cgi.script_name#?#cgi.query_string#")#" rel="self" type="application/rss+xml" />
<cfif arguments.thestruct.qry_files.recordcount NEQ 0><cfloop query="arguments.thestruct.qry_files">
<item>
<title>#xmlformat(filename)#</title>
<description>#xmlformat(description)#</description>
<media:title type="plain">#xmlformat(filename)#</media:title>
<media:description type="plain">#xmlformat(description)#</media:description>
<media:keywords>#xmlformat(keywords)#</media:keywords>
<!--- Show assets --->
<cfif link_kind NEQ "url">
<!--- Cloud ---><cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
<guid>#xmlformat(cloud_url)#</guid>
<media:thumbnail url="#xmlformat(cloud_url)#"/>
<media:content url="#xmlformat(cloud_url_org)#" medium="<cfif kind EQ "img">image<cfelseif kind EQ "vid">video<cfelseif kind EQ "aud">audio<cfelse>document</cfif>"/>
<!--- Local ---><cfelse>
<cfif kind EQ "vid"><cfif arguments.thestruct.kind EQ "all">
<guid>#xmlformat("#thestorage##path_to_asset#/#filename_org#")#</guid>
<media:thumbnail url="#xmlformat("#thestorage##path_to_asset#/#filename_org#")#"/><cfelse>
<guid>#xmlformat("#thestorage##path_to_asset#/#vid_name_image#")#</guid>
<media:thumbnail url="#xmlformat("#thestorage##path_to_asset#/#vid_name_image#")#"/></cfif>
<cfelseif kind EQ "img">
<guid>#xmlformat("#thestorage##path_to_asset#/thumb_#id#.#ext#")#</guid>
<media:thumbnail url="#xmlformat("#thestorage##path_to_asset#/thumb_#id#.#ext#")#"/>
<cfelse>
<cfif kind EQ "PDF"><cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")><cfif FileExists("#ExpandPath("../../")#/assets/#session.hostid#/#path_to_asset#/#thethumb#") IS "no"><media:thumbnail url="#xmlformat("#theurl#/global/host/dam/images/icons/icon_#ext#.png")#"/><cfelse><media:thumbnail url="#xmlformat("#theurl#/assets/#session.hostid#/#path_to_asset#/#thethumb#")#"/></cfif><cfelse><cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><media:thumbnail url="#xmlformat("#theurl#/global/host/dam/images/icons/icon_txt.png")#"/><cfelse><media:thumbnail url="#xmlformat("#theurl#/global/host/dam/images/icons/icon_#ext#.png")#"/></cfif>
</cfif>
</cfif>
<cfif kind EQ "vid"><cfif arguments.thestruct.kind EQ "all"><cfset vidorg = replacenocase(filename_org,"jpg",ext,"all")>
<media:content url="#xmlformat("#thestorage##path_to_asset#/#vidorg#")#" medium="video"/><cfelse>
<media:content url="#xmlformat("#thestorage##path_to_asset#/#filename_org#")#" medium="video"/></cfif>
<cfelse>
<guid>#xmlformat("#thestorage##path_to_asset#/#filename_org#")#</guid>
<media:content url="#xmlformat("#thestorage##path_to_asset#/#filename_org#")#" medium="<cfif kind EQ "img">image<cfelseif kind EQ "aud">audio<cfelse>document</cfif>"/>
</cfif>
</cfif>
<cfelse>
<guid>#xmlformat(link_path_url)#</guid>
<media:thumbnail url="#xmlformat(link_path_url)#"/>
<media:content url="#xmlformat(link_path_url)#" medium="<cfif kind EQ "img">image<cfelseif kind EQ "vid">video<cfelseif kind EQ "aud">audio<cfelse>document</cfif>"/>
</cfif>
</item>
</cfloop></cfif>
</channel>
</rss></cfoutput>
</cfsavecontent>
<!--- Return --->
<cfreturn view />
</cffunction>

<!--- Create XLS --->
<cffunction name="xls" output="true" access="public">
<cfargument name="thestruct" type="struct">
	<!--- If collection we have qry structs --->
	<cfif session.iscol EQ "t">
		<cfset arguments.thestruct.qry_files = arguments.thestruct.qry_files.qry_files>
	</cfif>
	<!--- Only select the columns we need to show --->
	<cfquery dbtype="query" name="qry">
	SELECT id, filename, description, keywords<cfif arguments.thestruct.kind EQ "all">, kind</cfif>, path_to_asset, cloud_url, cloud_url_org
	FROM arguments.thestruct.qry_files
	</cfquery>
	<!--- Write temp filename --->
	<cfset var view = createuuid("") & ".xls">
	<!--- Write the XLS to the temp dir --->
	<cfspreadsheet action="write" filename="#GetTempDirectory()#/#view#" overwrite="true" query="#qry#" sheetname="text" >
	<!--- Return --->
	<cfreturn view />
</cffunction>

<!--- Create DOC --->
<cffunction name="doc" output="true" access="public">
<cfargument name="thestruct" type="struct">
	<!--- If collection we have qry structs --->
	<cfif session.iscol EQ "t">
		<cfset arguments.thestruct.qry_files = arguments.thestruct.qry_files.qry_files>
	</cfif>
	<!--- Storage Decision --->
	<cfset thestorage = "#session.thehttp##cgi.http_host#/#cgi.context_path#/assets/#session.hostid#/">
	<!--- The local host --->
	<cfset theurl = "#session.thehttp#" & cgi.HTTP_HOST>
	<!--- Write temp filename --->
	<!--- <cfset var view = createuuid() & ".doc"> --->
	<!--- Write doc --->
<cfsavecontent variable="view"><cfoutput>
<html xmlns:w="urn:schemas-microsoft-com:office:word">
<!--- Head tag instructs Word to start up a certain way, specifically in
print view. --->
    <head>
        <xml>
         <w:WordDocument>
            <w:View>Print</w:View>
            <w:SpellingState>Clean</w:SpellingState>
            <w:GrammarState>Clean</w:GrammarState>
            <w:Compatibility>
             <w:BreakWrappedTables/>
             <w:SnapToGridInCell/>
             <w:WrapTextWithPunct/>
             <w:UseAsianBreakRules/>
            </w:Compatibility>
            <w:DoNotOptimizeForBrowser/>
         </w:WordDocument>
        </xml>
    </head>
<body>
<cfloop query="arguments.thestruct.qry_files">
	<table border="0" width="500">
		<tr>
			<th colspan="3" style="BACKGROUND-COLOR: yellow;">#filename#</th>
		</tr>
		<tr>
			<td rowspan="2">
				<cfif link_kind NEQ "url">
					<!--- Cloud --->
					<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
						<img src="#cloud_url#" border="0" />
					<!--- Local --->
					<cfelse>
						<cfif kind EQ "vid">
							<cfif arguments.thestruct.kind EQ "all">	
								<img src="#thestorage##path_to_asset#/#filename_org#" border="0" />
							<cfelse>
								<!--- <cfset vidorg = replacenocase(filename_org,ext,"jpg","all")> --->
								<img src="#thestorage##path_to_asset#/#vid_name_image#" border="0" />
							</cfif>
						<cfelseif kind EQ "img">
							<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#" border="0" />
						<cfelse>
							<cfif kind EQ "PDF">
								<cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
								<cfif FileExists("#ExpandPath("../../")#/assets/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
									<img src="#theurl#/global/host/dam/images/icons/icon_#ext#.png" border="0" />
								<cfelse>
									<img src="#theurl#/assets/#session.hostid#/#path_to_asset#/#thethumb#" border="0" />
								</cfif>
							<cfelse>
								<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no">
									<img src="#theurl#/global/host/dam/images/icons/icon_txt.png" border="0" />
								<cfelse>
									<img src="#theurl#/global/host/dam/images/icons/icon_#ext#.png" border="0" />
								</cfif>
							</cfif>
						</cfif>
					</cfif>
				<cfelse>
					<img src="#link_path_url#" border="0" />
				</cfif>
			</td>
			<td valign="top" width="70">Description:</td>
			<td align="left" width="430">#description#</td>
		</tr>
		<tr>
			<td valign="top" width="70">Keywords:</td>
			<td align="left" width="430">#keywords#</td>
		</tr>
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>
	</table>
	
</cfloop>
    <!--- Create a page break microsoft style (took hours to find this) 

    <br clear="all"
style="page-break-before:always;mso-break-type:page-break" />
    Next page goes here--->
</body>
</html></cfoutput>
</cfsavecontent> 
	<!--- Return --->
	<cfreturn view />
</cffunction>

</cfcomponent>