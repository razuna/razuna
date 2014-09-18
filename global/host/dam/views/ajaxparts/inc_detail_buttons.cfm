<cfoutput>
<cfif  Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
	<cfset isadmin = true>
<cfelse>
	<cfset isadmin = false>
</cfif>
<div class="collapsable">
	<div class="headers">
		<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
			<a href="##" onclick="$('##thedropbasket').load('#myself##xfa.tobasket#&file_id=#attributes.file_id#-#attributes.cf_show#&thetype=#attributes.file_id#-#attributes.cf_show#');flash_footer('basket');">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</div>
			</a>
		</cfif>
		<cfif cs.button_send_email  AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
			<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#attributes.file_id#&thetype=#attributes.cf_show#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("send_with_email")#</div>
			</a>
		</cfif>
		<cfif qry_detail.detail.link_kind NEQ "url" AND cs.button_send_ftp  AND (isadmin OR cs.btn_ftp_slct EQ "" OR listfind(cs.btn_ftp_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_ftp_slct,session.thegroupofuser) NEQ "")>
			<a href="##" onclick="showwindow('#myself##xfa.sendftp#&file_id=#attributes.file_id#&thetype=#attributes.cf_show#','#myFusebox.getApplicationData().defaults.trans("send_with_ftp")#',600,2);return false;">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/go-up-7.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("send_with_ftp")#</div>
			</a>
		</cfif>
		<cfif cs.button_print AND (isadmin OR cs.btn_print_slct EQ "" OR listfind(cs.btn_print_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_print_slct,session.thegroupofuser) NEQ "")>
			<a href="##" onclick="showwindow('#myself#ajax.topdf_window&folder_id=#qry_detail.detail.folder_id_r#&kind=detail&thetype=#attributes.cf_show#&file_id=#attributes.file_id#','#myFusebox.getApplicationData().defaults.trans("pdf_window_title")#',500,2);return false;">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/preferences-desktop-printer-2.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("tooltip_print")#</div>
			</a>
		</cfif>
		<!--- Shown only to users who are not R --->
		<cfif attributes.folderaccess NEQ "R">
			<cfif cs.tab_collections AND cs.button_add_to_collection  AND (isadmin OR cs.btn_collection_slct EQ "" OR listfind(cs.btn_collection_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_collection_slct,session.thegroupofuser) NEQ "")>
				<a href="##" onclick="showwindow('#myself#c.choose_collection&file_id=#attributes.file_id#-#attributes.cf_show#&thetype=#attributes.cf_show#&artofimage=list&artofvideo=&artofaudio=&artoffile=','#myFusebox.getApplicationData().defaults.trans("add_to_collection")#',600,2);">
					<div style="float:left;">
						<img src="#dynpath#/global/host/dam/images/picture-link.png" width="16" height="16" border="0" style="padding-right:3px;" />
					</div>
					<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("add_to_collection")#</div>
				</a>
			</cfif>
			<!--- Move --->
			<cfif cs.icon_move  AND (isadmin OR  cs.icon_move_slct EQ "" OR listfind(cs.icon_move_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.icon_move_slct,session.thegroupofuser) NEQ "")>
				<a href="##" onclick="showwindow('#myself#c.move_file&file_id=#attributes.file_id#&type=movefile&thetype=#attributes.cf_show#&folder_id=#qry_detail.detail.folder_id_r#','#myFusebox.getApplicationData().defaults.trans("move_file")#',600,2);">
					<div style="float:left;">
						<img src="#dynpath#/global/host/dam/images/application-go.png" width="16" height="16" border="0" style="padding-right:3px;" />
					</div>
					<div style="float:left;padding-right:20px;">#myFusebox.getApplicationData().defaults.trans("move_file")#</div>
				</a>
			</cfif>
			<!--- Trash --->
			<cfif NOT isdefined("labelview") AND NOT isdefined("collectionview") AND NOT isdefined("basketview")>
				<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
					<a href="##" onclick="showwindow('#myself#ajax.trash_record&id=#attributes.file_id#&what=#what#&loaddiv=#loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&showsubfolders=#session.showsubfolders#','#myFusebox.getApplicationData().defaults.trans("trash")#',400,2);return false;">
						<div style="float:left;">
							<img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" style="padding-right:3px;" />
						</div>
						<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("trash_asset")#</div>
					</a>
				</cfif>
			</cfif>
			<!--- Plugin being shows with show_in_detail_link_wx  --->
			<cfif structKeyExists(pllink,"pview")>
				<cfloop list="#pllink.pview#" delimiters="," index="i">
					#evaluate(i)#
				</cfloop>
			</cfif>
		</cfif>
	</div>
</div>
</cfoutput>