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
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">

	<!--- Search Results --->
	<div id="loading_searchagain"></div>
	<div>
		<!--- Top Search Bar --->
		<div style="margin:0;padding:0;">
			<form action="#self#" method="post" id="form_searchsearch" name="form_searchsearch">
			<input type="hidden" name="#theaction#" value="c.search_simple">
			<input type="hidden" name="folder_id" value="#attributes.folder_id#">
			<input type="hidden" name="searchtext" id="s_searchtext" value="">
			<input type="hidden" name="listdocid" id="s_listdocid" value="#attributes.listdocid#">
			<input type="hidden" name="listimgid" id="s_listimgid" value="#attributes.listimgid#">
			<input type="hidden" name="listvidid" id="s_listvidid" value="#attributes.listvidid#">
			<input type="hidden" name="listaudid" id="s_listaudid" value="#attributes.listaudid#">
			<table border="0" width="100%" cellspacing="0" cellpadding="0" class="tablepanel">
				<tr>
					<th colspan="6">#defaultsObj.trans("refine_search")#</th>
				</tr>
				<tr>
					<td valign="top">
						<input type="radio" id="s_newsearch" name="newsearch" value="t"<cfif attributes.newsearch EQ "t"> checked="true"</cfif>> <a href="##" onclick="clickcbk('form_searchsearch','newsearch',0)" style="text-decoration:none;">#defaultsObj.trans("new_search")#</a> <input type="radio" name="newsearch" id="s_newsearch" value="f"<cfif attributes.newsearch EQ "f"> checked="true"</cfif>> <a href="##" onclick="clickcbk('form_searchsearch','newsearch',1)" style="text-decoration:none;">#defaultsObj.trans("search_within")#</a>
						<br><br>
						#defaultsObj.trans("search_term")# (<a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank">Help</a>)
						<br />
						<input name="searchfor" id="insearchsearchfor" type="text" class="textbold" style="width:190px;">
					</td>
					<td valign="top">
						Filename
						<br />
						<input type="text" name="filename" id="s_filename" style="width:190px;" class="textbold" value="#attributes.filename#">
						<br />
						Keywords
						<br />
						<input type="text" name="keywords" id="s_keywords" style="width:190px;" class="textbold" value="#attributes.keywords#">
					</td>
					<td valign="top">
						Description
						<br />
						<input type="text" name="description" id="s_description" style="width:190px;" class="textbold" value="#attributes.description#">
						<br>
						#defaultsObj.trans("labels")#
						<br />
						<select data-placeholder="Choose a label" class="chzn-select" style="width:201px;" name="labels" id="search_labels" multiple="multiple">
							<option value=""></option>
							<cfloop query="attributes.thelabelsqry">
								<cfset l = replace(label_path," "," AND ","all")>
								<cfset l = replace(l,"/"," AND ","all")>
								<option value="(#l#)"<cfif attributes.flabel EQ "(#l#)"> selected="true"</cfif>>#label_path#</option>
							</cfloop>
						</select>
					</td>
					<td valign="top">
						Extension
						<br /><input type="text" name="extension" id="s_extension" style="width:190px;" class="textbold" value="#attributes.extension#">
						<br />
						All Metadata
						<br /><input type="text" name="rawmetadata" id="s_metadata" style="width:190px;" class="textbold" value="#attributes.metadata#">
					</td>
					<td nowrap="nowrap" valign="top">
						#defaultsObj.trans("search_for_type")#
						<br />
						<select name="thetype" id="s_type">
							<option value="all"<cfif attributes.thetype EQ "all"> selected="true"</cfif>>#defaultsObj.trans("search_for_allassets")#</option>
							<option value="img"<cfif attributes.thetype EQ "img"> selected="true"</cfif>>#defaultsObj.trans("search_for_images")#</option>
							<option value="doc"<cfif attributes.thetype EQ "doc"> selected="true"</cfif>>#defaultsObj.trans("search_for_documents")#</option>
							<option value="vid"<cfif attributes.thetype EQ "vid"> selected="true"</cfif>>#defaultsObj.trans("search_for_videos")#</option>
							<option value="aud"<cfif attributes.thetype EQ "aud"> selected="true"</cfif>>#defaultsObj.trans("search_for_audios")#</option>
						</select>
						<br>
						#defaultsObj.trans("date_created")#
						<br />
						<cfset lastyear = #year(now())# - 10>
						<cfset newyear = #year(now())# + 3>
						<select name="on_day" id="s_on_day" class="text"><option value="">#defaultsObj.trans("day")#</option><cfloop from="1" to="31" index="theday"><option value="#theday#"<cfif attributes.on_day EQ theday> selected="true"</cfif>>#theday#</option></cfloop></select> <select name="on_month" id="s_on_month" class="text"><option value="">#defaultsObj.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="#themonth#"<cfif attributes.on_month EQ themonth> selected="true"</cfif>>#themonth#</option></cfloop></select> <select name="on_year" id="s_on_year" class="text"><option value="">#defaultsObj.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#"<cfif attributes.on_year EQ theyear> selected="true"</cfif>>#theyear#</option></cfloop></select> <a href="##" onclick="settoday('form_searchsearch');">#defaultsObj.trans("today")#</a>
						<br>
						And/Or
						<br /><select name="andor" id="andor">
							<option value="AND"<cfif attributes.andor EQ "and"> selected="true"</cfif>>AND</option>
							<option value="OR"<cfif attributes.andor EQ "or"> selected="true"</cfif>>OR</option>
						</select>
					</td>
					<td valign="top">
						<button class="awesome big green">Search</button>
						<!--- <input type="submit" name="submit" value="#defaultsObj.trans("button_find")#" class="button"> --->
					</td>
				</tr>
				<!--- <tr>
					
					<cfloop query="qry_cf_fields">
						<cfset cfid = replace(cf_id,"-","","all")>
						#cf_text#
						<br />
						<!--- For text --->
						<cfif cf_type EQ "text" OR cf_type EQ "textarea">
							<input type="text" style="width:190px;" name="cf#cfid#">
						<!--- Radio --->
						<cfelseif cf_type EQ "radio">
							<input type="radio" name="cf#cfid#" value="T">#defaultsObj.trans("yes")# <input type="radio" name="cf#cfid#" value="F">#defaultsObj.trans("no")#
						<!--- Select --->
						<cfelseif cf_type EQ "select">
							<select name="cf#cfid#" style="width:190px;">
								<option value="" selected="selected"></option>
								<cfloop list="#cf_select_list#" index="i">
									<option value="#i#">#i#</option>
								</cfloop>
							</select>
						</cfif>
						<br />
					</cfloop>
					</td>
				</tr> --->

			</table>
			</form>
		</div>
		<!--- Clear --->
		<div style="clear:both;padding-top:15px;"></div>
		<!--- Search Results --->
		<div style="padding:0;margin:0;">
			<div id="search_tab">
				<ul>
					<li><a href="##content_search_all" onclick="switchsearchtab('all');" rel="prefetch prerender">#defaultsObj.trans("searchresults_header")# (#qry_filecount.thetotal#)</a></li>
					<cfif structKeyExists(qry_files, "qimg") AND qry_files.qimg.cnt NEQ 0 AND cs.tab_images>
						<li><a href="##content_search_img" onclick="switchsearchtab('img');" rel="prefetch prerender">#defaultsObj.trans("folder_images")# (#qry_files.qimg.cnt#)</a></li>
					</cfif>
					<cfif structKeyExists(qry_files, "qvid") AND qry_files.qvid.cnt NEQ 0 AND cs.tab_videos>
						<li><a href="##content_search_vid" onclick="switchsearchtab('vid');" rel="prefetch">#defaultsObj.trans("folder_videos")# (#qry_files.qvid.cnt#)</a></li>
					</cfif>
					<cfif structKeyExists(qry_files, "qaud") AND qry_files.qaud.cnt NEQ 0 AND cs.tab_audios>
						<li><a href="##content_search_aud" onclick="switchsearchtab('aud');" rel="prefetch">#defaultsObj.trans("folder_audios")# (#qry_files.qaud.cnt#)</a></li>
					</cfif>
					<cfif structKeyExists(qry_files, "qdoc") AND qry_files.qdoc.cnt NEQ 0 AND cs.tab_doc>
						<li><a href="##content_search_doc" onclick="switchsearchtab('doc');" rel="prefetch">Documents (#qry_files.qdoc.cnt#)</a></li>
					</cfif>
				</ul>
				
				<div id="content_search_all">
					<cfinclude template="dsp_folder_content_results.cfm" />
				</div>
				<cfif structKeyExists(qry_files, "qimg") AND qry_files.qimg.cnt NEQ 0 AND cs.tab_images>
					<div id="content_search_img"></div>
				</cfif>
				<cfif structKeyExists(qry_files, "qvid") AND qry_files.qvid.cnt NEQ 0 AND cs.tab_videos>
					<div id="content_search_vid"></div>
				</cfif>
				<cfif structKeyExists(qry_files, "qaud") AND qry_files.qaud.cnt NEQ 0 AND cs.tab_audios>
					<div id="content_search_aud"></div>
				</cfif>
				<cfif structKeyExists(qry_files, "qdoc") AND qry_files.qdoc.cnt NEQ 0 AND cs.tab_doc>
					<div id="content_search_doc"></div>
				</cfif>
			</div>
		</div>
	</div>
</cfoutput>

<script type="text/javascript">
	$(document).ready(function() {
		<cfif structkeyexists(attributes,"searchfor")>
			// Copy the simple search text value
			$('#insearchsearchfor').val('<cfoutput>#attributes.searchfor#</cfoutput>');
		<cfelse>
			// Copy the simple search text value
			var sst = $('#simplesearchtext').val();
			$('#insearchsearchfor').val(sst);
		</cfif>
		// Activate Chosen
		$(".chzn-select").chosen();
		// Load tabs
		jqtabs("search_tab");
		// Search submit
		$("#form_searchsearch").submit(function(e){
			// Get searchfor value
			var searchfor = $('#insearchsearchfor').val();
			// Call subfunction to get fields
			var searchtext = subadvfields('form_searchsearch');
			// Only allow chars
			var illegalChars = /(\*|\?)/;
			// Parse the entry
			var thetype = $('#thetype').val();
			// get the first position
			var p1 = searchtext.substr(searchtext,1);
			// Now check
			if (illegalChars.test(p1)){
				alert('The first character of your search string is an illegal one. Please remove it!');
			}
			else if (searchtext == "") {
				alert('Please enter a search term!');
			}
			else {
				// Show loading bar
				$("body").append('<div id="bodyoverlay"><img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
				// Get values
				var newsearch = $('#s_newsearch:checked').val();
				var thetype = $('#s_type option:selected').val();
				var listaudid = $('#s_listaudid').val();
				var listvidid = $('#s_listvidid').val();
				var listimgid = $('#s_listimgid').val();
				var listdocid = $('#s_listdocid').val();
				var on_day = $('#s_on_day option:selected').val();
				var on_month = $('#s_on_month option:selected').val();
				var on_year = $('#s_on_year option:selected').val();
				var andor = $('#andor option:selected').val();
				var flab = $('#search_labels option:selected').val();
				var fname = $('#s_filename').val();
				var fkeys = $('#s_keywords').val();
				var fdesc = $('#s_description').val();
				var fext = $('#s_extension').val();
				var fmeta = $('#s_metadata').val();
				// Post the search
				$('#rightside').load('<cfoutput>#myself#</cfoutput>c.search_simple', {searchtext: searchtext, newsearch: newsearch, folder_id: <cfoutput>#attributes.folder_id#</cfoutput>, thetype: thetype, listaudid: listaudid, listvidid: listvidid, listimgid: listimgid, listdocid: listdocid, andor: andor, on_day: on_day, on_month: on_month, on_year: on_year, searchfor: searchfor, filename: fname, keywords: fkeys, description: fdesc, extension: fext, metadata: fmeta, flabel: flab}, function(){
						$("#bodyoverlay").remove();
					});
			}
			return false;
		});
		// Show Subsearch
		function showsubsearch(){
			$('#searchsearch').toggle('blind','slow');
		}
		// Search for keywords
		function searchkeywords(folderid,searchtext,thetype){
			$('#loading_searchagain').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#rightside').load('index.cfm?fa=c.search_simple', { searchtext: 'keywords:' + searchtext, thetype: thetype, folder_id: folderid });
		}
	});
</script>