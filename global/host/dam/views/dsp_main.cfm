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
		<!--- 
		<!--- Nirvanix Usage --->
		<cfif application.razuna.storage EQ "nirvanix" AND structkeyexists(attributes.nvxusage,"limitup")>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
				<tr>
					<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;color:##900;">
						You have exceeded the total amount of storage or traffic for your account for this month. Please login to your <a href="##" onclick="showaccount();">account panel and upgrade</a>!
					</td>
				</tr>
			</table>
			<br />
			
		</cfif>
		 --->
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
							<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tablepanel">
								<tr>
									<th>Razuna Tester</th>
								</tr>
								<tr>
									<td>Thank you for taking this Pre-Release Version of Razuna for a spin. We appreciate your help a lot. To streamline the process of reporting issues that you might find, please <a href="http://groups.google.com/group/razuna-testers" target="_blank">subscribe to the Razuna-Testers Google Group</a>. <br /><br />Please <strong>always</strong> <a href="http://issues.razuna.com" target="_blank">check our issue platform for reported issues first</a>, <strong>before</strong> posting to the group.</td>
								</tr>
								<tr>
									<td>
										<img src="http://groups.google.com/intl/en/images/logos/groups_logo_sm.gif" height=30 width=140 alt="Google Groups"><br />
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
						</cfif>
						<cfcachecontent action="cache" cachename="razunawelcomecache" cachedwithin="#CreateTimeSpan(1,0,0,0)#">
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
							<li><a href="##support">Support for Razuna</a></li>
							<li><a href="##twitter" onclick="window.open('http://twitter.com/razunahq');">Twitter</a></li>
							<li><a href="##facebook" onclick="window.open('http://facebook.com/razunahq');">Facebook</a></li>
							<li><a href="##blog" onclick="loadcontent('blog','#myself#c.mainblog');">Razuna Blog</a></li>
						</ul>
						<!-- tab "panes" -->
						<div class="pane" id="raztools">
							<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
								<tr>
									<td>Hi there. Thank you for using Razuna. In order for your to enjoy Razuna even more we have some additional tools for you available.</td>
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
									<th style="padding-top:15px;"><u>Connect with Razuna</u></th>
								</tr>
								<tr>
									<td><a href="http://twitter.com/razunahq" class="twitter-follow-button">Follow @razunahq</a></td>
								</tr>
								<tr>
									<td><script>(function(d){
  var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
  js = d.createElement('script'); js.id = id; js.async = true;
  js.src = "//connect.facebook.net/en_US/all.js##appId=207944582601260&xfbml=1";
  d.getElementsByTagName('head')[0].appendChild(js);
}(document));</script>
<div class="fb-like" data-href="https://www.facebook.com/razunahq" data-send="true" data-width="350" data-show-faces="true"></div></td>
								</tr>
							</table>
						</div>
						<div class="pane" id="support">
							<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
								<cfif NOT application.razuna.isp>
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
						</div>
						<div class="pane" id="blog">#defaultsObj.loadinggif("#dynpath#")#</div>
						<div class="pane" id="twitter"></div>
						<div class="pane" id="facebook">
							<div id="fb-root"></div>
						</div>
					</div>
				</td>
			</tr>
		</table>
	</cfoutput>
</div>
<!--- Activate the Tabs on the main page --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_main_support");
	function showaccount(){
		win = window.open('','myWin','toolbars=0,location=1,status=1,scrollbars=1,directories=0,width=650,height=600');            
		document.form_account.target='myWin';
		document.form_account.submit();
	}
	// Detect Firebug
	if (window.console && window.console.firebug) {
		//Firebug is enabled
		$("#firebugalert").css({'display':'','padding':'10px','background-color':'#FFFFE0','color':'#900','font-weight':'bold','text-align':'center'});
		$("#firebugalert").html('Hi there, Developer. The Firebug extension can significantly degrade the performance of Razuna. We recommend that you disable it for Razuna!<br />');
	}
</script>
<!--- JS: FOLDERS --->
<cfinclude template="../js/folders.cfm">
<!--- JS: FILES --->
<cfinclude template="../js/files.cfm">
<!--- JS: BASKET --->
<cfinclude template="../js/basket.cfm">
<!--- JS: USERS --->
<cfinclude template="../js/users.cfm">
<!--- JS: GROUPS --->
<cfinclude template="../js/groups.cfm">
<!--- JS: SCHEDULER --->
<cfinclude template="../js/scheduler.cfm">
<!--- JS: SCHEDULER --->
<cfinclude template="../js/custom_fields.cfm">
