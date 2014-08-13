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
	<script type="text/javascript"  src='#dynpath#/global/js/ckeditor/ckeditor.js'> </script>
	<script type="text/javascript">
		CKEDITOR.replace( 'folder_subscribe_body',{height:100} );
		CKEDITOR.replace( 'asset_expiry_body',{height:100}  );
		CKEDITOR.replace( 'duplicates_body',{height:100}  );
		CKEDITOR.replace( 'set2_new_user_email_body' );
		// Activate Chosen
		$(".chzn-select").chosen({search_contains: true});
	</script>
	#myFusebox.getApplicationData().defaults.trans("email_setup_intro")#<br>
	#myFusebox.getApplicationData().defaults.trans("email_setup_desc")#

	<cfform name="form_admin_notification" id="form_admin_notification" method="post" action="#self#">
		<cfinput type="hidden" name="#theaction#" value="c.admin_notification_save">
		
		<!--- Set the FROM address for emails --->
			<h4>#myFusebox.getApplicationData().defaults.trans("from_email_header")#</h4>
			#myFusebox.getApplicationData().defaults.trans("from_email_desc")#
			<input type="text" name="set2_email_from" size="60" value="#attributes.notifications.set2_email_from#" /></td>
			<hr/>
			<!--- email settings for new registration from site --->
			<h4>#myFusebox.getApplicationData().defaults.trans("intranet_new_registration")#</h4>
			<table border"0">
			<tr>
				<td colspan="2">
				#myFusebox.getApplicationData().defaults.trans("intranet_new_registration_desc")#
				</td>
			</tr>
			<tr>
				<td width="10%" nowrap="nowrap">
				#myFusebox.getApplicationData().defaults.trans("intranet_new_registration_emails")#
				</td>
				<td align="left">
				<input type="text" name="set2_intranet_reg_emails" size="60" value="#attributes.notifications.set2_intranet_reg_emails#" /><br />
				</td>
			</tr>
			<tr>
				<td colspan="2" valign="top" align="top">
				<i>#myFusebox.getApplicationData().defaults.trans("multiple_emails")#</i>
				</td>
			</tr>
			<tr>
				<td width="10%" nowrap="nowrap">
				#myFusebox.getApplicationData().defaults.trans("intranet_new_registration_email_subject")#
				</td>
				<td align="left">
				<input type="text" name="set2_intranet_reg_emails_sub" size="60" value="#attributes.notifications.set2_intranet_reg_emails_sub#" />
				</td>
			</tr>
			</table>
			<hr/>
			<!--- New User Welcome Email settings  --->
			<h4>#myFusebox.getApplicationData().defaults.trans("new_user_email_header")#</h4>
			<table border"0">
			<tr>
				<td colspan="2">
				#myFusebox.getApplicationData().defaults.trans("new_user_email_desc")#
				</td>
			</tr>
			<tr>
				<td width="120">
				#myFusebox.getApplicationData().defaults.trans("new_user_email_subject")#
				</td>
				<td>
				<input type="text" name="set2_new_user_email_sub" size="60" value="#attributes.notifications.set2_new_user_email_sub#" />
				</td>
			<tr>
				<td width="120">
				#myFusebox.getApplicationData().defaults.trans("new_user_email_body")#
				</td>
				<td>
				<textarea name="set2_new_user_email_body"  id="set2_new_user_email_body"  class="ckeditor">
				<cfif  attributes.notifications.set2_new_user_email_body neq "">
					#attributes.notifications.set2_new_user_email_body#
				<cfelse>
				#myFusebox.getApplicationData().defaults.trans("user_login_info_email")# <br>
				Username: $username$<br>
				Password: $password$
				</cfif>
				</textarea>
				</td>
			</tr>
			</table>
			<hr/>

		<h4>#myFusebox.getApplicationData().defaults.trans("folder_subscribe_email_header")# </h4>
		<table border"0">
			<tr>
				<td width="120"><label for="folder_subscribe_subject">#myFusebox.getApplicationData().defaults.trans("the_email_subject")#</label></td>
				<td><cfinput type="text" name="folder_subscribe_subject" id="folder_subscribe_subject" maxlength="50" size="50" value="#attributes.notifications.set2_folder_subscribe_email_sub#"></td>
			</tr>
			<tr>
				<td width="120"><label for="folder_subscribe_body">#myFusebox.getApplicationData().defaults.trans("the_email_intro")#</label></td>
				<td><cftextarea name="folder_subscribe_body" id="folder_subscribe_body">#attributes.notifications.set2_folder_subscribe_email_body#</cftextarea></td>
			</tr>
			<tr>
				<td width="120"><label for="folder_subscribe_meta">#myFusebox.getApplicationData().defaults.trans("the_asset_metadata")#</label></td>
				<td>
				 <select data-placeholder="Choose metadata to include" class="chzn-select" style="width:410px;" name="folder_subscribe_meta" id="folder_subscribe_meta" multiple="multiple">
				        	<option value="" disabled>--- Custom Fields ---</option>
				        	<cfloop query="attributes.meta_cf"><option value="cf_#cf_id#" <cfif listcontains(attributes.notifications.set2_folder_subscribe_meta, "cf_#cf_id#")>selected</cfif>>#cf_text#</option></cfloop>
				        	<option value="" disabled>--- For Images ---</option>
				        	<cfloop collection="#attributes.meta_img#" item="i"><option value="img_#i#" <cfif listcontainsnocase(attributes.notifications.set2_folder_subscribe_meta, "img_#i#")>selected</cfif>>#structfind(attributes.meta_img,i)#</option></cfloop>
				        	<option value="" disabled>--- For Documents (PDF) ---</option>
				        	<cfloop list="#attributes.meta_doc#" index="i" delimiters=","><option value="doc_#i#" <cfif listcontains(attributes.notifications.set2_folder_subscribe_meta, "doc_#i#")>selected</cfif>>#i#</option></cfloop>
			        	</select>
			        	</td>
		        </tr>
		</table>
		<hr/>
		<h4>#myFusebox.getApplicationData().defaults.trans("asset_expiry_email_header")#</h4>
		<table border"0">
			<tr>
			<td width="120"><label for="asset_expiry_subject">#myFusebox.getApplicationData().defaults.trans("the_email_subject")#</label></td>
			<td><cfinput type="text" name="asset_expiry_subject" id="asset_expiry_subject" maxlength="50" size="50" value="#attributes.notifications.set2_asset_expiry_email_sub#"></td>
			</tr>
			<tr>
			<td width="120"><label for="asset_expiry_body">#myFusebox.getApplicationData().defaults.trans("the_email_intro")#</label></td>
			<td><cftextarea name="asset_expiry_body" id="asset_expiry_body">#attributes.notifications.set2_asset_expiry_email_body#</cftextarea></td>
			</tr>
			<tr>
				<td width="120"><label for="asset_expiry_meta">#myFusebox.getApplicationData().defaults.trans("the_asset_metadata")#</label></td>
				<td>
				 <select data-placeholder="Choose metadata to include" class="chzn-select" style="width:410px;" name="asset_expiry_meta" id="asset_expiry_meta" multiple="multiple">
				        	<option value="" disabled>--- Custom Fields ---</option>
				        	<cfloop query="attributes.meta_cf"><option value="cf_#cf_id#" <cfif listcontains(attributes.notifications.set2_asset_expiry_meta, "cf_#cf_id#")>selected</cfif>>#cf_text#</option></cfloop>
				        	<option value="" disabled>--- For Images ---</option>
				        	<cfloop collection="#attributes.meta_img#" item="i"><option value="img_#i#" <cfif listcontainsnocase(attributes.notifications.set2_asset_expiry_meta, "img_#i#")>selected</cfif>>#structfind(attributes.meta_img,i)#</option></cfloop>
				        	<option value="" disabled>--- For Documents (PDF) ---</option>
				        	<cfloop list="#attributes.meta_doc#" index="i" delimiters=","><option value="doc_#i#" <cfif listcontains(attributes.notifications.set2_asset_expiry_meta, "doc_#i#")>selected</cfif>>#i#</option></cfloop>
			        	</select>
			      	</td>
		        </tr>
		</table>
		<hr/>
		<h4>#myFusebox.getApplicationData().defaults.trans("duplicate_email_header")#</h4>
		#myFusebox.getApplicationData().defaults.trans("duplicate_email_desc")#
		<table border"0">
			<tr>
				<td width="120"><label for="duplicates_subject">#myFusebox.getApplicationData().defaults.trans("the_email_subject")#</label></td>
				<td><cfinput type="text" name="duplicates_subject" id="duplicates_subject" maxlength="50" size="50" value="#attributes.notifications.set2_duplicates_email_sub#"></td>
			</tr>
			<tr>
				<td width="120"><label for="duplicates_body">#myFusebox.getApplicationData().defaults.trans("the_email_content")#</label></td>
				<td><cftextarea name="duplicates_body" id="duplicates_body"><cfif len(attributes.notifications.set2_duplicates_email_body) LT 10>
					Hi there. The file $filename$ already exists in Razuna and thus was not added to the system!
					The file exists at the following locations: $location$
				<cfelse> #attributes.notifications.set2_duplicates_email_body#</cfif></cftextarea></td>
			</tr>
			<tr>
				<td width="120"><label for="duplicates_meta">#myFusebox.getApplicationData().defaults.trans("the_asset_metadata")#</label></td>
				<td>
				 <select data-placeholder="Choose metadata to include" class="chzn-select" style="width:410px;" name="duplicates_meta" id="duplicates_meta" multiple="multiple">
				        	<option value="" disabled>--- Custom Fields ---</option>
				        	<cfloop query="attributes.meta_cf"><option value="cf_#cf_id#" <cfif listcontains(attributes.notifications.set2_duplicates_meta, "cf_#cf_id#")>selected</cfif>>#cf_text#</option></cfloop>
				        	<option value="" disabled>--- For Images ---</option>
				        	<cfloop collection="#attributes.meta_img#" item="i"><option value="img_#i#" <cfif listcontainsnocase(attributes.notifications.set2_duplicates_meta, "img_#i#")>selected</cfif>>#structfind(attributes.meta_img,i)#</option></cfloop>
				        	<option value="" disabled>--- For Documents (PDF) ---</option>
				        	<cfloop list="#attributes.meta_doc#" index="i" delimiters=","><option value="doc_#i#" <cfif listcontains(attributes.notifications.set2_duplicates_meta, "doc_#i#")>selected</cfif>>#i#</option></cfloop>
			        	</select>
		        		</td>
		        </tr>
		</table>
		<br/>
		<div id="form_admin_notification_status" style="float:left;font-weight:bold;color:green;"></div>
		<div style="float:right;"><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>
		<br/><br/>
	</cfform>
	<!--- JS --->
	<script language="JavaScript" type="text/javascript">
		// Submit Form
		$("##form_admin_notification").submit(function(e){
			// Need to update ckeditor text area before form submit so that the current value is grabbed on submit for AJAX call
			CKEDITOR.instances["folder_subscribe_body"].updateElement();
			CKEDITOR.instances["asset_expiry_body"].updateElement();
			CKEDITOR.instances["duplicates_body"].updateElement();
			CKEDITOR.instances["set2_new_user_email_body"].updateElement();
			if ($('##set2_new_user_email_body').val().length >=4000)
				{
				alert ('Email body must be less than 4000 characters. '); 
				return false;
				}
			if ($('##folder_subscribe_body').val().length >=1000 || $('##asset_expiry_body').val().length >=1000 || $('##duplicates_body').val().length >=1000)
			{
			alert ('Email introdutcions must be less than 1000 characters. '); 
			return false;
			}
			if ($('##duplicates_body').val().length >=2000)
			{
			alert ('Email content must be less than 2000 characters. '); 
			return false;
			}
			// Get values
			var url = formaction("form_admin_notification");
			var items = formserialize("form_admin_notification");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
			   		$('##form_admin_notification_status').html('#myFusebox.getApplicationData().defaults.trans("success")#').animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			   	}
			});
			return false;
		});
	</script>	
</cfoutput>