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
<div id="tab_admin_user">
	<ul>
		<li><a href="##tab_user">#myFusebox.getApplicationData().defaults.trans("user_edit")#</a></li>
		<li><a href="##tab_groups">#myFusebox.getApplicationData().defaults.trans("groups")#</a></li>
		<cfif jr_enable EQ "true"><li><a href="##tab_logins">#myFusebox.getApplicationData().defaults.trans("tab_users_social_accounts")#</a></li></cfif>
		<cfif attributes.add EQ "f" AND grpnrlist EQ 2>
			<li><a href="##tab_api" onclick="loadcontent('tab_api','#myself#c.admin_user_api&user_id=#attributes.user_id#');">API Key</a></li>
		</cfif>
	</ul>
	<!--- User --->
	<div id="tab_user">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<!--- User details --->
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("user_name")# / #myFusebox.getApplicationData().defaults.trans("email")#</td>
			</tr>
			<tr>
				<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("user_active")#</td>
				<td><input type="checkbox" name="user_active" value="T"<cfif qry_detail.user_active EQ "T"> checked</cfif>></td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("email")#*</td>
				<td><input type="text" name="user_email" id="user_email" size="45" class="text" value="#qry_detail.user_email#" onkeyup="checkemail();"><cfif attributes.add EQ "F"> <a href="mailto:#qry_detail.user_email#" title="Opens your email app to send email to user"><img src="#dynpath#/global/host/dam/images/mail.png" border="0" name="email_2" align="top"></a></cfif><div id="checkemaildiv"></div><label for="user_email" class="error">Enter your eMail address!</label></td>
			</tr>
			<tr>
				<td width="180">#myFusebox.getApplicationData().defaults.trans("user_name")#*</td>
				<td width="420"><input type="text" name="user_login_name" id="user_login_name" size="45" value="#qry_detail.user_login_name#" onkeyup="checkusername();"><div id="checkusernamediv"></div><label for="user_login_name" class="error">Enter your Loginname!</label></td>
			</tr>
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("password")#</th>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("password")#*</td>
				<td><input type="password" name="user_pass" id="user_pass" size="25" class="text" style="float:left;"><a href="##" onclick="loadpass();return false;" title="Click here to generate a secure password"><img src="#dynpath#/global/host/dam/images/lock_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; padding-left: 3px; vertical-align: middle; float: left;"></a><div id="randompass" style="float:left;padding-left:3px;"></div></td>
			</tr>
			<tr>
				<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("password_confirm")#*</td>
				<td><span id="spryconfirm1"><input type="password" name="user_pass_confirm" id="user_pass_confirm" size="25" class="text"></span></td>
			</tr>
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("theuser")#</th>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("user_first_name")#*</td>
				<td><input type="text" name="user_first_name" id="user_first_name" size="45" class="text" value="#qry_detail.user_first_name#"<!---  onchange="salut_first2();" --->><label for="user_first_name" class="error">Enter your Firstname!</label></td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("user_last_name")#*</td>
				<td><input type="text" name="user_last_name" id="user_last_name" size="45" class="text" value="#qry_detail.user_last_name#"<!---  onchange="salut_last2();" --->><label for="user_last_name" class="error">Enter your Lastname!</label></td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("salutation")#</td>
				<td nowrap="nowrap"><input type="text" name="user_salutation" size="45" class="text" value="#qry_detail.user_salutation#"></td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("user_company")#</td>
				<td><input name="user_company" type="text" size="45" value="#qry_detail.user_company#"></td>
			</tr>
			<!--- <tr>
				<td width="1%" nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("user_street")#</td>
				<td width="100%"><input type="text" name="user_street" size="24" value="#user_street#"> #myFusebox.getApplicationData().defaults.trans("user_street_nr")# <input type="text" name="user_street_nr" size="5" value="#user_street_nr#"></td>
			</tr>
			<tr>
				<td width="1%" nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("user_zip")#</td>
				<td width="100%"><input type="text" name="user_zip" size="6" value="#user_zip#"> #myFusebox.getApplicationData().defaults.trans("user_city")# <input type="text" name="user_city" size="32" value="#user_city#"></td>
			</tr> --->
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("user_tel")#</td>
				<td><input name="user_phone" type="text" size="45" value="#qry_detail.user_phone#"></td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("user_fax")#</td>
				<td><input name="user_fax" type="text" size="45" value="#qry_detail.user_fax#"></td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("user_mobile")#</td>
				<td><input name="user_mobile" type="text" size="45" value="#qry_detail.user_mobile#"></td>
			</tr>
		</table>
	</div>
	<!--- Groups --->
	<div id="tab_groups">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!--- WEB GROUPS --->
			<tr>
				<td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0" class="gridno">
					<!--- If SysAdmin or Admin --->
					<cfif Request.securityobj.CheckSystemAdminUser(qry_groups_admin.grp_id) OR Request.securityobj.CheckAdministratorGroup(qry_groups_admin.grp_id)>
						<cfif qry_groups_users.recordcount EQ 1 AND attributes.user_id EQ qry_groups_users.user_id>
							<input type="hidden" name="admin_group_2" value="2">
						</cfif>
						<tr>
							<td style="padding-bottom:10px;"><input type="checkbox" name="admin_group_2" value="2"<cfif grpnrlist EQ 2> checked</cfif><cfif qry_groups_users.recordcount EQ 1 AND attributes.user_id EQ qry_groups_users.user_id> disabled</cfif>></td>
							<td style="padding-bottom:10px;" colspan="2">Administrator</td>
						</tr>
					</cfif>
					<cfloop query="qry_groups">
						<tr>
							<td width="1%" nowrap="nowrap"><input type="checkbox" name="webgroup_#qry_groups.grp_id#" value="#grp_id#"<cfif listfind(webgrpnrlist, #grp_id#, ",")> checked</cfif>></td>
							<td nowrap="nowrap">#qry_groups.grp_name#</td>
							<td width="100%">
								<cfif Len(qry_groups.grp_translation_key)>
									&nbsp;:&nbsp;
									#myFusebox.getApplicationData().defaults.trans(qry_groups.grp_translation_key)#
								</cfif>
							</td>
						</tr>
					</cfloop>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<!--- Social Network Accounts --->
	<cfif jr_enable EQ "true">
		<div id="tab_logins">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
				<tr class="list">
					<td>#myFusebox.getApplicationData().defaults.trans("tab_users_social_accounts_desc")#</td>
				</tr>
				
				
				<tr>
					<td style="padding-top:10px;">
						<!--- List accounts found --->
						<cfloop query="qry_social">
							<div id="input#currentrow#" style="margin-bottom:4px;" class="clonedInput">
						        <input type="text" name="identifier_#currentrow#" id="identifier_#currentrow#" style="width:250px;" value="#identifier#" />
						        <select id="provider_#currentrow#" name="provider_#currentrow#" style="width:250px;">
						        	<option selected="selected">Choose Provider ...</option>
						        	<option value="google"<cfif provider EQ "google"> selected="selected"</cfif>>Google</option>
						        	<option value="twitter"<cfif provider EQ "twitter"> selected="selected"</cfif>>Twitter</option>
						        	<option value="facebook"<cfif provider EQ "facebook"> selected="selected"</cfif>>Facebook</option>
						        	<option value="linkedin"<cfif provider EQ "linkedin"> selected="selected"</cfif>>LinkedIn</option>
						        	<option value="yahoo"<cfif provider EQ "yahoo"> selected="selected"</cfif>>Yahoo!</option>
						        	<option value="openid"<cfif provider EQ "openid"> selected="selected"</cfif>>OpenID</option>
						        	<option value="flickr"<cfif provider EQ "flickr"> selected="selected"</cfif>>Flickr</option>
						        	<option value="paypal"<cfif provider EQ "paypal"> selected="selected"</cfif>>PayPal</option>
						        	<option value="salesforce"<cfif provider EQ "salesforce"> selected="selected"</cfif>>Salesforce</option>
						        	<option value="foursquare"<cfif provider EQ "foursquare"> selected="selected"</cfif>>Foursquare</option>
						        	<option value="aol"<cfif provider EQ "aol"> selected="selected"</cfif>>AOL</option>
						        	<option value="blogger"<cfif provider EQ "blogger"> selected="selected"</cfif>>Blogger</option>
						        	<option value="myspace"<cfif provider EQ "myspace"> selected="selected"</cfif>>MySpace</option>
						        	<option value="verisign"<cfif provider EQ "verisign"> selected="selected"</cfif>>Verisign</option>
						        	<option value="wordpress"<cfif provider EQ "wordpress"> selected="selected"</cfif>>Wordpress</option>
						        	<option value="windowslive"<cfif provider EQ "windowslive"> selected="selected"</cfif>>Windows Live ID</option>
						        </select>
						    </div>
						</cfloop>
						<!--- If no accounts found then show first input field --->
						<cfif qry_social.recordcount EQ 0>
							<div id="input1" style="margin-bottom:4px;" class="clonedInput">
						        <input type="text" name="identifier_1" id="identifier_1" style="width:250px;" />
						        <select id="provider_1" name="provider_1" style="width:250px;">
						        	<option selected="selected">Choose Provider ...</option>
						        	<option value="google">Google</option>
						        	<option value="twitter">Twitter</option>
						        	<option value="facebook">Facebook</option>
						        	<option value="linkedin">LinkedIn</option>
						        	<option value="yahoo">Yahoo!</option>
						        	<option value="openid">OpenID</option>
						        	<option value="flickr">Flickr</option>
						        	<option value="paypal">PayPal</option>
						        	<option value="salesforce">Salesforce</option>
						        	<option value="foursquare">Foursquare</option>
						        	<option value="aol">AOL</option>
						        	<option value="blogger">Blogger</option>
						        	<option value="myspace">MySpace</option>
						        	<option value="verisign">Verisign</option>
						        	<option value="wordpress">Wordpress</option>
						        	<option value="windowslive">Windows Live ID</option>
						        </select>
						    </div>
					    </cfif>
					    <div style="width:50px;height:40px;">
					 		<img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" align="left" id="btnAdd" />
					    	<img src="#dynpath#/global/host/dam/images/list-remove-3.png" width="24" height="24" border="0" align="right" id="btnDel" />
						</div>
					</td>
				</tr>
			</table>
		</div>
	</cfif>
	<!--- API --->
	<cfif attributes.add EQ "f" AND grpnrlist EQ 2>
		<div id="tab_api"></div>
	</cfif>
</div>
<div id="submit" style="float:right;padding:10px;"><div id="updatetext" style="color:green;padding:10px;display:none;float:left;"></div><input type="submit" name="SubmitUser" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>

</form>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	// Initialize Tabs
	jqtabs("tab_admin_user");
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
		<cfif attributes.user_id EQ "0">
			destroywindow(1);
		<cfelse>
			$("##updatetext").css("display","");
			$("##updatetext").html("#JSStringFormat(myFusebox.getApplicationData().defaults.trans("success"))#");
		</cfif>
		loadcontent('admin_users', '#myself#c.users');
	}
	// Load Pass
	function loadpass(){
		$("##randompass").load('#myself#c.randompass', function() {
	  		var thepass = $('##randompass').html();
	  		$('##user_pass').val(thepass);
	  		$('##user_pass_confirm').val(thepass);
		})
	}
	
	$(document).ready(function() {
		<cfif qry_social.recordcount EQ 0>
			$('##btnDel').css('display','none');
		</cfif>
		$('##btnAdd').click(function() {
	        var num     = $('.clonedInput').length; // how many "duplicatable" input fields we currently have
	        var newNum  = new Number(num + 1);      // the numeric ID of the new input field being added
			
	        // create the new element via clone(), and manipulate it's ID using newNum value
	        var newElem = $('##input' + num).clone().attr('id', 'input' + newNum);
	
	        // manipulate the name/id values of the input inside the new element
	        newElem.children(':first').attr('id', 'identifier_' + newNum).attr('name', 'identifier_' + newNum);
	        newElem.children(':nth-child(2)').attr('id', 'provider_' + newNum).attr('name', 'provider_' + newNum);
	      	
	        // Add the fields to the page
	        $('##input' + num).after(newElem)
	        
	        // enable the "remove" button
	        $('##btnDel').css('display','');
			
			// Add the new num as the new radio value
	       /*  $('##radio_' + newNum).val(newNum); */
	         // Reset the values for the new field set
	        $('##identifier_' + newNum).val('');
	        $('##provider_' + newNum).val($('option:first', this).val());
	    });
	
	    $('##btnDel').click(function() {
	        var num = $('.clonedInput').length; // how many "duplicatable" input fields we currently have
	        $('##input' + num).remove();     // remove the last element
	
	        // enable the "add" button
	        $('##btnAdd').attr('disabled',false);
	
	        // if only one element remains, disable the "remove" button
	        if (num-1 == 1)
	            $('##btnDel').css('display','none');
	    });
	
	});
</script>

</cfoutput>