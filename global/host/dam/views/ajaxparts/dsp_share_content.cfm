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
<!--- Storage Decision --->
<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
<cfif session.iscol EQ "F"> <!--- If this is a folder --->
	<cfset thefid = attributes.folder_id>
	<cfset thecolid = 1>
<cfelse> <!--- If this is a collection the folder_id holds the id of the collection --->
	<cfset thefid = 1>
	<cfset thecolid = attributes.folder_id>
</cfif>
<cfset uniqueid = createuuid()>
<cfoutput>
<div id="tabs_shared">
	<!--- Check to see if basket button is not set to hidden --->
	<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
		<ul>
			<li><a href="##shared_thumbs">Thumbnails</a></li>
			<cfif qry_folder.share_comments EQ "T"><li><a href="##shared_list">List</a></li></cfif>
			<li><a href="##shared_basket" id="tabs_shared_basket" onclick="loadcontent('shared_basket','#myself#c.share_basket&jsessionid=#session.SessionID#');">Basket</a></li>
		</ul>
	</cfif>
	<div id="shared_thumbs">
		<form id="formsharedcontent" name="formsharedcontent">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<!--- Header --->
			<tr>
				<td colspan="5">
					<div style="float:left;">
						<cfif qry_folder.share_upload EQ "T">
							<a href="##" onclick="showwindow('#myself#c.asset_add_single&folder_id=#thefid#&jsessionid=#session.SessionID#&fromshare=true','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;" style="padding-right:10px;"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("add_file")#</button></a> 
						</cfif>
						<cfif qry.qry_filecount.thetotal EQ "">0<cfelse>#qry.qry_filecount.thetotal#</cfif> #myFusebox.getApplicationData().defaults.trans("share_content_count")#
						<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
							<a href="##" id="checkallcontent" style="text-decoration:underline;padding-right:10px;padding-left:10px;" class="ddicon">#myFusebox.getApplicationData().defaults.trans("select_all")#</a>
						</cfif>
						<!--- BreadCrumb --->
						<cfif structkeyexists(url,"folder_id_r")>
							<cfif listlen(qry_breadcrumb)>
								<cfset counter = 0>
								<cfloop list="#qry_breadcrumb#" delimiters=";" index="i"><cfif counter EQ 0>/ <a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#&jsessionid=#session.SessionID#');">Home</a><cfelse> / <a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#&folder_id=#ListGetAt(i,2,"|")#&folder_id_r=#ListGetAt(i,3,"|")#&jsessionid=#session.SessionID#');">#ListGetAt(i,1,"|")#</a></cfif><cfset counter = 0 + 1> </cfloop>
							</cfif>
						</cfif>
					</div>
					<div style="float:right;">
						<cfif session.offset GTE 1>
							<!--- For Back --->
							<cfset newoffset = session.offset - 1>
							<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#newoffset#&jsessionid=#session.SessionID#');">< #myFusebox.getApplicationData().defaults.trans("back")#</a> |
						</cfif>
						<cfset showoffset = session.offset * session.rowmaxpage>
						<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
						<cfif qry.qry_filecount.thetotal GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
						<cfif qry.qry_filecount.thetotal GT session.rowmaxpage AND NOT shownextrecord GTE qry.qry_filecount.thetotal> | 
							<!--- For Next --->
							<cfset newoffset = session.offset + 1>
							<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#newoffset#&jsessionid=#session.SessionID#');" style="padding-right:5px;">#myFusebox.getApplicationData().defaults.trans("next")# ></a>
						</cfif>
						<cfif qry.qry_filecount.thetotal GT session.rowmaxpage>
							<cfset thepage = ceiling(qry.qry_filecount.thetotal / session.rowmaxpage)>
							Page: 
								<select id="thepagelistshare" onChange="loadcontent('rightside', $('##thepagelistshare :selected').val());">
								<cfloop from="1" to="#thepage#" index="i">
									<cfset loopoffset = i - 1>
									<option value="#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#loopoffset#&jsessionid=#session.SessionID#"<cfif (session.offset + 1) EQ i> selected</cfif>>#i#</option>
								</cfloop>
								</select>
						</cfif>
					</div>
					<div id="showselect" style="display:none;float:left;padding-top:3px;"><a href="##" id="checkallnone">Deselect all</a><a href="##" style="padding-left:10px;" id="allinbasket">Put selected file(s) in basket</a></div>
					<div id="showselectall" style="display:none;;float:left;padding-left:15px;padding-top:3px;"><strong>All files in this share have been selected!</strong></div>
				</td>
			</tr>
			<tr>
				<td valign="top" align="center">
					<!--- Show Subfolders --->
					<cfif session.iscol EQ "F">
						<cfloop query="qry_subfolders">
							<div class="assetbox" style="text-align:center;">
								<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#&folder_id=#folder_id#&folder_id_r=#folder_id_r#&jsessionid=#session.SessionID#');">
									<div class="theimg">
										<cfif directoryexists("#ExpandPath("../..")#global/host/folderthumbnail/#session.hostid#/#folder_id#")>
											<cfdirectory name="myDir" action="list" directory="#ExpandPath("../../")#global/host/folderthumbnail/#session.hostid#/#folder_id#/" type="file">
											<cfif myDir.RecordCount>
												<img src="#dynpath#/global/host/folderthumbnail/#session.hostid#/#folder_id#/#myDir.name#" border="0"><br />
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0"><br />
											</cfif>
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0"><br />
										</cfif>
									</div>
								<strong>#left(folder_name,50)#</strong></a>
							</div>
						</cfloop>
					</cfif>
					<cfoutput query="qry.qry_files" group="id"> <!--- We need this here since the SQL can not be smplified otherwise --->
						<div class="assetbox">
							<!--- Images --->
							<cfif kind EQ "img">
								<cfif is_available>
									<div class="theimg">
										<!--- Show assets --->
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#?#uniqueid#" border="0">
											</cfif>
										<cfelse>
											<img src="#link_path_url#" border="0">
										</cfif>
									</div>
									<cfif expiry_date EQ '' OR expiry_date GTE now()>
										<!--- Check to see if basket button is not set to hidden --->
										<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
											<div>
												<input type="checkbox" name="file_id" value="#id#-img" onclick="selectone();">
												<a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#-img&thetype=#id#-img&jsessionid=#session.SessionID#');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
											</div>
										</cfif>
									</cfif>
									<br>
									<strong>#left(filename,50)#</strong>
								<cfelse>
									The upload of "#left(filename,50)#" is still in progress!
								</cfif>
							<!--- Videos --->
							<cfelseif kind EQ "vid">
								<cfif is_available>
									<div class="theimg">
										<cfif link_kind NEQ "url"><cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix"><img src="#cloud_url#" border="0"><cfelse>
										<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
										<img src="#thestorage##path_to_asset#/#thethumb#?#uniqueid#" border="0" width="160"></cfif><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0"></cfif>
									</div>
									<cfif expiry_date EQ '' OR expiry_date GTE now()>
										<!--- Check to see if basket button is not set to hidden --->
										<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
											<div>
												<input type="checkbox" name="file_id" value="#id#-vid" onclick="selectone();">
												<a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#-vid&thetype=#id#-vid&jsessionid=#session.SessionID#');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
											</div>
										</cfif>
									</cfif>
									<br>
									<strong>#left(filename,50)#</strong>
								<cfelse>
									The upload of "#left(filename,50)#" is still in progress!
								</cfif>
							<!--- Audios --->
							<cfelseif kind EQ "aud">
								<cfif is_available>
									<div class="theimg">
										<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">
									</div>
									<cfif expiry_date EQ '' OR expiry_date GTE now()>
										<!--- Check to see if basket button is not set to hidden --->
										<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
											<div>
												<input type="checkbox" name="file_id" value="#id#-aud" onclick="selectone();">
												<a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#-aud&thetype=#id#-aud&jsessionid=#session.SessionID#');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
											</div>
										</cfif>
									</cfif>
									<br>
									<strong>#left(filename,50)#</strong>
								<cfelse>
									The upload of "#left(filename,50)#" is still in progress!
								</cfif>
							<!--- All other files --->
							<cfelse>
								<cfif is_available>
									<div class="theimg">
										<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
										<cfif application.razuna.storage EQ "amazon" AND cloud_url NEQ "">
											<img src="#cloud_url#" border="0" img-tt="img-tt">
										<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") >
											<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#?#uniqueid#" border="0" img-tt="img-tt">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0" width="128" height="128" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
										</cfif>
									</div>
									<cfif expiry_date EQ '' OR expiry_date GTE now()>
										<!--- Check to see if basket button is not set to hidden --->
										<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
											<div>
												<input type="checkbox" name="file_id" value="#id#-doc" onclick="selectone();">
												<a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#-doc&thetype=#id#-doc&jsessionid=#session.SessionID#');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
											</div>
										</cfif>
									</cfif>
									<br>
									<strong>#left(filename,50)#</strong>
								<cfelse>
									The upload of "#left(filename,50)#" is still in progress!
								</cfif>
							</cfif>
						</div>
					</cfoutput>
				</td>
			</tr>
		</table>
		</form>
	</div>
	<!--- List View --->
	<cfif qry_folder.share_comments EQ "T">
		<div id="shared_list">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
				<!--- Header --->
				<tr>
					<td colspan="5">
						<div style="float:left;">
							<cfif qry_folder.share_upload EQ "T">
								<a href="##" onclick="showwindow('#myself#c.asset_add_single&folder_id=#thefid#&jsessionid=#session.SessionID#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;">#myFusebox.getApplicationData().defaults.trans("add_file")#</a> | 
							</cfif>
							#qry.qry_filecount.thetotal# #myFusebox.getApplicationData().defaults.trans("share_content_count")#
							<!--- BreadCrumb --->
							<cfif structkeyexists(url,"folder_id_r")>
								| Folder: <cfloop list="#qry_breadcrumb#" delimiters=";" index="i"> / <a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#&folder_id=#ListGetAt(i,2,"|")#&folder_id_r=#ListGetAt(i,3,"|")#&jsessionid=#session.SessionID#');">#ListGetAt(i,1,"|")#</a> </cfloop>
							</cfif>
						</div>
						<div style="float:right;">
							<cfif session.offset GTE 1>
								<!--- For Back --->
								<cfset newoffset = session.offset - 1>
								<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#newoffset#&jsessionid=#session.SessionID#');">< #myFusebox.getApplicationData().defaults.trans("back")#</a> |
							</cfif>
							<cfset showoffset = session.offset * session.rowmaxpage>
							<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
							<cfif qry.qry_filecount.thetotal GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
							<cfif qry.qry_filecount.thetotal GT session.rowmaxpage AND NOT shownextrecord GTE qry.qry_filecount.thetotal> | 
								<!--- For Next --->
								<cfset newoffset = session.offset + 1>
								<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#newoffset#&jsessionid=#session.SessionID#');" style="padding-right:5px;">#myFusebox.getApplicationData().defaults.trans("next")# ></a>
							</cfif>
							<cfif qry.qry_filecount.thetotal GT session.rowmaxpage>
								<cfset thepage = ceiling(qry.qry_filecount.thetotal / session.rowmaxpage)>
								Page: 
									<select id="thepagelistshare" onChange="loadcontent('rightside', $('##thepagelistshare :selected').val());">
									<cfloop from="1" to="#thepage#" index="i">
										<cfset loopoffset = i - 1>
										<option value="#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#loopoffset#&jsessionid=#session.SessionID#"<cfif (session.offset + 1) EQ i> selected</cfif>>#i#</option>
									</cfloop>
									</select>
							</cfif>
						</div>
					</td>
				</tr>
				<!--- List assets --->
				<cfoutput query="qry.qry_files" group="id">
					<tr class="thumbview">
						<td valign="top" style="width:200px;">
							<!--- Images --->
							<cfif kind EQ "img">
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<img src="#cloud_url#" border="0">
									<cfelse>
										<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#?#uniqueid#" border="0">
									</cfif>
								<cfelseif link_kind EQ "url">
									<img src="#link_path_url#" border="0" width="120">
								</cfif>
								<cfif expiry_date EQ '' OR expiry_date GTE now()>
									<!--- Check to see if basket button is not set to hidden --->
									<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
									<br><a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#-img&thetype=#id#-img&jsessionid=#session.SessionID#');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">
									</cfif>
								</cfif>
							<!--- Videos --->
							<cfelseif kind EQ "vid">
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<img src="#cloud_url#" border="0" width="160">
									<cfelse>
										<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
										<img src="#thestorage##path_to_asset#/#thethumb#?#uniqueid#" border="0" width="160">
									</cfif>
								<cfelseif link_kind EQ "url">
									<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0" width="128" height="128">
								</cfif>
								<cfif expiry_date EQ '' OR expiry_date GTE now()>
									<!--- Check to see if basket button is not set to hidden --->
									<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
									<br><a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#-vid&thetype=#id#-vid&jsessionid=#session.SessionID#');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">
									</cfif>
								</cfif>
							<!--- Audios --->
							<cfelseif kind EQ "aud">
								<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" width="120" border="0">
								<cfif expiry_date EQ '' OR expiry_date GTE now()>
									<!--- Check to see if basket button is not set to hidden --->
									<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
									<br><a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#-aud&thetype=#id#-aud&jsessionid=#session.SessionID#');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">
									</cfif>
								</cfif>
							<!--- All other files --->
							<cfelse>
								<!--- Show the thumbnail --->
								<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
								<cfif application.razuna.storage EQ "amazon" AND cloud_url NEQ "">
									<img src="#cloud_url#" border="0" img-tt="img-tt">
								<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") >
									<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#?#uniqueid#" border="0" img-tt="img-tt">
								<cfelse>
									<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0" width="128" height="128" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
								</cfif>
								<cfif expiry_date EQ '' OR expiry_date GTE now()>
									<!--- Check to see if basket button is not set to hidden --->
									<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
									<br><a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#-doc&thetype=#id#-doc&jsessionid=#session.SessionID#');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">
									</cfif>
								</cfif>
							</cfif>
							<cfif expiry_date EQ '' OR expiry_date GTE now()>
								<!--- Check to see if basket button is not set to hidden --->
								<cfif cs.button_basket AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
							#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
								</cfif>
							</cfif>
						</td>
						<td valign="top"><b>#filename#</b><cfif description NEQ ""><br />#description#</cfif><br />
							<div style="width:300px;">
								<!--- Load latest comment and links --->
								<div id="divlatcomment#id#"></div>
								<br />
								#myFusebox.getApplicationData().defaults.trans("comments_title")#<br />
								<textarea id="comment#id#" style="width:300px;height:40px;"></textarea><br />
								<div style="float:right;"><a href="##" onclick="addcomment('#id#','#kind#');return false;" style="text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("comments_submit")#</a></div>
								<div style="clear:right;padding-top:10px;" />
								<div id="div#id#" style="display:none;background-color:##CCC;height:200px;overflow:scroll;"><p></p></div>
							</div>
							<!--- JS for Slide Effects --->
							<script type="text/javascript">
								// Load latest comment
								loadcontent('divlatcomment#id#','#myself#c.share_comments_latest&file_id=#id#&type=#kind#&jsessionid=#session.SessionID#');
							</script>
						</td>
					</tr>
				</cfoutput>
			</table>
		</div>
	</cfif>
	<!--- Basket --->
	<div id="shared_basket"></div>
