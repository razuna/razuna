<cfoutput>
<div class="collapsable">
	<div class="headers">
		<cfif cs.show_bottom_part AND cs.button_basket>
			<a href="##" onclick="$('##thedropbasket').load('#myself##xfa.tobasket#&file_id=#attributes.file_id#-#attributes.cf_show#&thetype=#attributes.file_id#-#attributes.cf_show#');flash_footer('basket');">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</div>
			</a>
		</cfif>
		<cfif cs.button_send_email>
			<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#attributes.file_id#&thetype=#attributes.cf_show#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("send_with_email")#</div>
			</a>
		</cfif>
		<cfif qry_detail.detail.link_kind NEQ "url" AND cs.button_send_ftp>
			<a href="##" onclick="showwindow('#myself##xfa.sendftp#&file_id=#attributes.file_id#&thetype=#attributes.cf_show#','#myFusebox.getApplicationData().defaults.trans("send_with_ftp")#',600,2);return false;">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/go-up-7.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("send_with_ftp")#</div>
			</a>
		</cfif>
		<cfif cs.tab_collections AND cs.button_add_to_collection>
			<a href="##" onclick="showwindow('#myself#c.choose_collection&file_id=#attributes.file_id#-#attributes.cf_show#&thetype=#attributes.cf_show#&artofimage=list&artofvideo=&artofaudio=&artoffile=','#myFusebox.getApplicationData().defaults.trans("add_to_collection")#',600,2);">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/picture-link.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("add_to_collection")#</div>
			</a>
		</cfif>
		<cfif cs.button_print>
			<a href="##" onclick="showwindow('#myself#ajax.topdf_window&folder_id=#qry_detail.detail.folder_id_r#&kind=detail&thetype=#attributes.cf_show#&file_id=#attributes.file_id#','#myFusebox.getApplicationData().defaults.trans("pdf_window_title")#',500,2);return false;">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/preferences-desktop-printer-2.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("tooltip_print")#</div>
			</a>
		</cfif>
		<!--- Shown only to users who are not R --->
		<cfif attributes.folderaccess NEQ "R">
			<!--- Move --->
			<a href="##" onclick="showwindow('#myself#c.move_file&file_id=#attributes.file_id#&type=movefile&thetype=#attributes.cf_show#&folder_id=#qry_detail.detail.folder_id_r#','#myFusebox.getApplicationData().defaults.trans("move_file")#',600,2);">
				<div style="float:left;">
					<img src="#dynpath#/global/host/dam/images/application-go.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:20px;">#myFusebox.getApplicationData().defaults.trans("move_file")#</div>
			</a>
			<!--- Trash --->
			<cfif not isdefined("labelview")>
				<a href="##" onclick="showwindow('#myself#ajax.trash_record&id=#attributes.file_id#&what=#what#&loaddiv=#loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&showsubfolders=#session.showsubfolders#','#myFusebox.getApplicationData().defaults.trans("trash")#',400,2);return false;">
					<div style="float:left;">
						<img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" style="padding-right:3px;" />
					</div>
					<div style="float:left;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("trash_asset")#</div>
				</a>
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