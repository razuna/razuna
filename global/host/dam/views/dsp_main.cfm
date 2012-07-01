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
<!--- The default div. This will be overwritten by any call that calls the id of this div --->
<div id="rightside">
	<cfoutput>
		<cfif cs.folder_redirect EQ "0" OR attributes.redirectmain> 
			<!--- Show if Firebug is enabled --->
			<div id="firebugalert" style="display:none;"></div>
			<!--- Storage Check --->
			<cfif application.razuna.storage EQ "nirvanix" AND attributes.nvxsession EQ 0>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
					<tr>
						<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;color:##900;">
							<cfif application.razuna.isp>
								<strong>Caution: Something is wrong with your setup. Please <a href="mailto:support@razuna.com?subject=Login error for #session.hostid#">contact the Razuna support team</a> with this error. Do NOT continue until you hear from us!</strong>
							<cfelse>
								Caution: You are using the Nirvanix Cloud Storage, but it looks like it is not properly set up. Thus no assets will be shown! <br />Please check with your Administrator to resolve this immediately
							</cfif>
						</td>
					</tr>
				</table>
				<br />
			</cfif>
			<!--- Nirvanix Usage --->
			<cfif application.razuna.isp AND application.razuna.storage EQ "nirvanix" AND structkeyexists(attributes.nvxusage,"limitup")>
				<cfcachecontent name="nvx_exceeded" cachedwithin="#CreateTimeSpan(1,0,0,0)#" region="razcache">
					<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
						<tr>
							<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;color:##900;">
								You have exceeded the total amount of storage or traffic for your account for this month. Please login to your <a href="##" onclick="showaccount();">account panel and upgrade</a>!
							</td>
						</tr>
					</table>
					<br />
				</cfcachecontent>
			</cfif>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="50%" valign="top">
						<div id="tab_intro">
						<cfif application.razuna.isp>
							<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tablepanel">
								<tr>
									<th>Important Announcements</th>
								</tr>
								<cfloop query="attributes.qry_news">
									<tr>
										<td style="font-weight:bold;padding-top:10px;padding-bottom:0px;color:red;"><div style="float:left;">#news_title#</div><div style="float:right;font-style:italic;font-weight:normal;color:black;">(#dateformat(news_date,"mmmm d, yyyy")#)</div></td>
									</tr>
									<tr>
										<td style="padding-top:0px;padding-bottom:0px;">#news_text##news_text_long#</td>
									</tr>
								</cfloop>
							</table>
						<cfelse>
							<cfif settingsObj.getconfig("prerelease")>
								<cfcachecontent name="razunatesters" cachedwithin="#CreateTimeSpan(1,0,0,0)#" region="razcache">
									<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tablepanel">
										<tr>
											<th>Razuna Tester</th>
										</tr>
										<tr>
											<td>Thank you for taking this Pre-Release Version of Razuna for a spin. We appreciate your help a lot. To streamline the process of reporting issues that you might find, please <a href="http://groups.google.com/group/razuna-testers" target="_blank">subscribe to the Razuna-Testers Google Group</a>. <br /><br />Please <strong>always</strong> <a href="http://issues.razuna.com" target="_blank">check our issue platform for reported issues first</a>, <strong>before</strong> posting to the group.</td>
										</tr>
										<tr>
											<td>
												<img src="//groups.google.com/intl/en/images/logos/groups_logo_sm.gif" height=30 width=140 alt="Google Groups"><br />
												Subscribe to razuna-testers<br />
												<form action="http://groups.google.com/group/razuna-testers/boxsubscribe">
												Email: <input type="text" name="email" style="width:200px"> <input type=submit name="sub" value="Subscribe">
												</form>
												<br />
												<a href="http://groups.google.com/group/razuna-testers">Visit the Razuna-Testers group on the Web</a>
											</td>
										</tr>
									</table>
									<br />
								</cfcachecontent>
							</cfif>
							<cfcachecontent name="razunawelcomecache" cachedwithin="#CreateTimeSpan(1,0,0,0)#" region="razcache">
								<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tablepanel">
									<tr>
										<th>#defaultsObj.trans("welcome_to_ecp")#</th>
									</tr>
									<tr>
										<td>#defaultsObj.trans("welcome_text")#</td>
									</tr>
								</table>
							</cfcachecontent>
						</cfif>
						</div>
					</td>
					<td width="50%" valign="top" style="padding-left:10px;">
						<!--- If the top part is hidden then admin functions are here and the search also --->
						<cfif !cs.show_top_part>
							<!--- If SystemAdmin or Admininstrator --->
							<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
								<div id="tab_admin">
									<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tablepanel">
										<tr>
											<th>Administrator Panel</th>
										</tr>
										<tr>
											<td><a href="##" onclick="loadcontent('rightside','#myself#ajax.admin');$('##userselection').toggle();return false;" style="width:100%;">Go to Administration</a> <cfif qry_langs.recordcount NEQ 1>| <cfloop query="qry_langs"><a href="#myself#c.switchlang&thelang=#lang_name#&_v=#createuuid('')#">#lang_name#</a> | </cfloop> </cfif> <a href="http://getsatisfaction.razuna" target="_blank">Razuna Help</a> | <a href="#myself#c.logout&_v=#createuuid('')#">#defaultsObj.trans("logoff")#</a></td>
										</tr>
									</table>
								</div>
								<br>
							</cfif>
							<!--- Search here --->
							<div id="tab_search">
								<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tablepanel">
									<tr>
										<th>Search Panel</th>
									</tr>
									<tr>
										<td>
											<form name="form_simplesearch" id="form_simplesearch" onsubmit="checkentry();return false;">
											<input type="hidden" name="simplesearchthetype" id="simplesearchthetype" value="all">
											<div style="float:left;padding-top:4px;">
												<img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" class="ddicon" onclick="$('##searchselection').toggle();">
											</div>
											<div id="searchselection" class="ddselection_header">
												<p><a href="##" onclick="selectsearchtype('all');"><div id="markall" style="float:left;padding-right:2px;"><img src="#dynpath#/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0"></div>#defaultsObj.trans("search_for_allassets")#</a></p>
												<p><a href="##" onclick="selectsearchtype('img');"><div id="markimg" style="float:left;padding-right:14px;">&nbsp;</div>#defaultsObj.trans("search_for_images")#</a></p>
												<p><a href="##" onclick="selectsearchtype('doc');"><div id="markdoc" style="float:left;padding-right:14px;">&nbsp;</div>#defaultsObj.trans("search_for_documents")#</a></p>
												<p><a href="##" onclick="selectsearchtype('vid');"><div id="markvid" style="float:left;padding-right:14px;">&nbsp;</div>#defaultsObj.trans("search_for_videos")#</a></p>
												<p><a href="##" onclick="selectsearchtype('aud');"><div id="markaud" style="float:left;padding-right:14px;">&nbsp;</div>#defaultsObj.trans("search_for_audios")#</a></p>
												<p><hr></p>
												<p><a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank" onclick="$('##userselection').toggle();">Help with Search</a></p>
											</div>
											<div style="float:left;">
												<input name="simplesearchtext" id="simplesearchtext" type="text" class="textbold" style="width:300px;" value="Quick Search">
											</div>
											<div style="float:left;padding-left:2px;padding-top:4px;" id="searchicon">
												<img src="#dynpath#/global/host/dam/images/search_16.png" width="16" height="16" border="0" onclick="checkentry();" class="ddicon">
											</div>
											<div style="float:right;padding-left:20px;padding-top:4px;">
												<a href="##" onclick="showwindow('#myself#c.search_advanced','#defaultsObj.trans("link_adv_search")#',500,1);$('##searchselection').toggle();return false;">#defaultsObj.trans("link_adv_search")#</a>
											</div>
											</form>
										
										</td>
									</tr>
								</table>
							</div>
							<br>
						</cfif>
						<div id="tab_wisdom">
							<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tablepanel">
							<tr>
								<th>Wisdom of Today</th>
							</tr>
							<tr>
								<td>#wisdom.wis_text#</td>
							</tr>
							<tr>
								<td style="padding-top:10px;"><i>#wisdom.wis_author#</i></td>
							</tr>
							</table>
						</div>
						<br>
						<div id="tabs_main_support">
							<!-- the tabs -->
							<ul class="tabs">
								<li><a href="##raztools">Razuna Tools</a></li>
								<cfif cs.tab_razuna_support><li><a href="##support">Support for Razuna</a></li></cfif>
								<cfif cs.tab_twitter><li><a href="##twitter" onclick="window.open('http://twitter.com/razunahq');">Twitter</a></li></a></cfif>
								<cfif cs.tab_facebook><li><a href="##facebook" onclick="window.open('http://facebook.com/razunahq');">Facebook</a></li></cfif>
								<cfif cs.tab_razuna_blog><li><a href="##blog" onclick="loadcontent('blog','#myself#c.mainblog');">Razuna Blog</a></li></cfif>
							</ul>
							<!-- tab "panes" -->
							<div class="pane" id="raztools">
								<cfcachecontent name="raztools" cachedwithin="#CreateTimeSpan(1,0,0,0)#" region="razcache">
									<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
										<tr>
											<td>Hi there. Thank you for using Razuna. In order for you to enjoy Razuna even more we have some additional tools for you available.</td>
										</tr>
										<tr>
											<th><a href="http://razuna.org/whatisrazuna/razunadesktop" target="_blank">Razuna Desktop</a></th>
										</tr>
										<tr>
											<td>Razuna Desktop enables you to add any asset from your desktop to Razuna by simply dragging and dropping it into your Razuna Desktop application. <a href="http://razuna.org/whatisrazuna/razunadesktop" target="_blank">Read more >>></a></td>
										</tr>
										<tr>
											<th><a href="http://razuna.org/whatisrazuna/razunawordpress" target="_blank">Razuna Wordpress Plugin</a></th>
										</tr>
										<tr>
											<td>With the Razuna Wordpress plugin you simply choose assets within Razuna on your Wordpress powered site. There is no need to upload or import them to Wordpress. <a href="http://razuna.org/whatisrazuna/razunawordpress" target="_blank">Read more >>></a></td>
										</tr>
										<tr>
											<th><a href="https://chrome.google.com/webstore/detail/gliobkpjddpabnjilfghpnkghmigjjcn" target="_blank">Razuna Google Chrome Extension</a></th>
										</tr>
										<tr>
											<td>With the Razuna Google Chrome Extension installed you can browse your assets directly within Chrome. <a href="https://chrome.google.com/webstore/detail/gliobkpjddpabnjilfghpnkghmigjjcn" target="_blank">Read more >>></a></td>
										</tr>
										<tr>
											<th><a href="http://razuna.org/getinvolved/developers" target="_blank">Razuna API</a></th>
										</tr>
										<tr>
											<td>Razuna features a extensive API for you to expand on and access your assets Head over to our <a href="http://razuna.org/getinvolved/developers" target="_blank">Developer section</a> or directly to the <a href="http://wiki.razuna.com/display/ecp/API+Developer+Guide" target="_blank">API guide</a>. </a></td>
										</tr>
										<tr>
											<td>
												<cfif cs.show_twitter>
													<a href="http://twitter.com/razunahq" class="twitter-follow-button">Follow @razunahq</a>
												</cfif>
											</td>
										</tr>
										<tr>
											<td>
												<cfif cs.show_facebook>
													<script>(function(d){
		  var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
		  js = d.createElement('script'); js.id = id; js.async = true;
		  js.src = "//connect.facebook.net/en_US/all.js##appId=207944582601260&xfbml=1";
		  d.getElementsByTagName('head')[0].appendChild(js);
		}(document));</script>
		<div class="fb-like" data-href="https://www.facebook.com/razunahq" data-send="true" data-width="350" data-show-faces="true"></div>
												</cfif>
											</td>
										</tr>
									</table>
								</cfcachecontent>
							</div>
							<cfif cs.tab_razuna_support>
								<div class="pane" id="support">
									<cfcachecontent name="tab_razuna_support" cachedwithin="#CreateTimeSpan(7,0,0,0)#" region="razcache">
										<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
											<cfif !application.razuna.isp>
												<tr>
													<th>Razuna Support</th>
												</tr>
												<tr>
													<td>#defaultsObj.trans("support_desc")#</td>
												</tr>
											</cfif>
											<tr>
												<th style="padding-top:15px;">Online Support Tools</th>
											</tr>
											<tr>
												<td><a href="##" onClick="feedback_widget.show();">Leave us a Feedback</a></td>
											</tr>
											<tr>
												<td><a href="http://wiki.razuna.com/">Documentation (Wiki)</a></td>
											</tr>
											<tr>
												<td><a href="https://getsatisfaction.com/razuna" target="_blank">Join the Razuna Customer Community</a></td>
											</tr>
											<tr>
												<td><a href="http://issues.razuna.com/" target="_blank">Razuna Issue Platform</a></td>
											</tr>
										</table>
									</cfcachecontent>
								</div>
							</cfif>
							<cfif cs.tab_razuna_blog>
								<div class="pane" id="blog">#defaultsObj.loadinggif("#dynpath#")#</div>
							</cfif>
							<div class="pane" id="twitter"></div>
							<div class="pane" id="facebook">
								<div id="fb-root"></div>
							</div>
						</div>
					</td>
				</tr>
			</table>
		<cfelse>
			<script type="text/javascript">
				loadcontent('rightside','#myself#c.folder&col=F&folder_id=#cs.folder_redirect#');
			</script>
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

