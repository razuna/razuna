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
<cfparam default="0" name="attributes.folder_id">
<cfset myvar = structnew()>
<cfoutput>
	<div id="searchadvanced">
		<ul>
			<li><a href="##all_assets">#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</a></li>
			<!--- RAZ-3241 Hide all tabs except the 'All Assets' tab --->
			<cfif !cs.hide_search_tabs>
				<li><a href="##adv_files">Documents</a></li>
				<li><a href="##adv_images">Images</a></li>
				<li><a href="##adv_videos">Videos</a></li>
				<li><a href="##adv_audios">Audios</a></li>
			</cfif>
		</ul>
		<!--- Loading Bars --->
		<div id="loading_searchadv" style="width:100%;text-align:center;padding-top:5px;"></div>
		<!--- All --->
		<div id="all_assets">
			<form name="advsearch_all" id="advsearch_all" method="post" onsubmit="searchadv_all('advsearch_all','c.search_simple','#attributes.fromshare#');return false;">
				<cfif attributes.folder_id NEQ 0>
					<input type="hidden" name="adv_folder_id" id="adv_folder_id" value="#attributes.folder_id#">
				</cfif>
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<!--- Include advanced fields --->
					<cfset myvar.thetype = "all">
					<cfinclude template="inc_search_fields.cfm" myvar="#myvar#" />
					<cfset lastyear = #year(now())# - 10>
					<cfset newyear = #year(now())# + 3>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_created")#</td>
						<td><select name="on_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="01" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="on_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="on_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_all','on');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_changed")#</td>
						<td><select name="change_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="01" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="change_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="change_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_all','change');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td>Match</td>
						<td>
							<select name="andor" id="andor">
							<option value="AND" selected="true">Match ALL terms</option>
							<option value="OR">Match ANY term</option>
						</select>
						</td>
					</tr>
					<tr>
						<td></td>
						<td><input type="submit" name="submitsearch" value="#myFusebox.getApplicationData().defaults.trans("button_find")#" class="button"></td>
					</tr>
				</table>
			</form>
		</div>
			<cfif !cs.hide_search_tabs>
			<!--- Documents --->
			<div id="adv_files">
				<form name="advsearch_files" id="advsearch_files" onsubmit="searchadv_files('advsearch_files','c.search_simple','#attributes.folder_id#');return false;">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<!--- Include advanced fields --->
					<cfset myvar.thetype = "doc">
					<cfinclude template="inc_search_fields.cfm" myvar="#myvar#" />
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("search_for_type")#</td>
						<td>
							<select name="doctype">
								<option value="all" selected="selected">#myFusebox.getApplicationData().defaults.trans("all_documents")#</option>
								<option value="doc">#myFusebox.getApplicationData().defaults.trans("folder_word")#</option>
								<option value="xls">#myFusebox.getApplicationData().defaults.trans("folder_excel")#</option>
								<option value="pdf">#myFusebox.getApplicationData().defaults.trans("folder_pdf")#</option>
								<option value="other">#myFusebox.getApplicationData().defaults.trans("folder_others")#</option>
							</select>
						</td>
					</tr>
					<cfset lastyear = #year(now())# - 10>
					<cfset newyear = #year(now())# + 3>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_created")#</td>
						<td><select name="on_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="1" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="on_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="on_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_files','on');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_changed")#</td>
						<td><select name="change_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="01" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="change_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="change_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_files','change');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td>Match</td>
						<td>
							<select name="andor" id="andor">
								<option value="AND" selected="true">Match ALL terms</option>
								<option value="OR">Match ANY term</option>
							</select>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="right"><a href="##" onclick="$('##pdfxmp').slideToggle('slow');return false;">Show additional metadata fields</a></td>
					</tr>
					<tr>
						<td colspan="2" style="padding:0px;margin:0px;">
							<div id="pdfxmp" style="display:none;">
								<table>
									<tr>
										<td colspan="2"><hr></td>
									</tr>
									<tr>
										<th colspan="2">For PDF only (XMP metadata)</th>
									</tr>
									<tr>
										<td>Author</td>
										<td><input type="text" name="author" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Authorsposition</td>
										<td><input type="text" name="authorsposition" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Captionwriter</td>
										<td><input type="text" name="captionwriter" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Webstatement</td>
										<td><input type="text" name="webstatement" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Rights</td>
										<td><input type="text" name="rights" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Rightsmarked</td>
										<td><input type="text" name="rightsmarked" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td colspan="2"><hr></td>
									</tr>
								</table>
							</div>
						</td>
					</tr>
					
					<tr>
						<td></td>
						<td><input type="submit" name="submitsearchdoc" value="#myFusebox.getApplicationData().defaults.trans("button_find")#" class="button"></td>
					</tr>
				</table>
				</form>
			</div>
			<!--- Images --->
			<div id="adv_images">
				<form name="advsearch_images" id="advsearch_images" onsubmit="searchadv_images('advsearch_images','c.search_simple','#attributes.folder_id#');return false;">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<!--- Include advanced fields --->
					<cfset myvar.thetype = "img">
					<cfinclude template="inc_search_fields.cfm" myvar="#myvar#" />
					<cfset lastyear = #year(now())# - 10>
					<cfset newyear = #year(now())# + 3>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_created")#</td>
						<td><select name="on_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="1" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="on_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="on_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_images','on');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_changed")#</td>
						<td><select name="change_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="01" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="change_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="change_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_images','change');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td>Match</td>
						<td>
							<select name="andor" id="andor">
								<option value="AND" selected="true">Match ALL terms</option>
								<option value="OR">Match ANY term</option>
							</select>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="right"><a href="##" onclick="$('##imgxmp').slideToggle('slow');return false;">Show additional metadata fields</a></td>
					</tr>
					<tr>
						<td colspan="2" style="padding:0px;margin:0px;">
							<div id="imgxmp" style="display:none;">
								<table>
									<tr>
										<td colspan="2"><hr></td>
									</tr>
									<tr>
										<th colspan="2">Dedicated Metadata (XMP metadata)</th>
									</tr>
									<tr>
										<td>Subjectcode</td>
										<td><input type="text" name="subjectcode" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Creator</td>
										<td><input type="text" name="creator" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Title</td>
										<td><input type="text" name="title" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Authorsposition</td>
										<td><input type="text" name="authorsposition" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Captionwriter</td>
										<td><input type="text" name="captionwriter" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Contact Address</td>
										<td><input type="text" name="ciadrextadr" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Category</td>
										<td><input type="text" name="category" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Supplemental Categories</td>
										<td><input type="text" name="supplementalcategories" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Urgency</td>
										<td><input type="text" name="urgency" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Contact City</td>
										<td><input type="text" name="ciadrcity" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Contact Country</td>
										<td><input type="text" name="ciadrctry" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Location</td>
										<td><input type="text" name="location" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Address Zip Code</td>
										<td><input type="text" name="ciadrpcode" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>eMail(s)</td>
										<td><input type="text" name="ciemailwork" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Contact URL</td>
										<td><input type="text" name="ciurlwork" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Contact Phone(s)</td>
										<td><input type="text" name="citelwork" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Intellectual Genre</td>
										<td><input type="text" name="intellectualgenre" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Instructions</td>
										<td><input type="text" name="instructions" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Source</td>
										<td><input type="text" name="source" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Usage Terms</td>
										<td><input type="text" name="usageterms" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Copyright Status</td>
										<td><input type="text" name="copyrightstatus" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Transmission reference</td>
										<td><input type="text" name="transmissionreference" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Web Statement</td>
										<td><input type="text" name="webstatement" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Headline</td>
										<td><input type="text" name="headline" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Date Created</td>
										<td><input type="text" name="datecreated" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>City</td>
										<td><input type="text" name="city" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Contact State</td>
										<td><input type="text" name="ciadrregion" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Country</td>
										<td><input type="text" name="country" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Country Code</td>
										<td><input type="text" name="countrycode" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Scene</td>
										<td><input type="text" name="scene" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>State</td>
										<td><input type="text" name="state" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td>Credit</td>
										<td><input type="text" name="credit" style="width:300px;" class="textbold"></td>
									</tr>
								 	<tr>
										<td>Rights</td>
										<td><input type="text" name="rights" style="width:300px;" class="textbold"></td>
									</tr>
									<tr>
										<td colspan="2"><hr></td>
									</tr>
								</table>
							</div>
						</td>
					</tr>
					<tr>
						<td></td>
						<td><input type="submit" name="submitsearchimg" value="#myFusebox.getApplicationData().defaults.trans("button_find")#" class="button"></td>
					</tr>
				</table>
				</form>
			</div>
			<!--- Videos --->
			<div id="adv_videos">
				<form name="advsearch_videos" id="advsearch_videos" onsubmit="searchadv_videos('advsearch_videos','c.search_simple','#attributes.folder_id#');return false;">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<!--- Include advanced fields --->
					<cfset myvar.thetype = "vid">
					<cfinclude template="inc_search_fields.cfm" myvar="#myvar#" />
					<cfset lastyear = #year(now())# - 10>
					<cfset newyear = #year(now())# + 3>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_created")#</td>
						<td><select name="on_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="1" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="on_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="on_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_videos','on');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_changed")#</td>
						<td><select name="change_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="01" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="change_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="change_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_videos','change');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td>Match</td>
						<td>
							<select name="andor" id="andor">
								<option value="AND" selected="true">Match ALL terms</option>
								<option value="OR">Match ANY term</option>
							</select>
						</td>
					</tr>
					<tr>
						<td></td>
						<td><input type="submit" name="submitsearchvid" value="#myFusebox.getApplicationData().defaults.trans("button_find")#" class="button"></td>
					</tr>
				</table>
				</form>
			</div>
			<!--- Audios --->
			<div id="adv_audios">
				<form name="advsearch_audios" id="advsearch_audios" onsubmit="searchadv_audios('advsearch_audios','c.search_simple','#attributes.folder_id#');return false;">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<!--- Include advanced fields --->
					<cfset myvar.thetype = "aud">
					<cfinclude template="inc_search_fields.cfm" myvar="#myvar#" />
					<cfset lastyear = #year(now())# - 10>
					<cfset newyear = #year(now())# + 3>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_created")#</td>
						<td><select name="on_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="1" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="on_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="on_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_audios','on');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_changed")#</td>
						<td><select name="change_day" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("day")#</option><cfloop from="01" to="31" index="theday"><option value="<cfif len(theday) EQ 1>0</cfif>#theday#">#theday#</option></cfloop></select> <select name="change_month" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="<cfif len(themonth) EQ 1>0</cfif>#themonth#">#themonth#</option></cfloop></select> <select name="change_year" class="text"><option value="">#myFusebox.getApplicationData().defaults.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('advsearch_audios','change');return false;">#myFusebox.getApplicationData().defaults.trans("today")#</a></td>
					</tr>
					<tr>
						<td>Match</td>
						<td>
							<select name="andor" id="andor">
								<option value="AND" selected="true">Match ALL terms</option>
								<option value="OR">Match ANY term</option>
							</select>
						</td>
					</tr>
					<tr>
						<td></td>
						<td><input type="submit" name="submitsearchaud" value="#myFusebox.getApplicationData().defaults.trans("button_find")#" class="button"></td>
					</tr>
				</table>
				</form>
			</div>
		</cfif>
		<!--- Loading Bars --->
		<div id="loading_searchadv2" style="width:100%;text-align:center;"></div>
	</div>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		// Activate Chosen
		$(".chzn-select").chosen({search_contains: true});
		jqtabs("searchadvanced");
		// Focus
		$('##searchforadv_all').focus();
	</script>	
</cfoutput>
	