</div>
<script type="text/javascript">
	jqtabs("tabs_shared");
	<cfif structkeyexists(attributes,"tab")>
		$('##tabs_shared').tabs('option', 'active',1);
	</cfif>
	// Select All from Content
	$('##checkallcontent').click(function () {
		// Loop over the checkboxes
		$('##shared_thumbs :checkbox').each( function() {
			// Check all and display divs
			$(this).prop('checked', true);
			$('##showselect').css('display','');
			$('##showselectall').css('display','');
		})
		// Store all
		$('##loaddummy').load('#myself#c.store_file_all', { folder_id: "#thefid#", thekind: "all", collection_id: "#thecolid#"});
		return false;
	});
	// Deselect all
	$('##checkallnone').click(function () {
		$('##shared_thumbs :checkbox').each( function() {
			$(this).prop('checked', false);
			$('##showselect').css('display','none');
			$('##showselectall').css('display','none');
		})
		// Empty storage
		$('##loaddummy').load('#myself#c.store_file_search', { fileids: 0 });
		return false;
	});
	// Put all into basket
	$('##allinbasket').click(function () {
		// Add the to the basket
		$('##loaddummy').load('#myself#c.basket_put_include', { jsessionid: '#session.SessionID#', fromshare: "T" }, function(){
	   		$.sticky('<span style="color:green;font-weight:bold;">All files have been added to the basket</span>');
	   	});
		return false;
	});
	// Select one
	function selectone(){
		// get how many are selected
	    var n = $('##shared_thumbs input:checked').length;
	    // Open or close selection
	    if (n > 0) {
			$('##showselect').css('display','');
		}
		if (n == 0) {
			$('##showselect').css('display','none');
		}
		// Always hide the status of select all
		$('##showselectall').css('display','none');
		// Set empty var
		var theids = '';
		// Loop over all checked boxes and add them
		$('##shared_thumbs :checkbox:checked').each( function() {
			$(this).prop('checked', true);
			$('##showselect').css('display','');
			theids += $(this).val() + ',';
		})
		// Store IDs
		$('##loaddummy').load('#myself#c.store_file_values', { folder_id: "#thefid#", file_id: theids, collection_id: "#thecolid#" });
	}
</script>
</cfoutput>