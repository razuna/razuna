<cfoutput>
	<!--- Get LDAP User list --->
	<cfset attributes.showerr = true>
	<cfinvoke component="global.cfc.settings" method="get_ad_server_userlist"  returnvariable="results"  thestruct="#attributes#">
	<!--- Create a new three-column query, specifying the column data types --->
	<form  name="ad_user_form" id="ad_user_form" action="#self#" method="post" >
		<input type="hidden" name="#theaction#" value="c.ad_server_users_save">
		<table width="100%" border="1" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th><input type="checkbox" name="check_all" id="check_all" value="" /></th>
				<th>#myFusebox.getApplicationData().defaults.trans("username")#</th>
				<th>#myFusebox.getApplicationData().defaults.trans("user_first_name")#</th>
				<th>#myFusebox.getApplicationData().defaults.trans("user_last_name")#</th>
				<th>#myFusebox.getApplicationData().defaults.trans("user_company")#</th>
				<th>#myFusebox.getApplicationData().defaults.trans("email")#</th>
				<th>#myFusebox.getApplicationData().defaults.trans("ad_status")#</th>
			</tr>
	        <cfif results.recordcount NEQ 0>
				<cfoutput query="results">
					<!--- AD users details --->
					<input type="hidden" name="user_login_name_#currentrow#" class="#currentrow#" value="#sAMAccountName#" disabled="disabled">
					<input type="hidden" name="user_email_#currentrow#" class="#currentrow#" value="#mail#" disabled="disabled">
					<input type="hidden" name="user_first_name_#currentrow#" class="#currentrow#" value="#givenName#" disabled="disabled">
					<input type="hidden" name="user_last_name_#currentrow#" class="#currentrow#" value="#sn#" disabled="disabled">
					<input type="hidden" name="user_company_#currentrow#" class="#currentrow#" value="#company#" disabled="disabled">
					<input type="hidden" name="user_street_#currentrow#" class="#currentrow#" value="#streetAddress#" disabled="disabled">
					<input type="hidden" name="user_zip_#currentrow#" class="#currentrow#" value="#postalCode#" disabled="disabled">
					<input type="hidden" name="user_city_#currentrow#" class="#currentrow#" value="#l#" disabled="disabled">
					<input type="hidden" name="user_country_#currentrow#" class="#currentrow#" value="#co#" disabled="disabled">
					<input type="hidden" name="user_phone_#currentrow#" class="#currentrow#" value="#telephoneNumber#" disabled="disabled">
					<input type="hidden" name="user_phone_2_#currentrow#" class="#currentrow#" value="#homePhone#" disabled="disabled">
					<input type="hidden" name="user_mobile_#currentrow#" class="#currentrow#" value="#mobile#" disabled="disabled">
					<input type="hidden" name="user_fax_#currentrow#" class="#currentrow#" value="#facsimileTelephoneNumber#" disabled="disabled">
					<cfinvoke component="global.cfc.users" method="check_email"  returnvariable="qCheckUser"  email=#mail# >
					<tr>
						<td valign="top" nowrap width="5%"><cfif qCheckUser.recordcount EQ 0 AND results.mail NEQ ""><input type="checkbox" name="ad_users" class="ad_users" id="ad_users" value="#currentrow#" /></cfif></td>
						<td valign="top" nowrap width="20%">#SamAccountname#</td>
						<td valign="top" nowrap width="20%" >#givenName#</td>
						<td valign="top" nowrap width="20%" >#sn#</td>
						<td valign="top" nowrap width="20%">#company#</td>
						<td valign="top" nowrap width="5%">#mail#</td>
						<td valign="top"><cfif qCheckUser.recordcount NEQ 0>Imported<cfelse>Not Imported</cfif></td>
					</tr>
				</cfoutput>
			</cfif>
		</table>
		<br/><br/>
		<div id="submit">
				<span style="vertical-align:top;">#myFusebox.getApplicationData().defaults.trans("group_by")#:</span>
				<select name="grp_id_assigneds" multiple="multiple" size="5" style="width:150px;">
	    			<cfloop query="qry_groups">
			    		<option value=#grp_id# >#grp_name#</option>
					</cfloop>
				</select>
			<br/><br/>
			<input type="button" name="SubmitUser" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" id="add">
		</div>
	</form>
	<script type="text/javascript">
		$('##check_all').click(function(){
			if (this.checked){
					// select all
					$('.ad_users').attr('checked','checked');
					<cfloop query="results">
						$('.#currentrow#').attr('disabled',false);
					</cfloop>
				}
				else {
					// select none
					$('.ad_users').attr('checked',false);
					<cfloop query="results">
						$('.#currentrow#').attr('disabled',true);
					</cfloop>
				}
		});
		
		//Form data posted based on the checkbox checked values  
		$(".ad_users").on("change", function() {
			if($(this).prop("checked")) {
				 $('.'+$(this).val()).attr('disabled',false);		
			} else {
				 $('.'+$(this).val()).attr('disabled',true);		
			}
		});
		 
		$('##add').on('click', function () {
			// Form url and post data	    
			var url = formaction("ad_user_form");
			var items = formserialize("ad_user_form");
			
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
					destroywindow(1);
					loadcontent('admin_users', '#myself#c.users');
			   	}
			});	   
		});
	</script>
</cfoutput>