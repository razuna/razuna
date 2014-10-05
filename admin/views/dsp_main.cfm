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
		<!--- If a new version is avaiable we show this table --->
		<cfif newversion.versionavailable EQ "T">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
				<tr>
					<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;">Razuna #newversion.newversionnr# is available. <a href="http://razuna.org/download" target="_blank">Please update now</a>.</td>
				</tr>
			</table>
			<br />
		</cfif>
		<!--- Show alerts when applications could not be found --->
		<cfif appcheck.im NEQ "T">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
				<tr>
					<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;color:##900;">Image Magick is not properly installed! Please check your settings now.</td>
				</tr>
			</table>
			<br />
		<cfelseif appcheck.ff NEQ "T">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
				<tr>
					<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;color:##900;">FFMpeg is not properly installed! Please check your settings now.</td>
				</tr>
			</table>
			<br />
		<cfelseif appcheck.ex NEQ "T">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
				<tr>
					<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;color:##900;">ExifTool is not properly installed! Please check your settings now.</td>
				</tr>
			</table>
			<br />
		<cfelseif appcheck.af NEQ "T">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
				<tr>
					<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;color:##900;">Caution: Your defined Assets folder is not properly setup! Please check with your Administrator to resolve this immediately.</td>
				</tr>
			</table>
			<br />
		</cfif>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="50%" valign="top">
						<div id="tab_intro">
							<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tablepanel">
								<tr>
									<th>#defaultsObj.trans("welcome_to_ecp")#</th>
								</tr>
								<tr>
									<td>#defaultsObj.trans("welcome_text")#</td>
								</tr>
							</table>
						</div>
						<br>
						<div id="tabs_main_setup">
							<ul>
								<li><a href="##check">#defaultsObj.trans("installation_checklist")#</a></li>
								<li><a href="##sysinfo">System Information</a></li>
							</ul>
							<div id="check"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
							<div id="sysinfo">
								<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
									<tr>
										<th colspan="2">Your Razuna Setup</th>
									</tr>
									<tr>
										<td width="100%">#defaultsObj.trans("database_in_use")#</td>
										<td width="1%" nowrap>#application.razuna.thedatabase#</td>
									</tr>
									<tr>
										<td width="100%">#defaultsObj.trans("storage_container")#</td>
										<td width="1%" nowrap>#application.razuna.storage#</td>
									</tr>
									<tr>
										<td width="100%">#defaultsObj.trans("server_platform")#</td>
										<td width="1%" nowrap>#server.OS.Name#</td>
									</tr>
									<tr>
										<td width="100%">#defaultsObj.trans("server_platform_version")#</td>
										<td width="1%" nowrap>#server.os.version#</td>
									</tr>
									<tr>
										<td width="100%">#defaultsObj.trans("coldfusion_product")#</td>
										<td width="1%" nowrap>#server.ColdFusion.ProductName#</td>
									</tr>
									<tr>
										<td width="100%">#defaultsObj.trans("coldfusion_version")#</td>
										<td width="1%" nowrap><cfif server.ColdFusion.ProductName CONTAINS "bluedragon">#server.bluedragon.edition#<cfelse>#server.ColdFusion.ProductVersion#</cfif></td>
									</tr>
									<tr>
										<td width="100%">#defaultsObj.trans("server_url")#</td>
										<td width="1%" nowrap>#cgi.HTTP_HOST#</td>
									</tr>
									<tr>
										<td width="100%">Server ID</td>
										<td width="1%" nowrap>#application.razuna.serverid#</td>
									</tr>
									<tr>
										<td class="list" colspan="2"></td>
									</tr>
								</table>
								<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
 									<cfset variables.mem = systemmemory()>
									<tr>
										<th colspan="2">Memory Allocation</th>
									</tr>
									<tr>
										<td width="100%">SystemMemory Total</td>
										<td width="1%" nowrap>#int(defaultsObj.converttomb(variables.mem.total))# MB</td>
									</tr>
									<tr>
										<td width="100%">SystemMemory Free</td>
										<td width="1%" nowrap>#int(defaultsObj.converttomb(variables.mem.free))# MB</td>
									</tr>
									<tr>
										<td width="100%">SystemMemory Max</td>
										<td width="1%" nowrap>#int(defaultsObj.converttomb(variables.mem.max))# MB</td>
									</tr>
									<tr>
										<td width="100%">SystemMemory Used</td>
										<td width="1%" nowrap>#int(defaultsObj.converttomb(variables.mem.used))# MB</td>
									</tr>
								</table>
							</div>
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
							<li><a href="##raztools">Add-Ons</a></li>
							<li><a href="##support">Support</a></li>
							<li><a href="##blog" onclick="loadcontent('blog','#myself#c.mainblog');">Blog</a></li>
						</ul>
						<!-- tab "panes" -->
						<div class="pane" id="raztools">
							<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
								<tr>
									<td>Hi there. Thank you for using Razuna. In order for you to enjoy Razuna even more we have some additional tools for you available.</td>
								</tr>
								<tr>
									<th><a href="http://razuna.org/whatisrazuna/razunawordpress" target="_blank">Razuna Wordpress Plugin</a></th>
								</tr>
								<tr>
									<td>With the Razuna Wordpress plugin you simply choose assets within Razuna on your Wordpress powered site. There is no need to upload or import them to Wordpress. <a href="http://razuna.org/whatisrazuna/razunawordpress" target="_blank">Read more</a></td>
								</tr>
								<tr>
									<th><a href="https://chrome.google.com/webstore/detail/gliobkpjddpabnjilfghpnkghmigjjcn" target="_blank">Razuna Google Chrome Extension</a></th>
								</tr>
								<tr>
									<td>With the Razuna Google Chrome Extension installed you can browse your assets directly within Chrome. <a href="https://chrome.google.com/webstore/detail/gliobkpjddpabnjilfghpnkghmigjjcn" target="_blank">Read more</a></td>
								</tr>
								<tr>
									<th><a href="http://razuna.org/getinvolved/developers" target="_blank">Razuna API</a></th>
								</tr>
								<tr>
									<td>Razuna features a extensive API for you to expand on and access your assets Head over to our <a href="http://razuna.org/getinvolved/developers" target="_blank">Developer section</a> or directly to the <a href="http://wiki.razuna.com/display/ecp/API+Developer+Guide" target="_blank">API guide</a>. </a></td>
								</tr>
							</table>
						</div>
						<div class="pane" id="support">
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
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
									<td><a href="https://help.razuna.com" target="_blank">Leave us a Feedback</a></td>
								</tr>
								<tr>
									<td><a href="http://wiki.razuna.com/">Documentation (Wiki)</a></td>
								</tr>
								<tr>
									<td><a href="https://help.razuna.com" target="_blank">Join the Razuna Customer Community</a></td>
								</tr>
								<tr>
									<td><a href="http://issues.razuna.com/" target="_blank">Razuna Issue Platform</a></td>
								</tr>
							</table>
						</div>
						<div class="pane" id="blog"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
					</div>
					</td>
				</tr>
			</table>
	</cfoutput>
</div>
<!--- Activate the Tabs on the main page --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_main_support");
	jqtabs("tabs_main_setup");
	loadcontent('check','<cfoutput>#myself#</cfoutput>c.mainchecklist');
</script>

