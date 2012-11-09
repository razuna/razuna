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
<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
<cfoutput>
	<div id="tabs_mini">
		<ul>
			<li><a href="##thecontent" onclick="" rel="prefetch prerender">Folder &amp; Files</a></li>
			<li><a href="##thesearch" onclick="" rel="prefetch prerender">Search</a></li>
		</ul>
		<div id="thecontent">
			<!--- Foldername --->
			<cfif qry_foldername NEQ "">
				<div id="foldername">/ <a href="#myself#c.mini_browser&folder_id=0" style="text-decoration:underline;">Home</a><cfloop list="#qry_breadcrumb#" delimiters=";" index="i"> / <a href="#myself#c.mini_browser&folder_id=#ListGetAt(i,2,"|")#" style="text-decoration:underline;">#ListGetAt(i,1,"|")#</a></cfloop></div>
				<div style="float:right;font-weight:bold;"><cfif attributes.folderaccess NEQ "R"><a href="##" onclick="showwindow('#attributes.folder_id#');" style="text-decoration:underline;">Upload</a></cfif></div>
				<div style="clear:both;"></div>
			</cfif>
			<div>There are #qry_subfolders.recordcount# folders and #qry_filecount.thetotal# files here.</div>
			<br />
			<cfloop query="qry_subfolders">
				<div id="folders">
					<div><a href="#myself#c.mini_browser&folder_id=#folder_id#"><img src="#dynpath#/global/host/dam/images/folder-blue-mini.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"></a></div>
					<div id="foldername_list"><a href="#myself#c.mini_browser&folder_id=#folder_id#">#folder_name#</a></div>
				</div>
				<!--- <div style="clear:both;"</div> --->
			</cfloop>
			<cfloop query="qry_files">
				<div id="files">
					<div id="filesthumbs">
						<a href="##" onclick="slidefile('#id#','#kind#');return false;">
							<cfif kind EQ "img">
								<!--- Show assets --->
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<cfif cloud_url NEQ "">
											<img src="#cloud_url#" border="0">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
										</cfif>
									<cfelse>
										<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#?#hashtag#" border="0">
									</cfif>
								<cfelse>
									<img src="#link_path_url#" border="0" width="120">
								</cfif>
							<cfelseif kind EQ "vid">
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<cfif cloud_url NEQ "">
											<img src="#cloud_url#" border="0">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
										</cfif>
									<cfelse>
										<img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0">
									</cfif>
								<cfelse>
									<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
								</cfif>
							<cfelseif kind EQ "aud">
								<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">
							<cfelse>
								<!--- If it is a PDF we show the thumbnail --->
								<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND ext EQ "PDF">
									<cfif cloud_url NEQ "">
										<img src="#cloud_url#" border="0">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
									</cfif>
								<cfelseif application.razuna.storage EQ "local" AND ext EQ "PDF">
									<cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
									<cfif FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
										<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
									<cfelse>
										<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/#thethumb#" width="120" border="0">
									</cfif>
								<cfelse>
									<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="120" height="120" border="0"></cfif>
								</cfif>
							</cfif>
						</a>
					</div>
					<div id="foldername_list"><a href="##" onclick="slidefile('#id#','#kind#');return false;">#filename#</a></div>
					<div style="clear:both;"></div>
					<!--- This div loads dynamically --->
					<div id="slider#id#" style="display:none;">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
				</div>
			</cfloop>
		</div>
		<!--- Search --->
		<div id="thesearch">
			<form name="form_minisearch" id="form_minisearch">
				<input type="hidden" name="searchthetype" id="searchthetype" value="all" >
				<input type="text" name="searchtext" id="searchtext" placeholder="Enter your search term and hit enter" />
			</form>
			<div style="clear:both;"></div>
			<!--- Show results --->
			<div id="minisearchstatus"></div>
			<div id="minisearchresults"></div>
		</div>
	</div>
	<!--- JS --->
	<script type="text/javascript">
		// Create tabs
		$('##tabs_mini').tabs();
		// Slide file
		function slidefile(theid,thekind){
			$('##slider' + theid).load('#myself#c.mini_browser_files&file_id=' + theid + '&kind=' + thekind, function(){
				$('##slider' + theid).slideToggle('slow');
			})
		}
		// Fire off search
		$('##form_minisearch').submit(
			function(){
				checkentry();
				return false;
			}
		);
	</script>
</cfoutput>