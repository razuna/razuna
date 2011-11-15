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
<form action="#self#" method="post" name="userdetailadd" id="userdetailadd">
<input type="hidden" name="#theaction#" value="c.users_save">
<input type="hidden" name="user_id" value="#attributes.user_id#">

<div id="theuser">
	<ul>
		<li><a href="##user">#defaultsObj.trans("user_edit")#</a></li>
		<li><a href="##groups">#defaultsObj.trans("groups")#</a></li>
	</ul>
	<!--- User --->
	<div id="user">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!--- User details --->
		<tr>
			<th colspan="2">#defaultsObj.trans("user_name")# / #defaultsObj.trans("email")#</td>
		</tr>
		<tr>
			<td nowrap="nowrap">#defaultsObj.trans("user_active")#</td>
			<td><input type="checkbox" name="user_active" value="T"<cfif #qry_detail.user_active# EQ "T"> checked</cfif>></td>
		</tr>
		<tr>
			<td valign="top">#defaultsObj.trans("email")#*</td>
			<td><label for="user_email" class="error">Enter a correct eMail address!</label><input type="text" name="user_email" id="user_email" size="45" class="text" value="#qry_detail.user_email#" onkeyup="checkemail();"><div id="checkemaildiv"></div></td>
		</tr>
		<tr>
			<td width="180" valign="top">#defaultsObj.trans("user_name")#*</td>
			<td width="420"><label for="user_login_name" class="error">Enter a Loginname!</label><input type="text" name="user_login_name" id="user_login_name" size="45" value="#qry_detail.user_login_name#" onkeyup="checkusername();"><div id="checkusernamediv"></div></td>
		</tr>
		<tr>
			<th colspan="2">#defaultsObj.trans("password")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("password")#*</td>
			<td><label for="user_pass" class="error">Enter a Password!</label><input type="password" name="user_pass" id="user_pass" size="25" class="text" style="float:left;"><a href="##" onclick="loadcontent('randompass','#myself#c.randompass');return false;"><img src="images/lock_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; padding-left: 3px; vertical-align: middle; float: left;"></a><div id="randompass" style="float:left;padding-left:3px;"></div></td>
		</tr>
		<tr>
			<td nowrap="nowrap">#defaultsObj.trans("password_confirm")#*</td>
			<td><span id="spryconfirm1"><input type="password" name="user_pass_confirm" id="user_pass_confirm" size="25" class="text"></span></td>
		</tr>
		<tr>
			<th colspan="2">#defaultsObj.trans("theuser")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("user_first_name")#*</td>
			<td><label for="user_first_name" class="error">Enter your Firstname!</label><input type="text" name="user_first_name" id="user_first_name" size="45" class="text" value="#qry_detail.user_first_name#"></td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("user_last_name")#*</td>
			<td><label for="user_last_name" class="error">Enter your Lastname!</label><input type="text" name="user_last_name" id="user_last_name" size="45" class="text" value="#qry_detail.user_last_name#"></td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("salutation")#</td>
			<td nowrap="nowrap"><input type="text" name="user_salutation" size="45" class="text" value="#qry_detail.user_salutation#"></td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("user_company")#</td>
			<td><input name="user_company" type="text" size="45" value="#qry_detail.user_company#"></td>
		</tr>
		<!--- <tr>
			<td width="1%" nowrap="nowrap">#defaultsObj.trans("user_street")#</td>
			<td width="100%"><input type="text" name="user_street" size="24" value="#user_street#"> #defaultsObj.trans("user_street_nr")# <input type="text" name="user_street_nr" size="5" value="#user_street_nr#"></td>
		</tr>
		<tr>
			<td width="1%" nowrap="nowrap">#defaultsObj.trans("user_zip")#</td>
			<td width="100%"><input type="text" name="user_zip" size="6" value="#user_zip#"> #defaultsObj.trans("user_city")# <input type="text" name="user_city" size="32" value="#user_city#"></td>
		</tr> --->
		<tr>
			<td>#defaultsObj.trans("user_tel")#</td>
			<td><input name="user_phone" type="text" size="45" value="#qry_detail.user_phone#"></td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("user_fax")#</td>
			<td><input name="user_fax" type="text" size="45" value="#qry_detail.user_fax#"></td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("user_mobile")#</td>
			<td><input name="user_mobile" type="text" size="45" value="#qry_detail.user_mobile#"></td>
		</tr>
		<!--- Payment Options
		<tr>
			<th colspan="2">#defaultsObj.trans("payment_options")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("payment_cc")#</td>
			<td><input type="radio" name="user_payment_cc" value="T"<cfif #qry_detail.user_payment_cc# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="user_payment_cc" value="F"<cfif #qry_detail.user_payment_cc# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("payment_bill")#</td>
			<td><input type="radio" name="user_payment_bill" value="T"<cfif #qry_detail.user_payment_bill# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="user_payment_bill" value="F"<cfif #qry_detail.user_payment_bill# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("payment_pod")#</td>
			<td><input type="radio" name="user_payment_pod" value="T"<cfif #qry_detail.user_payment_pod# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="user_payment_pod" value="F"<cfif #qry_detail.user_payment_pod# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("payment_pre")#</td>
			<td><input type="radio" name="user_payment_pre" value="T"<cfif #qry_detail.user_payment_pre# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="user_payment_pre" value="F"<cfif #qry_detail.user_payment_pre# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
		</tr>
		<tr>
			<td>PayPal</td>
			<td><input type="radio" name="user_payment_paypal" value="T"<cfif #qry_detail.user_payment_paypal# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="user_payment_paypal" value="F"<cfif #qry_detail.user_payment_paypal# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
		</tr>
		 --->
		</table>
	</div>
	<!--- Groups --->
	<div id="groups">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!--- Intranet Extranet --->
		<tr>
		<th colspan="2">#defaultsObj.trans("intranet_area")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("user_intranet_area")#</td>
			<td valign="top"><input type="checkbox" name="intrauser" value="T"<cfif #qry_detail.user_in_dam# EQ "T"> checked</cfif>></td>
		</tr>
		<!--- WEB GROUPS --->
		<cfif qry_groups.recordcount NEQ 0>
			<tr>
				<td valign="top">#defaultsObj.trans("groups")#</td>
				<td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0" class="gridno">
					<cfloop query="qry_groups">
						<tr>
						<td width="1%" nowrap="nowrap"><input type="checkbox" name="webgroup_#qry_groups.grp_id#" value="#grp_id#"<cfif listfind(webgrpnrlist, #grp_id#, ",")> checked</cfif>></td>
						<td nowrap="nowrap">#qry_groups.grp_name#</td>
						<td width="100%">
							<cfif Len(qry_groups.grp_translation_key)>
								&nbsp;:&nbsp;
								#defaultsObj.trans(qry_groups.grp_translation_key)#
							</cfif>
						</td>
						</tr>
					</cfloop>
					</table>
				</td>
			</tr>
		</cfif>
		<!--- ADMIN GROUPS --->
		<tr>
			<th colspan="2">#defaultsObj.trans("adminarea")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("allowedinadmin")#</td>
			<td><input type="checkbox" name="adminuser" value="T" <!--- onClick="admin_group_enable();" ---><cfif #qry_detail.user_in_admin# EQ "T"> checked</cfif>></td>
		</tr>
		<tr>
			<td valign="top">#defaultsObj.trans("groups")#</td>
			<td valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" class="gridno">
				<cfloop query="qry_groups_admin">
					<cfif Request.securityobj.CheckSystemAdminUser()>
						<tr>
							<td width="1%" nowrap="nowrap"><input type="checkbox" name="admin_group_#grp_id#" value="#grp_id#"<cfif #qry_detail.user_in_admin# IS NOT "T"> <!--- disabled ---></cfif>
						<!--- SystemAdmin --->
						<cfif Request.securityobj.CheckSystemAdminGroup(qry_groups_admin.grp_id)><!---  onclick="admin_group_sa();" ---></cfif>
						<!--- Administrator --->
						<cfif Request.securityobj.CheckAdministratorGroup(qry_groups_admin.grp_id)><!---  onclick="admin_group_ad();" ---></cfif>
						<cfif listfind(grpnrlist, #grp_id#, ",")> checked</cfif>></td>
							<td nowrap="nowrap">#grp_name#</td>
							<td width="100%">
								<cfif Len(qry_groups_admin.grp_translation_key)>
									&nbsp;:&nbsp;
									#defaultsObj.trans(qry_groups_admin.grp_translation_key)#
								</cfif>
							</td>
						</tr>
					<cfelse>
					<!--- not SystemAdmin --->
					<cfif not Request.securityobj.CheckSystemAdminGroup(qry_groups_admin.grp_id)>
					<tr>
						<td width="1%" nowrap="nowrap"><input type="checkbox" name="admin_group_#grp_id#" value="#grp_id#"<cfif #qry_detail.user_in_admin# IS NOT "T"> <!--- disabled ---></cfif>
					<!--- Administrator --->
					<cfif Request.securityobj.CheckAdministratorGroup(qry_groups_admin.grp_id)><!---  onclick="admin_group_ad();" ---></cfif>
						<cfif listfind(grpnrlist, #grp_id#, ",")> checked</cfif>></td>
							<td nowrap="nowrap">#grp_name#</td>
							<td width="100%">
								<cfif Len(qry_groups_admin.grp_translation_key)>
									&nbsp;:&nbsp;
									#defaultsObj.trans(qry_groups_admin.grp_translation_key)#
								</cfif>
							</td>
						</tr>
						</cfif>
					</cfif>
				</cfloop>
				</table>
			</td>
		</tr>
		<!--- Select Hosts for this user, but only if systemadmin --->
		<cfif Request.securityobj.CheckSystemAdminUser()>
		<tr>
			<th colspan="2">#defaultsObj.trans("hosts")#</th>
		</tr>
		<tr>
			<td valign="top"></td>
			<td valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" class="gridno">
					<cfloop query="qry_allhosts">
						<tr>
							<td width="1%" nowrap="nowrap"><input type="checkbox" value="#host_id#" name="hostid"<cfif listfind(hostlist, #host_id#, ",") OR qry_allhosts.recordcount EQ 1> checked<cfelseif session.hostid EQ host_id> checked</cfif>></td>
							<td width="100%" nowrap="nowrap">#host_name#</td>
						</tr>
					</cfloop>
				</table>
			</td>
		</tr>
		</cfif>
		</table>
	</div>
	<div id="submit" style="float:right;padding:10px;"><div id="updatetext" style="color:green;padding:10px;display:none;float:left;"></div><input type="submit" name="Submit" value="#defaultsObj.trans("save")#" class="button"></div>
</div>
</form>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("theuser");
	// Fire the form submit for new or update user
	$(document).ready(function(){
		$("##userdetailadd").validate({
			submitHandler: function(form) {
				jQuery(form).ajaxSubmit({
					success: adminuserfeedback
				});
			},
			rules: {
				user_first_name: "required",
				user_last_name: "required",
			   	user_email: {
			    	required: true,
			     	email: true
			   	},
			   	user_login_name: {
					required: true
				}
			   	<cfif attributes.user_id EQ "0">
			   	,
			   	user_pass: {
					required: true
				},
				user_pass_confirm: {
					required: true,
					equalTo: "##user_pass"
				}
				</cfif>
			 }
		});
	});
	// Feedback when saving form
	function adminuserfeedback() {
		$("##updatetext").css("display","");
		$("##updatetext").html("#JSStringFormat(defaultsObj.trans("success"))#");
		loadcontent('rightside', '#myself#c.users');
	}
	// Check eMail
	function checkemail(){
		loadcontent('checkemaildiv', '#myself#c.checkemail&user_id=#attributes.user_id#&user_email=' + $("##user_email").val() );
	}
	// Check User
	function checkusername(){
		loadcontent('checkusernamediv', '#myself#c.checkusername&user_id=#attributes.user_id#&user_login_name=' + $("##user_login_name").val() );
	}
	
</script>
</cfoutput>