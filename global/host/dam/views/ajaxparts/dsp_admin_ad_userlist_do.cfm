<cfoutput>
	<!--- Get LDAP User list --->
	<cfinvoke component="global.cfc.settings" method="get_ad_server_userlist"  returnvariable="results"  thestruct="#attributes#">
	<!--- Create a new three-column query, specifying the column data types --->
	<form  name="ad_user_form" id="ad_user_form" action="#self#" method="post" >
		<input type="hidden" name="#theaction#" value="c.ad_server_users_save">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th><input type="checkbox" name="check_all" id="check_all" value="" /></th>
				<th>#myFusebox.getApplicationData().defaults.trans("username")#</th>
				<th nowrap="true">#myFusebox.getApplicationData().defaults.trans("user_first_name")# #myFusebox.getApplicationData().defaults.trans("user_last_name")#</th>
				<th>#myFusebox.getApplicationData().defaults.trans("user_company")#</th>
				<th>eMail</th>
				<th colspan="2"></th>
			</tr>
	        <cfif results.recordcount NEQ 0>
				<cfoutput query="results">
				<input type="hidden" name="acc_email" id="acc_email" value="">
				<cfinvoke component="global.cfc.users" method="check_email"  returnvariable="qCheckUser"  email=#mail#>
				<tr>
					<td valign="top" nowrap width="5%"><cfif qCheckUser.recordcount EQ 0><input type="checkbox" name="ad_users" class="ad_users" id="ad_users" value="" /></cfif></td>
					<td valign="top" nowrap width="30%">#SamAccountname#</td>
					<td valign="top" nowrap width="30%" >#cn#</td>
					<td valign="top" nowrap width="30%">#company#</td>
					<td valign="top" nowrap width="5%">#mail#</td>
				</tr>
				</cfoutput>
			</cfif>
		</table>
		<div id="submit" style="float:right;padding:10px;">
			<div style="float:left;padding-right:10px;">
				<span style="vertical-align:top;">#myFusebox.getApplicationData().defaults.trans("group_by")#:</span>
				<select name="grp_id_assigneds" multiple="multiple" size="5" style="width:150px;">
	    			<cfloop query="qry_groups">
			    		<option value=#grp_id# >#grp_name#</option>
					</cfloop>
				</select>
			</div>
			<input type="button" name="SubmitUser" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" id="add">
		</div>
	</form>
	<script type="text/javascript">
		$('##check_all').click(function(){
			if (this.checked){
					// select all
					$('.ad_users').attr('checked','checked');
				}
				else {
					// select none
					$('.ad_users').attr('checked',false);
				}
		});
		 
		$('##add').on('click', function () {
			var emailValue='';
		    $('input:checked').each(function () {
		        emailValue += $(this).parent().siblings('td').eq(0).text()+'-'+$(this).parent().siblings('td').eq(1).text()+'-'+$(this).parent().siblings('td').eq(3).text()+',';
				$('##acc_email').val(emailValue);
			});
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