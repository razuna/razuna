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
<cfset thefa = "c.folder_content_results">
<table border="0" width="100%" cellspacing="0" cellpadding="0" class="gridno">
	<tr>
		<!--- Icons and drop down menu --->
		<td align="left" width="1%" nowrap="true">
			<div id="tooltip" style="float:left;width:300px;">
				<cfif !attributes.cv>
					<!--- Select --->
					<a href="##" onClick="CheckAll('searchform#attributes.thetype#','x','storesearch#attributes.kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_select_desc")#">
						<!--- <div style="float:left;">
							<img src="#dynpath#/global/host/dam/images/checkbox.png" width="16" height="16" name="edit_1" border="0" />
						</div> --->
						<div style="float:left;padding-right:15px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("select_all")#</div>
					</a>
					<!--- Search --->
					<cfif attributes.folder_id NEQ 0 AND structkeyexists(attributes,"share") AND attributes.share NEQ "T">
						<a href="##" onclick="showwindow('#myself#c.search_advanced&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("folder_search")#',500,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("folder_search")#">
							<!--- <div style="float:left;">
								<img src="#dynpath#/global/host/dam/images/system-search-3.png" width="16" height="16" border="0" style="padding-left:2px;" />
							</div> --->
							<div style="float:left;padding-right:15px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("search_again")#</div>
						</a>
					</cfif>
				</cfif>
			</div>
		</td>
		<td>
			<div id="feedback_delete_search" style="white-space:no-wrap;"></div><div id="dummy_search" style="display:none;"></div>
		</td>
		<!--- Next and Back --->
		<td align="right" width="100%" nowrap="true">
			<cfif session.offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.offset - 1>
				<a href="##" onclick="backforth(#newoffset#);">&lt; #myFusebox.getApplicationData().defaults.trans("back")#</a> |
			</cfif>
			<cfset showoffset = session.offset * session.rowmaxpage>
			<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
			<cfif qry_filecount.thetotal GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_filecount.thetotal GT session.rowmaxpage AND NOT shownextrecord GTE qry_filecount.thetotal> | 
				<!--- For Next --->
				<cfset newoffset = session.offset + 1>
				<a href="##" onclick="backforth(#newoffset#);">#myFusebox.getApplicationData().defaults.trans("next")# &gt;</a>
			</cfif>
			<!--- Pages --->
			<cfif qry_filecount.thetotal GT session.rowmaxpage>
				<span style="padding-left:10px;">
					<cfset thepage = ceiling(qry_filecount.thetotal / session.rowmaxpage)>
					Page: 
						<select id="thepagelistsearch#attributes.kind#" onChange="pagelist('thepagelistsearch#attributes.kind#');">
							<cfloop from="1" to="#thepage#" index="i">
								<cfset loopoffset = i - 1>
								<option value="#loopoffset#"<cfif (session.offset + 1) EQ i> selected</cfif>>#i#</option>
							</cfloop>
						</select>
				</span>
			</cfif>
		</td>
		<!--- Sort by --->
		<td align="right" width="1%" nowrap="true">
			Sort by: 
			 <select name="selectsortbysearch#attributes.thetype#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="selectsortbysearch#attributes.thetype#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="changesortbysearch('selectsortbysearch#attributes.thetype#<cfif structkeyexists(attributes,"bot")>b</cfif>');" style="width:80px;">
			 	<option value="name"<cfif session.sortby EQ "name"> selected="selected"</cfif>>Name</option>
			 	<option value="kind"<cfif session.sortby EQ "kind"> selected="selected"</cfif>>Type of Asset</option>
			 	<option value="sizedesc"<cfif session.sortby EQ "sizedesc"> selected="selected"</cfif>>Size (Descending)</option>
			 	<option value="sizeasc"<cfif session.sortby EQ "sizeasc"> selected="selected"</cfif>>Size (Ascending)</option>
			 	<option value="dateadd"<cfif session.sortby EQ "dateadd"> selected="selected"</cfif>>Date Added</option>
			 	<option value="datechanged"<cfif session.sortby EQ "datechanged"> selected="selected"</cfif>>Last Changed</option>
			 	<option value="hashtag"<cfif session.sortby EQ "hashtag"> selected="selected"</cfif>>Same file</option>
			 </select>
		</td>
		<!--- Change the amount of images shown --->
		<td align="right" width="1%" nowrap="true">
			<cfif qry_filecount.thetotal GT session.rowmaxpage OR qry_filecount.thetotal GT 25>
				<select name="selectrowperpagesearch#attributes.kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="selectrowperpagesearch#attributes.kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="changerowmaxsearch('selectrowperpagesearch#attributes.kind#<cfif structkeyexists(attributes,"bot")>b</cfif>')" style="width:80px;">
					<option value="javascript:return false;">Show how many...</option>
					<option value="javascript:return false;">---</option>
					<option value="25"<cfif session.rowmaxpage EQ 25> selected="selected"</cfif>>25</option>
					<option value="50"<cfif session.rowmaxpage EQ 50> selected="selected"</cfif>>50</option>
					<option value="75"<cfif session.rowmaxpage EQ 75> selected="selected"</cfif>>75</option>
					<option value="100"<cfif session.rowmaxpage EQ 100> selected="selected"</cfif>>100</option>
				</select>
			</cfif>
		</td>
	</tr>
