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
<cfcachecontent name="menucms" cachedwithin="#CreateTimeSpan(1,0,0,0)#" region="razcache">
<cfoutput>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="##FFFFFF">
		<td>
			<!--- Page Explorer --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_1">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="27">
									<img src="images/button_menu/pageexplorer_24.png" alt="" width="24" height="24" border="0" align="left">
								</td>
								<td width="212" class="textbold">#defaultsObj.trans("pageexplorer")#</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
				<tr>
					<td valign="top">
						<a href="##" onclick="javascript:loadcontent('rightside','#myself##xfa.pageexplorer#');return false;">&raquo; #defaultsObj.trans("pageexplorer")#</a>
					</td>
				</tr>
			</table>
			<!--- News --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
				<tr>
					<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_2">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="27">
									<img src="images/button_menu/news_24.png" alt="" width="24" height="24" border="0" align="left">
								</td>
								<td width="212" class="textbold">#defaultsObj.trans("news")#</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
				<tr>
					<td valign="top">
						<a href="##" onclick="javascript:loadcontent('rightside','#myself##xfa.news_cat_explorer#');return false;">&raquo; #defaultsObj.trans("news_edit")#</a>
					</td>
				</tr>
			</table>
			<!--- FAQ --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
				<tr>
					<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_3">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="27">
									<img src="images/button_menu/faq_24.png" alt="" width="24" height="24" border="0" align="left">
								</td>
								<td width="212" class="textbold">FAQ</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
				<tr>
					<td valign="top">
						<a href="##" onclick="javascript:loadcontent('rightside','#myself##xfa.faq_cat_explorer#');return false;">&raquo; #defaultsObj.trans("faq_edit")#</a>
					</td>
				</tr>
			</table>
			<!--- Mailing
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
			<tr>
			<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_4"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/mail_24.png" alt="" width="24" height="24" border="0" align="left"></td><td width="212" class="textbold">#defaultsObj.trans("user_mailinglist")#</td></tr></table></td>
			</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
			<tr>
			<td valign="top"><a href="">&raquo; #defaultsObj.trans("mailing_sendmail")#</a></td>
			</tr>
			<tr>
			<td valign="top"><a href="">&raquo; #defaultsObj.trans("mailing_editlists")#</a></td>
			</tr>
			<tr>
			<td valign="top"><a href="">&raquo; #defaultsObj.trans("mailing_archive")#</a></td>
			</tr>
			</table> --->
			<!--- Reports
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
			<tr>
			<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_5"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/chart_24.png" alt="" width="24" height="24" border="0" align="left"></td><td width="212" class="textbold">#defaultsObj.trans("reports")#</td></tr></table></td>
			</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
			<tr>
			<td valign="top"><a href="">&raquo; #defaultsObj.trans("report_stats")# (Website)</a></td>
			</tr>
			<tr>
			<td valign="top"><a href="">&raquo; #defaultsObj.trans("report_stats")# (Media Center)</a></td>
			</tr>
			</table> --->
			<!--- Flex
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
			<tr>
			<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_6"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/flex_24.png" alt="" width="24" height="24" border="0" align="left"></td><td width="212" class="textbold">#defaultsObj.trans("flexbuilder")#</td></tr></table></td>
			</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
			<tr>
			<td valign="top"><a href="">&raquo; #defaultsObj.trans("flexbuilder_list")#</a></td>
			</tr>
			</table> --->


		</td>
	</tr>
</table>
</cfoutput>
</cfcachecontent>