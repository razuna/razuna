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
	<div id="tabsfolder_tab">
		<ul>
			<!--- If we are a collection show the list of collections else the content of folder --->
			<cfif attributes.iscol EQ "F">
				<li><a href="##content" onclick="loadcontent('content','#myself##xfa.fcontent#&folder_id=#attributes.folder_id#&kind=all');" rel="prefetch prerender">#defaultsObj.trans("folder_content")# (#arraySum(qry_fileTotalAllTypes['cnt'])#)</a></li>
				<cfloop query="qry_fileTotalAllTypes">
					<cfif qry_fileTotalAllTypes.cnt GT 0>
						<cfif ext EQ "img">
							<cfif cs.tab_images>
								<li><a href="##img" onclick="loadcontent('img','#myself##xfa.fimages#&folder_id=#attributes.folder_id#&kind=img');" rel="prefetch prerender">#defaultsObj.trans("folder_images")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "vid">
							<cfif cs.tab_videos>
								<li><a href="##vid" onclick="loadcontent('vid','#myself##xfa.fvideos#&folder_id=#attributes.folder_id#&kind=vid');" rel="prefetch">#defaultsObj.trans("folder_videos")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "aud">
							<cfif cs.tab_audios>
								<li><a href="##aud" onclick="loadcontent('aud','#myself##xfa.faudios#&folder_id=#attributes.folder_id#&kind=aud');" rel="prefetch">#defaultsObj.trans("folder_audios")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "doc">
							<cfif cs.tab_doc>
								<li><a href="##doc" onclick="loadcontent('doc','#myself##xfa.ffiles#&folder_id=#attributes.folder_id#&kind=doc');" rel="prefetch">#defaultsObj.trans("folder_word")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "xls">
							<cfif cs.tab_xls>
								<li><a href="##xls" onclick="loadcontent('xls','#myself##xfa.ffiles#&folder_id=#attributes.folder_id#&kind=xls');" rel="prefetch">#defaultsObj.trans("folder_excel")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "pdf">
							<cfif cs.tab_pdf>
								<li><a href="##pdf" onclick="loadcontent('pdf','#myself##xfa.ffiles#&folder_id=#attributes.folder_id#&kind=pdf');" rel="prefetch">#defaultsObj.trans("folder_pdf")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "other">
							<cfif cs.tab_other>
								<li><a href="##other" onclick="loadcontent('other','#myself##xfa.ffiles#&folder_id=#attributes.folder_id#&kind=other');" rel="prefetch">#defaultsObj.trans("folder_others")# (#cnt#)</a></li>
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
			<cfelse>
				<li><a href="##content" onclick="loadcontent('content','#myself##xfa.collectionslist#&folder_id=#attributes.folder_id#&kind=content');" rel="prefetch">#defaultsObj.trans("header_collections")#</a></li>
			</cfif>
			<!--- If user or admin has folderaccess x --->
			<cfif attributes.folderaccess EQ "x">
				<!--- Folder properties --->
				<li><a href="##properties" onclick="loadcontent('properties','#myself##xfa.fproperties#&folder_id=#attributes.folder_id#&theid=#attributes.folder_id#');" rel="prefetch">#defaultsObj.trans("folder_properties")#</a></li>
				<cfif attributes.iscol EQ "F">
					<!--- Sharing --->
					<li><a href="##sharing" onclick="loadcontent('sharing','#myself##xfa.fsharing#&folder_id=#attributes.folder_id#&theid=#attributes.folder_id#');" rel="prefetch">#defaultsObj.trans("tab_sharing_options")#</a></li>
					<!--- Widgets --->
					<li><a href="##widgets" onclick="loadcontent('widgets','#myself#c.widgets&col_id=&folder_id=#attributes.folder_id#');" rel="prefetch">#defaultsObj.trans("header_widget")#</a></li>
				</cfif>
			</cfif>
		</ul>
		
		<div id="content">#defaultsObj.loadinggif("#dynpath#")#</div>
		<cfif attributes.iscol EQ "F">
			<cfloop query="qry_fileTotalAllTypes">
				<cfif qry_fileTotalAllTypes.cnt GT 0>
					<cfif ext EQ "img">
						<div id="img"></div>
					</cfif>
					<cfif ext EQ "vid">
						<div id="vid"></div>
					</cfif>
					<cfif ext EQ "aud">
						<div id="aud"></div>
					</cfif>
					<cfif ext EQ "doc">
						<div id="doc"></div>
					</cfif>
					<cfif ext EQ "xls">
						<div id="xls"></div>
					</cfif>
					<cfif ext EQ "pdf">
						<div id="pdf"></div>
					</cfif>
					<cfif ext EQ "other">
						<div id="other"></div>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		<!--- If user or admin has folderaccess x --->
		<cfif attributes.folderaccess EQ "x">
			<!--- Properties --->
			<div id="properties">#defaultsObj.loadinggif("#dynpath#")#</div>
			<cfif attributes.iscol EQ "F">
				<!--- Sharing --->
				<div id="sharing">#defaultsObj.loadinggif("#dynpath#")#</div>
				<div id="widgets">#defaultsObj.loadinggif("#dynpath#")#</div>
			</cfif>
		</cfif>
		<div id="content_search_all" style="display:none;">#defaultsObj.loadinggif("#dynpath#")#</div>
	</div>

<script type="text/javascript">
	jqtabs("tabsfolder_tab");
	<cfif attributes.iscol EQ "F">
		loadcontent('content','#myself##xfa.fcontent#&folder_id=#attributes.folder_id#');
	<cfelse>
		loadcontent('content','#myself##xfa.collectionslist#&folder_id=#attributes.folder_id#&kind=content');
	</cfif>
</script>
</cfoutput>