</table>

<!--- action with selection --->
<div id="folderselectionsearchform#attributes.thetype#" class="actiondropdown">
	<!--- Select all link --->
	<div style="float:left;padding-right:15px;padding-bottom:5px;" id="selectstore<cfif structkeyexists(attributes,"bot")>b</cfif>searchform#attributes.thetype#">
		#qry_filecount.thetotal# files select. <a href="##" onclick="CheckAllNot('searchform#attributes.thetype#');return false;">Deselect all</a>
	</div>
	<!--- Actions with selection icons --->
	<cfif cs.show_bottom_part>
		<a href="##" onclick="sendtobasket('searchform#attributes.thetype#');">
			<div style="float:left;">
				<img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" style="padding-right:3px;" />
			</div>
			<div style="float:left;padding-right:5px;">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</div>
		</a> 
	</cfif>
	<cfif (attributes.folder_id NEQ 0 AND attributes.folderaccess IS NOT "R") OR (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser())>
		<a href="##" onclick="batchaction('searchform#attributes.thetype#','all','#attributes.kind#','#attributes.folder_id#','move');">
			<div style="float:left;padding-left:5px;">
				<img src="#dynpath#/global/host/dam/images/application-go.png" width="16" height="16" border="0" style="padding-right:3px;" />
			</div>
			<div style="float:left;padding-right:5px;">#myFusebox.getApplicationData().defaults.trans("move")#</div>
		</a>
		<a href="##" onclick="batchaction('searchform#attributes.thetype#','all','#attributes.kind#','#attributes.folder_id#','batch');">
			<div style="float:left;padding-left:5px;">
				<img src="#dynpath#/global/host/dam/images/page-white_stack.png" width="16" height="16" border="0" style="padding-right:3px;" />
			</div>
			<div style="float:left;padding-right:5px;">#myFusebox.getApplicationData().defaults.trans("batch")#</div>
		</a>
		<cfif cs.tab_collections>
			<a href="##" onclick="batchaction('searchform#attributes.thetype#','all','#attributes.kind#','#attributes.folder_id#','chcoll');">
				<div style="float:left;padding-left:5px;">
					<img src="#dynpath#/global/host/dam/images/picture-link.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:5px;">#myFusebox.getApplicationData().defaults.trans("add_to_collection")#</div>
			</a>
		</cfif>
		<a href="##" onclick="batchaction('searchform#attributes.thetype#','all','#attributes.kind#','#attributes.folder_id#','exportmeta');">
			<div style="float:left;padding-left:5px;">
				<img src="#dynpath#/global/host/dam/images/report-go.png" width="16" height="16" border="0" style="padding-right:3px;" />
			</div>
			<div style="float:left;padding-right:5px;">#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#</div>
		</a>
		<cfif attributes.folderaccess EQ "X">
			<a href="##" onclick="batchaction('searchform#attributes.thetype#','all','#attributes.kind#','#attributes.folder_id#','delete');">
				<div style="float:left;padding-left:5px;">
					<img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" style="padding-right:2px;" />
				</div>
				<div style="float:left;">#myFusebox.getApplicationData().defaults.trans("delete")#</div>
			</a>
		</cfif>
	</cfif>
</div>

<script language="javascript">
	// Change the sortby
	function changesortbysearch(theselect){
		// Show loading bar
		$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
		// Get selected option
		var thesortby = $('##' + theselect + ' option:selected').val();
		$('###attributes.thediv#').load('#myself#c.search_simple', { sortby: thesortby, fcall: true, <cfloop list="#form.fieldnames#" index="i"><cfif i NEQ "sortby">#lcase(i)#:"#evaluate(i)#", </cfif></cfloop> }, function(){
				$("##bodyoverlay").remove();
			});
	}
	// Change the rowmax
	function changerowmaxsearch(theselect){
		// Show loading bar
		$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
		// Get selected option
		var themax = $('##' + theselect + ' option:selected').val();
		$('###attributes.thediv#').load('#myself#c.search_simple', { rowmaxpage: themax, fcall: true, <cfloop list="#form.fieldnames#" index="i"><cfif i NEQ "rowmaxpage">#lcase(i)#:"#evaluate(i)#", </cfif></cfloop> }, function(){
				$("##bodyoverlay").remove();
			});
	}
	// Change the pagelist
	function pagelist(theselect){
		// Show loading bar
		$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
		// Get selected option
		var themax = $('##' + theselect + ' option:selected').val();
		$('###attributes.thediv#').load('#myself#c.search_simple', { offset: themax, fcall: true, <cfloop list="#form.fieldnames#" index="i"><cfif i NEQ "offset">#lcase(i)#:"#evaluate(i)#", </cfif></cfloop> }, function(){
				$("##bodyoverlay").remove();
			});
	}
	// Change the pagelist
	function backforth(theoffset){
		// Show loading bar
		$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
		// Load
		$('###attributes.thediv#').load('#myself#c.search_simple', { offset: theoffset, fcall: true, <cfloop list="#form.fieldnames#" index="i"><cfif i NEQ "offset">#lcase(i)#:"#evaluate(i)#", </cfif></cfloop> }, function(){
				$("##bodyoverlay").remove();
			});
	}
</script>

</cfoutput>
