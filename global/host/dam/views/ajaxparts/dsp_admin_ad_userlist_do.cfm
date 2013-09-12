<cfoutput>
	<!--- Get LDAP User list --->
	<cfinvoke component="global.cfc.settings" method="get_ad_server_userlist"  returnvariable="results"  thestruct="#attributes#">
	<!--- Create a new three-column query, specifying the column data types --->
	<form  name="ad_user_form" id="ad_user_form" action="#self#" method="post" >
		<input type="hidden" name="#theaction#" value="c.ad_server_users_save">
		<!---<cfset results = QueryNew("SamAccountname,cn,company,mail", "VarChar,VarChar,VarChar,VarChar")>
		
		<!--- Make two rows in the query --->
		<cfset newRow = QueryAddRow(results, 2)>
		
		<!--- Set the values of the cells in the query --->
		<cfset temp = QuerySetCell(results, "SamAccountname", "Saravanan", 1)>
		<cfset temp = QuerySetCell(results, "cn", "SaravanaMuthu", 1)>
		<cfset temp = QuerySetCell(results, "company", "Mitrahsoft", 1)>
		<cfset temp = QuerySetCell(results, "mail", "saravanan@mitrahsoft.com", 1)>
		<cfset temp = QuerySetCell(results, "SamAccountname", "Kannan", 2)>
		<cfset temp = QuerySetCell(results, "cn", "kannan", 2)>
		<cfset temp = QuerySetCell(results, "company", "Mitrahsoft", 2)>
		<cfset temp = QuerySetCell(results, "mail", "kannan@mitrahsoft.com", 2)>--->	
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
		        emailValue += $(this).parent().siblings('td').eq(0).text()+'-'+$(this).parent().siblings('td').eq(3).text()+',';
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