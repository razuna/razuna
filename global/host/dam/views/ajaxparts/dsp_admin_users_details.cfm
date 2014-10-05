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

<!--- Turn expiry date input into a jQuery datepicker --->
  <script>
	  $(function() {
	    $( "#user_expirydate" ).datepicker();
	  });
  </script>
  <cfoutput>
<form action="#self#" method="post" name="userdetailadd" id="userdetailadd">
<input type="hidden" name="#theaction#" value="c.users_save">
<input type="hidden" name="user_id" value="#attributes.user_id#">
<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
<div id="tab_admin_user">
	<ul>
		<cfif attributes.user_id eq 0>
			<li><a href="##tab_user">#myFusebox.getApplicationData().defaults.trans("user_add")#</a></li>
		<cfelse>
			<li><a href="##tab_user">#myFusebox.getApplicationData().defaults.trans("user_edit")#</a></li>
		</cfif>
		<li><a href="##tab_groups">#myFusebox.getApplicationData().defaults.trans("groups")#</a></li>
		<cfif jr_enable EQ "true"><li><a href="##tab_logins">#myFusebox.getApplicationData().defaults.trans("tab_users_social_accounts")#</a></li></cfif>
		<cfif attributes.add EQ "f">
			<li><a href="##tab_api" onclick="loadcontent('tab_api','#myself#c.admin_user_api&user_id=#attributes.user_id#&grpnrlist=#grpnrlist#');">API Key</a></li>
		</cfif>
	</ul>
	<!--- User --->
	<div id="tab_user">
		<table width="460" border="0" cellspacing="0" cellpadding="0" class="grid">
			<!--- User details --->
			<!--- Don't show if from myinfo --->
			<cfif attributes.myinfo>
				<input type="hidden" name="user_active" value="#qry_detail.user_active#">
			<cfelse>
				<tr>
					<td nowrap="nowrap"><strong>#myFusebox.getApplicationData().defaults.trans("user_active")#</strong></td>
					<td><input type="checkbox" name="user_active" value="T"<cfif qry_detail.user_active EQ "T" OR qry_detail.recordcount EQ 0> checked</cfif>></td>
				</tr>
			</cfif>
			<tr>
				<td width="130" nowrap="true">
					<strong>#myFusebox.getApplicationData().defaults.trans("email")#*</strong>
				</td>
				<td width="300"><input type="text" name="user_email" id="user_email" style="width:300px;" class="text" value="#qry_detail.user_email#"<!--- <cfif attributes.add EQ "F"><a href="mailto:#qry_detail.user_email#" title="Opens your email app to send email to user">email user</a></cfif> ---></td>
			</tr>
			<tr>
				<td width="180"><strong>#myFusebox.getApplicationData().defaults.trans("user_name")#*</strong></td>
				<td width="420">
				<cfif structKeyExists(attributes,"user_id") AND attributes.user_id NEQ 0 AND qry_detail.user_pass EQ "" >
					<input type="text" name="user_login_name_show" id="user_login_name_show" style="width:300px;" value="#qry_detail.user_login_name#"  disabled>
					<input type="hidden" name="user_login_name" id="user_login_name"  value="#qry_detail.user_login_name#"  >
				<cfelse>
					<input type="text" name="user_login_name" id="user_login_name" style="width:300px;" value="#qry_detail.user_login_name#">
				</cfif>
				</td>
			</tr>
			<tr>
				<th colspan="2"><br /></th>
			</tr>
			<tr>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("password")#*</strong></td>
				<td><input type="password" name="user_pass" id="user_pass" style="width:300px;" class="text" style="float:left;" <cfif attributes.user_id EQ 0><cfelseif qry_detail.user_pass EQ "">disabled</cfif>></td>
			</tr>
			<tr>
				<td nowrap="nowrap" valign="top"><strong>#myFusebox.getApplicationData().defaults.trans("password_confirm")#*</strong></td>
				<td><span id="spryconfirm1"><input type="password" name="user_pass_confirm" id="user_pass_confirm" style="width:300px;" class="text" <cfif attributes.user_id EQ 0><cfelseif qry_detail.user_pass EQ "">disabled</cfif>></span><br ><cfif qry_detail.user_pass NEQ "" OR attributes.user_id EQ 0><a href="##" onclick="loadpass();return false;" title="Click here to generate a secure password">Generate password</a></cfif><div id="randompass"></div></td>
			</tr>
			<tr>
				<th colspan="2"><br /></th>
			</tr>
			<tr>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("user_first_name")#*</strong></td>
				<td><input type="text" name="user_first_name" id="user_first_name" style="width:300px;" class="text" value="#qry_detail.user_first_name#"<!---  onchange="salut_first2();" --->><label for="user_first_name" class="error">Enter your Firstname!</label></td>
			</tr>
			<tr>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("user_last_name")#*</strong></td>
				<td><input type="text" name="user_last_name" id="user_last_name" style="width:300px;" class="text" value="#qry_detail.user_last_name#"<!---  onchange="salut_last2();" --->><label for="user_last_name" class="error">Enter your Lastname!</label></td>
			</tr>
			<tr>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("salutation")#</strong></td>
				<td nowrap="nowrap"><input type="text" name="user_salutation" style="width:300px;" class="text" value="#qry_detail.user_salutation#"></td>
			</tr>
			<tr>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("user_company")#</strong></td>
				<td><input name="user_company" type="text" style="width:300px;" value="#qry_detail.user_company#"></td>
			</tr>
			<tr>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("user_tel")#</strong></td>
				<td><input name="user_phone" type="text" style="width:300px;" value="#qry_detail.user_phone#"></td>
			</tr>
			<tr>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("user_fax")#</strong></td>
				<td><input name="user_fax" type="text" style="width:300px;" value="#qry_detail.user_fax#"></td>
			</tr>
			<tr>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("user_mobile")#</strong></td>
				<td><input name="user_mobile" type="text" style="width:300px;" value="#qry_detail.user_mobile#"></td>
			</tr>
			<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
				<tr>
					<td><strong>#myFusebox.getApplicationData().defaults.trans("user_expirydate")#</strong></td>
					<td><input name="user_expirydate" id="user_expirydate" type="text" style="width:300px;" value="#dateformat(qry_detail.user_expiry_date,'mm/dd/yyyy')#"></td>
				</tr>
				<tr>
					<td></td>
					<td>#myFusebox.getApplicationData().defaults.trans("user_expirydate_desc")#</td>
				</tr>
			</cfif>
			<!--- If there is search selection --->
			<cfif cs.search_selection>
				<tr>
					<td><strong>#myFusebox.getApplicationData().defaults.trans("default_search_selection")#</strong></td>
					<td>
						<select data-placeholder="" class="chzn-select" name="user_search_selection" id="user_search_selection" style="min-width:300px;">
							<option value=""></option>
							<cfloop query="qry_search_selection">
								<option value="#folder_id#"<cfif qry_detail.user_search_selection EQ "#folder_id#"> selected="selected"</cfif>>#folder_name#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			</cfif>
			<!--- Show User id --->
			<cfif attributes.add EQ "f">
				<tr>
					<td><strong>ID</strong></td>
					<td>#qry_detail.user_id#</td>
				</tr>
			</cfif>
		</table>
		<!--- Custom fields --->
		<cfif qry_cf.recordcount NEQ 0>
			<cfset cf_id = session.theuserid>
			<br />
			<div id="customfields" style="padding-top:10px;">
				<cfinclude template="inc_custom_fields.cfm">
			</div>
			<div stlye="clear:both;"></div>
		</cfif>
	</div>
	<!--- Groups --->
	<div id="tab_groups">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!--- WEB GROUPS --->
			<tr>
				<td valign="top">
					<!--- Since this can now be viewed by the user himself we only show selection for admins --->
					<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
						<!--- We come from myinfo --->
						<cfif attributes.myinfo>
							<!--- If SysAdmin or Admin --->
							<cfif Request.securityobj.CheckSystemAdminUser()>
								<input type="hidden" name="admin_group_1" value="1">
								#myFusebox.getApplicationData().defaults.trans("sysadmin_access")#
							<cfelseif Request.securityobj.CheckAdministratorUser()>
								<input type="hidden" name="admin_group_2" value="2">
								#myFusebox.getApplicationData().defaults.trans("admin_access")#
							</cfif>
						<!--- Called within detail page --->
						<cfelseif !attributes.myinfo>
							<!--- If this is the only admin --->
							<cfif qry_groups_users.recordcount EQ 1 AND attributes.user_id EQ qry_groups_users.user_id>
								<cfif listfind(grpnrlist,"1",",")>
									<input type="hidden" name="admin_group_1" value="1">
								</cfif>
								<cfif listfind(grpnrlist,"2",",")>
									<input type="hidden" name="admin_group_2" value="2">
								</cfif>
								#myFusebox.getApplicationData().defaults.trans("admin_access")#
							<!--- There are more admin accounts thus show checkbox for admin --->
							<cfelse>
								<input type="checkbox" name="admin_group_2" id ="admin_group_2" value="2" onchange="togglegrps();checkmultitenant();"<cfif listfind(grpnrlist,"2",",") AND attributes.user_id NEQ 0> checked</cfif>> Administrator
							</cfif>
							<br /><br />
							<cfif !(qry_groups_users.recordcount EQ 1 AND attributes.user_id EQ qry_groups_users.user_id)>
								<!--- Show the rest of the groups  --->
								<div id="nonadmingrps">
									<cfloop query="qry_groups">
										<input type="checkbox" name="webgroup_#qry_groups.grp_id#" value="#grp_id#"<cfif listfind(webgrpnrlist, #grp_id#, ",")> checked</cfif>> #qry_groups.grp_name# <cfif Len(qry_groups.grp_translation_key)> &nbsp;:&nbsp; #myFusebox.getApplicationData().defaults.trans(qry_groups.grp_translation_key)#</cfif>
										<br />
									</cfloop>
								</div>
							</cfif>
						</cfif>
					<!--- simply show the names of the groups for non admin users --->
					<cfelse>
						You are a member of the following group(s):<br /><br />
						<cfloop query="qry_groups">
							<cfif listfind(webgrpnrlist, #grp_id#, ",")>
								<input type="hidden" name="webgroup_#qry_groups.grp_id#" value="#grp_id#">
								#qry_groups.grp_name#<br />
							</cfif>
						</cfloop>
					</cfif>
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
	<cfif attributes.add EQ "f">
		<div id="tab_api"></div>
	</cfif>
</div>
<div id="updatetext" style="color:green;display:none;float:left;font-weight:bold;padding:15px 0px 0px 10px;"></div>
<div id="dialog-confirm-admin" style="display:none;"><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 250px 0;"></span>This user has access to the following tenants: #valuelist(qry_userhosts.host_name)#.<br/><br/>If you choose to make this user an administrator it will automatically become an administrator for all tenants it has access to and any groups assignments for the user will be lost.</div>
<div id="dialog-confirm-admin2" style="display:none;"><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 250px 0;"></span>This user has access to the following tenants: #valuelist(qry_userhosts.host_name)#.<br/><br/>If you choose to remove this user as an administrator then it will also be removed as administrator from all other tenants.</div>
<div id="submit" style="float:right;padding:10px;">
	<cfif !attributes.myinfo><input type="checkbox" value="true" name="emailinfo" /> <span style="padding-right:15px;">Send user welcome email</span></cfif><input type="submit" name="SubmitUser" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>

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
			     	email: true,
			     	remote: <cfoutput>"#myself#c.checkemail&user_id=" + document.userdetailadd.user_id.value,</cfoutput>
			   	},
			   	user_login_name: {
					required: true,
					remote: <cfoutput>"#myself#c.checkusername&user_id=" + document.userdetailadd.user_id.value,</cfoutput>
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
			 },
			 messages:
			 {
			 	user_email: {remote: "This email is already taken."},
			 	user_login_name: {remote: "This username is already taken."}
			 },
 			onkeyup: function(element) { this.element(element); }
		});
	});

	// If user ismultitenant and being set as admin then warn user that it will be admin
	function checkmultitenant()
	{
		if (#listlen(hostlist)# > 1 &&  #listfind(grpnrlist,"2",",")# == 0 && $("##admin_group_2").prop("checked"))
		{
			$( "##dialog-confirm-admin" ).dialog({
				resizable: false,
				height:250,
				modal: true,
				title: 'Warning!',
				buttons: {
					Ok: function() {
						$( this ).dialog( "close" );
					}
				}
			});
		}

	else if (#listlen(hostlist)# > 1 &&  #listfind(grpnrlist,"2",",")# > 0 && $("##admin_group_2").prop("checked")==false)
		{
			$( "##dialog-confirm-admin2" ).dialog({
				resizable: false,
				height:250,
				modal: true,
				title: 'Warning!',
				buttons: {
					Ok: function() {
						$( this ).dialog( "close" );
					}
				}
			});
		}

	}

	function togglegrps()
	{
		if ($("##admin_group_2").prop("checked"))
		{	// Uncheck all group checkboxes if admin selected and disable them
			$("##nonadmingrps input[type=checkbox]").each(function() {
				$(this).prop("checked",false);
				$(this).prop("disabled",true);
			});
		}
		else
		{
			$("##nonadmingrps input[type=checkbox]").each(function() {
				$(this).prop("disabled",false);
			});
		}	
	}
	
	// Feedback when saving form
	function adminuserfeedback() {
		<cfif attributes.user_id EQ "0">
			destroywindow(1);
		<cfelse>
			$("##updatetext").css("display","");
			$("##updatetext").html("#JSStringFormat(myFusebox.getApplicationData().defaults.trans("success"))#")
			$("##updatetext").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
		</cfif>
		<cfif !attributes.myinfo>
			loadcontent('admin_users', '#myself#c.users');
		</cfif>
	}
	// Load Pass
	function loadpass(){
		$("##div_forall").load('#myself#c.randompass', function() {
	  		var thepass = $('##div_forall').html();
	  		$('##randompass').css('display','').html('Generated password is: ' + trim(thepass));
	  		$('##user_pass').val(trim(thepass));
	  		$('##user_pass_confirm').val(trim(thepass));
		})
	}
	
	$(document).ready(function() {
		 togglegrps();
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
	
	    // Activate Chosen
		$(".chzn-select").chosen({search_contains: true});

	});
</script>

</cfoutput>