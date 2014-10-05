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
<!--- Check if folder re-direction needs to happen --->

<!--- Initialize vars --->
<cfset session.do_folder_redirect = false>
<cfset session.folder_redirect_id = "0">
<!--- Check re-direct folders to ensure user has access to it and it's a valid folder. Find the first good match and set that as re-direct folder --->
<cfloop list="#redirectfolders#" index="redirect_folder_id">
	<cfif myFusebox.getApplicationData().folders.checkfolder(redirect_folder_id)>
		<cfset session.folder_redirect_id = redirect_folder_id>
		<cfset session.do_folder_redirect = true>
		<cfbreak>
	</cfif>
</cfloop>

<!--- If group re-direction is not set but global re-direction is then make re-direct folder as the set global folder --->
<cfif session.folder_redirect_id EQ "0" AND cs.folder_redirect NEQ "0" AND myFusebox.getApplicationData().folders.checkfolder(cs.folder_redirect)>
	<cfset session.do_folder_redirect = true>
	<cfset session.folder_redirect_id = cs.folder_redirect>
</cfif>
<!--- The default div. This will be overwritten by any call that calls the id of this div --->
<div id="rightside">
	<cfoutput>
		<cfif !session.do_folder_redirect OR attributes.redirectmain> 
			<!--- Show if Firebug is enabled --->
			<div id="firebugalert" style="display:none;" class="box-dotted"></div>
			
			<!--- Storage Check --->
			<!--- <cfif application.razuna.storage EQ "nirvanix" AND attributes.nvxsession EQ 0>
				<div style="padding:10px;background-color:##FFFFE0;color:##900;" class="box-dotted">
					<cfif application.razuna.isp>
						<strong>Caution: Something is wrong with your setup. Please contact our support team with this error. Do NOT continue until you hear from us! (Use the feedback link on top to report this. Thank you.)</strong>
					<cfelse>
						Caution: You are using the Nirvanix Cloud Storage, but it looks like it is not properly set up. Thus no assets will be shown! <br />Please check with your Administrator to resolve this immediately
					</cfif>
				</div>
				<div style="clear:both;"><br /></div>
			</cfif> --->
			<!--- Nirvanix Usage --->
			<!--- <cfif application.razuna.isp AND application.razuna.storage EQ "nirvanix" AND structkeyexists(attributes.nvxusage,"limitup")>
				<div style="padding:10px;background-color:##FFFFE0;color:##900;" class="box-dotted">
					You have exceeded the total amount of storage or traffic for your account for this month. Please login to your <a href="##" onclick="showaccount();">account panel and upgrade</a>!
				</div>
				<div style="clear:both;"><br /></div>
			</cfif> --->
			<!--- Prerelease --->
			<cfif prerelease>
				<div style="padding:10px;background-color:##FFFFE0;" class="box-dotted">
					<span style="color:green;font-weight:bold;">Thank you for taking this Pre-release Version of Razuna for a spin. We appreciate your help a lot!</span><br />
					To streamline the process of reporting issues that you might find, please <a href="http://groups.google.com/group/razuna-testers" target="_blank">subscribe to the Razuna-Testers Google Group</a>. Please always <a href="http://issues.razuna.com" target="_blank">check our issue platform for reported issues first</a>, before posting to the group.
				</div>
				<div style="clear:both;"><br /></div>
			</cfif>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="100%" valign="top">
						<!--- How to get the most out of Razuna --->
						<cfif application.razuna.whitelabel>
							<cfif attributes.wl_main_static NEQ "">
								#attributes.wl_main_static#
								<br>
							</cfif>
						<cfelse>
							<div class="panelsnew">
								<h1>#myFusebox.getApplicationData().defaults.trans("upload_now")#</h1>
								<a href="##" onclick="showwindow('#myself#c.choose_folder&folder_id=x','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("add_file")#">
									<button class="awesome super green">#myFusebox.getApplicationData().defaults.trans("add_your_files")#</button>
								</a>
							</div>
							<br>
							<div class="panelsnew">
								<h1>#myFusebox.getApplicationData().defaults.trans("razuna_main_video_header")#</h1>
								<a href="##" onclick="SetVideo('http://player.vimeo.com/video/43252986?title=0&amp;byline=0&amp;portrait=0&amp;color=c9ff23&amp;autoplay=1', '#myFusebox.getApplicationData().defaults.trans("razuna_main_video_1")#');return false;">&gt; #myFusebox.getApplicationData().defaults.trans("razuna_main_video_1")#</a>
								<br /><br />
								<a href="##" onclick="SetVideo('http://player.vimeo.com/video/43253330?title=0&amp;byline=0&amp;portrait=0&amp;color=c9ff23&amp;autoplay=1', '#myFusebox.getApplicationData().defaults.trans("razuna_main_video_2")#');return false;">&gt; #myFusebox.getApplicationData().defaults.trans("razuna_main_video_2")#</a>
								<br /><br />
								<a href="##" onclick="SetVideo('http://player.vimeo.com/video/43252988?title=0&amp;byline=0&amp;portrait=0&amp;color=c9ff23&amp;autoplay=1', '#myFusebox.getApplicationData().defaults.trans("razuna_main_video_3")#');return false;">&gt; #myFusebox.getApplicationData().defaults.trans("razuna_main_video_3")#</a>
								<br /><br />
								<a href="##" onclick="SetVideo('http://player.vimeo.com/video/43253332?title=0&amp;byline=0&amp;portrait=0&amp;color=c9ff23&amp;autoplay=1', '#myFusebox.getApplicationData().defaults.trans("razuna_main_video_4")#');return false;">&gt; #myFusebox.getApplicationData().defaults.trans("razuna_main_video_4")#</a>
								<br /><br />
								<a href="##" onclick="SetVideo('http://player.vimeo.com/video/43253331?title=0&amp;byline=0&amp;portrait=0&amp;color=c9ff23&amp;autoplay=1', '#myFusebox.getApplicationData().defaults.trans("razuna_main_video_5")#');return false;">&gt; #myFusebox.getApplicationData().defaults.trans("razuna_main_video_5")#</a>
							</div>
							<br />
						</cfif>
						<!--- If WL we show the recently updated assets --->
						<cfif structKeyExists(attributes,"wl_show_updates") AND attributes.wl_show_updates EQ "true" AND attributes.qry_log.recordcount NEQ 0>
							<br>
							<div class="panelsnew" style="width:100%" >
								<h1>Most recently updated assets</h1>
								<div style="height:200px;width:100%;overflow-y:auto;">
									<table border="0" cellpadding="0" cellspacing="0" class="grid" >
										<tr>
											<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("date")#</th>
											<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("time")#</th>
											<th width="100%">#myFusebox.getApplicationData().defaults.trans("description")#</th>
											<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("action")#</th>
											<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("log_type_of_file")#</th>
											<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("theuser")#</th>
										</tr>
										<!--- Loop over all assets log entries in database table --->
										<cfloop query="attributes.qry_log" endrow="50">
											<tr class="list" >
												<td nowrap="true" valign="top">#dateformat(log_timestamp, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
												<td nowrap="true" valign="top">#timeFormat(log_timestamp, 'HH:mm:ss')#</td>
												<td valign="top">#log_desc#</td>
												<td nowrap="true" align="center" valign="top">#log_action#</td>
												<td nowrap="true" align="center" valign="top">#log_file_type#</td>
												<td nowrap="true" align="center" valign="top">#user_first_name# #user_last_name#</td>
											</tr>
										</cfloop>
									</table>
								</div>
							</div>
						</cfif>
					</td>
					<td width="1%" valign="top" nowrap="nowrap">
						<!--- If the top part is hidden then admin functions are here and the search also --->
						<cfif !cs.show_top_part>						
							<!--- Search here --->
							<div id="tab_search">
								<div class="panelsnew">
									<h1>#myFusebox.getApplicationData().defaults.trans("search_panel")#</h1>
									<form name="form_simplesearch" id="form_simplesearch" onsubmit="checkentry();return false;">
									<input type="hidden" name="simplesearchthetype" id="simplesearchthetype" value="all">
									<div style="float:left;padding-top:4px;">
										<img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" class="ddicon" onclick="$('##searchselection').toggle();">
									</div>
									<div id="searchselection" class="ddselection_header" style="margin-top:75px;">
										<p><a href="##" onclick="selectsearchtype('all');"><div id="markall" style="float:left;padding-right:2px;"><img src="#dynpath#/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0"></div>#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</a></p>
										<p><a href="##" onclick="selectsearchtype('img');"><div id="markimg" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_images")#</a></p>
										<p><a href="##" onclick="selectsearchtype('doc');"><div id="markdoc" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_documents")#</a></p>
										<p><a href="##" onclick="selectsearchtype('vid');"><div id="markvid" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_videos")#</a></p>
										<p><a href="##" onclick="selectsearchtype('aud');"><div id="markaud" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_audios")#</a></p>
										<p><hr></p>
										<p><a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank" onclick="$('##userselection').toggle();">#myFusebox.getApplicationData().defaults.trans("help_with_search")#</a></p>
									</div>
									<div style="float:left;">
										<input name="simplesearchtext" id="simplesearchtext" type="text" class="textbold" style="width:250px;" placeholder="Quick Search">
									</div>
									<div style="float:left;">
										<button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("header_search")#</button>
									</div>
									<div style="float:right;padding-left:20px;padding-top:4px;">
										<a href="##" onclick="showwindow('#myself#c.search_advanced','#myFusebox.getApplicationData().defaults.trans("link_adv_search")#',500,1);$('##searchselection').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("link_adv_search")#</a>
									</div>
									</form>
								</div>
							</div>
							<br />
							<!--- If SystemAdmin or Admininstrator --->
							<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
								<div id="tab_admin">
									<div class="panelsnew">
										<h1>#myFusebox.getApplicationData().defaults.trans("administrator_panel")#</h1>
										<a href="##" onclick="loadcontent('rightside','#myself#c.admin');$('##userselection').toggle();return false;" style="width:100%;">#myFusebox.getApplicationData().defaults.trans("go_to_administration")#</a> <cfif qry_langs.recordcount NEQ 1>| <cfloop query="qry_langs"><a href="#myself#c.switchlang&thelang=#lang_name#&_v=#createuuid('')#">#lang_name#</a> | </cfloop> </cfif> <a href="https://help.razuna.com/" target="_blank">Razuna Help</a> | <a href="#myself#c.logout&_v=#createuuid('')#">#myFusebox.getApplicationData().defaults.trans("logoff")#</a>
									</div>
								</div>
							</cfif>
						</cfif>
						
						<!--- Announcement for ISP --->
						<cfif cgi.http_host CONTAINS "razuna.com">
							<div class="panelsnew">
								<h1>Razuna Announcements</h1>
								<cfloop query="attributes.qry_news">
									<cfif currentrow EQ 1><h2>#news_title#</h2><cfelse><a href="##" onclick="$('##slidenews#currentrow#').toggle('blind','slow');">#news_title#</a><br /></cfif>
									<cfif currentrow EQ 1>
										<span class="announcements">#news_text##news_text_long#</p>
										<br /><br />
									<cfelse>
										<div id="slidenews#currentrow#" style="display:none;">
											#news_text##news_text_long#
											<br />
										</div>
									</cfif>
								</cfloop>
							</div>
							<br />
						</cfif>
						<!--- If WL we show the news section here --->
						<cfif application.razuna.whitelabel>
							<div class="panelsnew">
								<!--- System News --->
								<cfif attributes.qry_news.news.recordcount NEQ 0>
									<h1>System News</h1>
								</cfif>
								<!--- News --->
								<cfif attributes.wl_news_rss EQ "">
									<cfloop query="attributes.qry_news.news">
										<cfif currentrow EQ 1><h2>#news_title#</h2><cfelse><a href="##" onclick="$('##sysslidenews#currentrow#').toggle('blind','slow');">#news_title#</a><br /></cfif>
										<cfif currentrow EQ 1>
											<span class="announcements">#news_text#</p>
											<br /><br />
										<cfelse>
											<div id="sysslidenews#currentrow#" style="display:none;">
												#news_text#
												<br />
											</div>
										</cfif>
									</cfloop>
									<cfif attributes.qry_news.news.recordcount NEQ 0>
										<br>
									</cfif>
								<!--- RSS --->
								<cfelse>
									<cfif arrayisempty(attributes.qry_news)>
										<h2>Connection to the news is currently not available</h2>
									<cfelse>
										<cfloop index="x" from="1" to="#arrayLen(attributes.qry_news)#">
											<a href="#attributes.qry_news[x].link#" target="_blank">#attributes.qry_news[x].title#</a><br />
										</cfloop>
										<br>
									</cfif>
								</cfif>
								<!--- Host News --->
								<cfif attributes.qry_news.news_host.recordcount NEQ 0>
									<h1>News</h1>
								</cfif>
								<!--- News --->
								<cfif attributes.wl_news_rss EQ "">
									<cfloop query="attributes.qry_news.news_host">
										<cfif currentrow EQ 1><h2>#news_title#</h2><cfelse><a href="##" onclick="$('##slidenews#currentrow#').toggle('blind','slow');">#news_title#</a><br /></cfif>
										<cfif currentrow EQ 1>
											<span class="announcements">#news_text#</p>
											<br /><br />
										<cfelse>
											<div id="slidenews#currentrow#" style="display:none;">
												#news_text#
												<br />
											</div>
										</cfif>
									</cfloop>
								<!--- RSS --->
								<cfelse>
									<cfif arrayisempty(attributes.qry_news)>
										<h2>Connection to the news is currently not available</h2>
									<cfelse>
										<cfloop index="x" from="1" to="#arrayLen(attributes.qry_news)#">
											<a href="#attributes.qry_news[x].link#" target="_blank">#attributes.qry_news[x].title#</a><br />
										</cfloop>
									</cfif>
								</cfif>
							</div>
						</cfif>
					</td>
				</tr>
			</table>
		<cfelse>
			<script language="JavaScript" type="text/javascript">
				$('##rightside').load('#myself#c.folder&col=F&folder_id=#session.folder_redirect_id#');
			</script>
		</cfif>
		<cfif structKeyExists(pl,"pview")>
			<cfloop list="#pl.pview#" delimiters="," index="i">
				#evaluate(i)#
			</cfloop>
		</cfif>
	</cfoutput>
</div>
<!--- Activate the Tabs on the main page --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_main_support");
</script>
<!--- JS: FOLDERS --->
<cfinclude template="../js/folders.cfm" runonce="true">
<!--- JS: FILES --->
<cfinclude template="../js/files.cfm" runonce="true">
<!--- JS: BASKET --->
<cfinclude template="../js/basket.cfm" runonce="true">
<!--- JS: USERS --->
<cfinclude template="../js/users.cfm" runonce="true">
<!--- JS: SCHEDULER --->
<cfinclude template="../js/scheduler.cfm" runonce="true">
