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
	<div id="tabs_mini">
		<ul>
			<li><a href="##thecontent" onclick="" rel="prefetch prerender">Folder &amp; Files</a></li>
			<li><a href="##thesearch" onclick="" rel="prefetch prerender">Search</a></li>
			<li><a href="##theupload" onclick="" rel="prefetch prerender">Upload</a></li>
		</ul>
	<div id="thecontent">
		<!--- Foldername --->
		<cfif qry_foldername NEQ "">
			<div id="foldername"><a href="#myself#c.mini_browser&folder_id=0">Home</a><cfloop list="#qry_breadcrumb#" delimiters=";" index="i"> / <a href="#myself#c.mini_browser&folder_id=#ListGetAt(i,2,"|")#">#ListGetAt(i,1,"|")#</a></cfloop>
			</div>
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
				<div><a href="##" onclick="slidefile('#id#','#kind#');return false;"><cfif kind EQ "img"><img src="#dynpath#/global/host/dam/images/image-x-generic.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"><cfelseif kind EQ "vid"><img src="#dynpath#/global/host/dam/images/video-x-generic.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"><cfelseif kind EQ "aud"><img src="#dynpath#/global/host/dam/images/audio-x-generic.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"><cfelse><img src="#dynpath#/global/host/dam/images/x-office-document-2.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"></cfif></a></div>
				<div id="foldername_list"><a href="##" onclick="slidefile('#id#','#kind#');return false;">#filename#</a></div>
				<!--- This div loads dynamically --->
				<div id="slider#id#" style="display:none;">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
			</div>
		</cfloop>
	</div>
	<div id="thesearch"></div>
	<div id="theupload"></div>
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
	</script>
</cfoutput>