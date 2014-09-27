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
	<cfif !listfindnocase('r,w,x',attributes.folderaccess)>
		You do not have the necessary permissions to access this folder. Please contact your administrator if you feel this is in error.
		<cfabort>
	</cfif>
	<div id="tabsfolder_tab">
		<ul>
			<!--- If we are a collection show the list of collections else the content of folder --->
			<cfif attributes.iscol EQ "F">
				<li><a href="##content" onclick="loadcontent('content','#myself##xfa.fcontent#&folder_id=#attributes.folder_id#&kind=all&iscol=#attributes.iscol#');" rel="prefetch prerender">#myFusebox.getApplicationData().defaults.trans("folder_content")# (#arraySum(qry_fileTotalAllTypes['cnt'])#)</a></li>
				<cfloop query="qry_fileTotalAllTypes">
					<cfif qry_fileTotalAllTypes.cnt GT 0>
						<cfif ext EQ "img">
							<cfif cs.tab_images>
								<li><a href="##img" onclick="loadcontent('img','#myself##xfa.fimages#&folder_id=#attributes.folder_id#&kind=img&iscol=#attributes.iscol#');" rel="prefetch prerender">#myFusebox.getApplicationData().defaults.trans("folder_images")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "vid">
							<cfif cs.tab_videos>
								<li><a href="##vid" onclick="loadcontent('vid','#myself##xfa.fvideos#&folder_id=#attributes.folder_id#&kind=vid&iscol=#attributes.iscol#');" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("folder_videos")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "aud">
							<cfif cs.tab_audios>
								<li><a href="##aud" onclick="loadcontent('aud','#myself##xfa.faudios#&folder_id=#attributes.folder_id#&kind=aud&iscol=#attributes.iscol#');" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("folder_audios")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "doc">
							<cfif cs.tab_doc>
								<li><a href="##doc" onclick="loadcontent('doc','#myself##xfa.ffiles#&folder_id=#attributes.folder_id#&kind=doc&iscol=#attributes.iscol#');" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("folder_word")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "xls">
							<cfif cs.tab_xls>
								<li><a href="##xls" onclick="loadcontent('xls','#myself##xfa.ffiles#&folder_id=#attributes.folder_id#&kind=xls&iscol=#attributes.iscol#');" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("folder_excel")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "pdf">
							<cfif cs.tab_pdf>
								<li><a href="##pdf" onclick="loadcontent('pdf','#myself##xfa.ffiles#&folder_id=#attributes.folder_id#&kind=pdf&iscol=#attributes.iscol#');" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("folder_pdf")# (#cnt#)</a></li>
							</cfif>
						</cfif>
						<cfif ext EQ "other">
							<cfif cs.tab_other>
								<li><a href="##other" onclick="loadcontent('other','#myself##xfa.ffiles#&folder_id=#attributes.folder_id#&kind=other&iscol=#attributes.iscol#');" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("folder_others")# (#cnt#)</a></li>
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
			<cfelse>
				<li><a href="##content" onclick="loadcontent('content','#myself##xfa.collectionslist#&folder_id=#attributes.folder_id#&kind=content&iscol=#attributes.iscol#');" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("header_collections")#</a></li>
				<li><a href="##contentrel" onclick="loadcontent('contentrel','#myself##xfa.collectionslist#&folder_id=#attributes.folder_id#&kind=content&iscol=#attributes.iscol#&released=true');" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("header_collections")# Released</a></li>
			</cfif>
		</ul>
		
		<div id="content">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
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
		<cfelse>
			<!--- This is the collection released div --->
			<div id="contentrel">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		</cfif>
		<!--- Search results --->
		<div id="content_search_all" style="display:none;">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
	</div>

<script type="text/javascript">
	jqtabs("tabsfolder_tab");
	<cfif attributes.iscol EQ "F" OR attributes.iscol EQ "">
		loadcontent('content','#myself##xfa.fcontent#&folder_id=#attributes.folder_id#&iscol=#attributes.iscol#');
	<cfelse>
		loadcontent('content<cfif structKeyExists(attributes,"released") AND attributes.released>rel</cfif>','#myself##xfa.collectionslist#&folder_id=#attributes.folder_id#&kind=content&iscol=#attributes.iscol#<cfif structKeyExists(attributes,"released") AND attributes.released>&released=#attributes.released#</cfif>');
		<cfif structKeyExists(attributes,"released") AND attributes.released>
			var index = $('##tabsfolder_tab div.ui-tabs-panel').length-1;
			$('##tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
			//$('##tabsfolder_tab').tabs('select','##contentrel');
		</cfif>
	</cfif>
</script>
</cfoutput>
