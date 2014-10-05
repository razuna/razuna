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
	CKEDITOR.replace('message',{height:200} );
</script>
<form name="sendemailform" id="sendemailform" action="#self#" method="post">
<input type="hidden" name="#theaction#" value="#xfa.submit#">
<input type="hidden" name="file_id" value="#attributes.file_id#">
<input type="hidden" name="thetype" value="#attributes.thetype#">
<input type="hidden" name="thepath" value="#thisPath#">
<input type="hidden" name="artofimage" id="sendemailform_artofimage" value="">
<input type="hidden" name="artofvideo" id="sendemailform_artofvideo" value="">
<input type="hidden" name="artofaudio" id="sendemailform_artofaudio" value="">
<input type="hidden" name="artoffile" id="sendemailform_artoffile" value="">
<input type="hidden" name="from" id="sendemailform_from" value="#qryuseremail#">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
	<cfif attributes.frombasket EQ "T">
		<tr>
			<td colspan="2">#myFusebox.getApplicationData().defaults.trans("basket_email_send_desc")#</td>
		</tr>
	</cfif>
	<tr>
		<td>#myFusebox.getApplicationData().defaults.trans("from")#</td>
		<td>#qryuseremail#</td>
	</tr>
	<tr>
		<td>#myFusebox.getApplicationData().defaults.trans("to")#</td>
		<td><input type="text" name="to" id="to" value="#attributes.email#" style="width:95%"></td>
	</tr>
	<tr>
		<td>Cc</td>
		<td><input type="text" name="cc" style="width:95%"></td>
	</tr>
	<tr>
		<td>Bcc</td>
		<td><input type="text" name="bcc" style="width:95%"></td>
	</tr>
	<tr>
		<td>#myFusebox.getApplicationData().defaults.trans("email_subject")#</td>
		<td><input type="text" name="subject" id="subject" style="width:95%"></td>
	</tr>
	<cfif attributes.frombasket EQ "F">
		<tr>
			<td colspan="2"> <hr> </td>
		</tr>
		<!--- Send as attachment --->
		<cfif qry_asset.detail.link_kind NEQ "url">
			<tr>
				<td valign="top">#myFusebox.getApplicationData().defaults.trans("attachment")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" class="gridno">
						<tr>
							<td></td>
							<td>
								<input type="radio" name="sendaszip" id="sendaszip" value="T"> #myFusebox.getApplicationData().defaults.trans("yes")# 
								<input type="radio" name="sendaszip" id="sendaszip" value="F" checked="true"> #myFusebox.getApplicationData().defaults.trans("no")#
							</td>
						</tr>
						<tr>
							<td></td>
							<td>#myFusebox.getApplicationData().defaults.trans("send_as_zip")#</td>
						</tr>
						<tr>
							<td colspan="2">Filename for Attachment
							<br>
							<input type="text" size="50" name="zipname" id="zipname" value="#attributes.filename#">.zip</td>
						</tr>
					</table>
				</td>
			</tr>
		<cfelse>
			<input type="hidden" name="sendaszip" value="F">
		</cfif>
		<tr>
			<td></td>
			<td>#myFusebox.getApplicationData().defaults.trans("format")#</td>
		</tr>
		<!--- Get related videos --->
		<cfif attributes.thetype EQ "vid">
			<tr>
				<td></td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- The Original video --->
						<input type="hidden" name="artofimage" value="">
						<cfif qry_asset.detail.perm NEQ "R" OR (qry_share_options.asset_format EQ "org" AND qry_share_options.asset_dl)>
							<tr>
								<td width="1%"><input type="checkbox" name="artofimage" value="video" onclick="checkzip();"/></td>
								<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artofimage',1)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("original")# <cfif qry_asset.detail.link_kind NEQ "url">#ucase(qry_asset.detail.vid_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.vlength#")# MB) (#qry_asset.detail.vwidth#x#qry_asset.detail.vheight# pixel)</cfif></a></td>
							</tr>
						</cfif>
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<cfset theid = vid_id>
							<cfset theext = vid_extension>
							<cfset theilength = vlength>
							<cfset theorgwidth = vid_width>
							<cfset theorgheight = vid_height>
							<cfloop query="qry_share_options">
								<cfif asset_format EQ theid>
									<cfif qry_asset.detail.perm NEQ "R" OR asset_dl>
										<tr>
											<td><input type="checkbox" name="artofimage" value="#theid#" onclick="checkzip();"/></td>
											<td><a href="##" onclick="clickcbk('sendemailform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(theext)# #myFusebox.getApplicationData().defaults.converttomb("#theilength#")# MB (#theorgwidth#x#theorgheight# pixel)</a></td>
										</tr>
										<cfset thecounter = thecounter + 1>
									</cfif>
								</cfif>
							</cfloop>
						</cfloop>
					</table>
				</td>
			</tr>
		<!--- Get related images --->
		<cfelseif attributes.thetype EQ "img">
			<tr>
				<td></td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- Thumbnail --->
						<tr>
							<td width="1%"><input type="checkbox" name="artofimage" value="thumb" onclick="checkzip();"/></td>
							<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artofimage',0)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(qry_asset.detail.img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.theprevsize#")# MB) (#qry_asset.detail.thumbwidth#x#qry_asset.detail.thumbheight# pixel)</a></td>
						</tr>
						<!--- Original --->
						<cfif qry_asset.detail.perm NEQ "R" OR (qry_share_options.asset_format EQ "org" AND qry_share_options.asset_dl)>
							<tr>
								<td><input type="checkbox" name="artofimage" value="original" onclick="checkzip();"/></td>
								<td><a href="##" onclick="clickcbk('sendemailform','artofimage',1)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("original")# #ucase(qry_asset.detail.img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.ilength#")# MB) (#qry_asset.detail.orgwidth#x#qry_asset.detail.orgheight# pixel)</a></td>
							</tr>
						</cfif>
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<cfset theid = img_id>
							<cfset theext = img_extension>
							<cfset theilength = ilength>
							<cfset theorgwidth = orgwidth>
							<cfset theorgheight = orgheight>
							<cfloop query="qry_share_options">
								<cfif asset_format EQ theid>
									<cfif qry_asset.detail.perm NEQ "R" OR asset_dl>
										<tr>
											<td><input type="checkbox" name="artofimage" value="#theid#" onclick="checkzip();"/></td>
											<td><a href="##" onclick="clickcbk('sendemailform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(theext)# #myFusebox.getApplicationData().defaults.converttomb("#theilength#")# MB (#theorgwidth#x#theorgheight# pixel)</a></td>
										</tr>
										<cfset thecounter = thecounter + 1>
									</cfif>
								</cfif>
							</cfloop>
						</cfloop>
					</table>
				</td>
			</tr>
		<!--- Get related audios --->
		<cfelseif attributes.thetype EQ "aud">
			<tr>
				<td></td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- The Original --->
						<input type="hidden" name="artofimage" value="">
						<cfif qry_asset.detail.perm NEQ "R" OR (qry_share_options.asset_format EQ "org" AND qry_share_options.asset_dl)>
							<tr>
								<td width="1%"><input type="checkbox" name="artofimage" value="audio" onclick="checkzip();"/></td>
								<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artofimage',1)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("original")# #ucase(qry_asset.detail.aud_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.aud_size#")# MB)</a></td>
							</tr>
						</cfif>
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<cfset theid = aud_id>
							<cfset theext = aud_extension>
							<cfset theilength = aud_size>
							<cfloop query="qry_share_options">
								<cfif asset_format EQ theid>
									<cfif qry_asset.detail.perm NEQ "R" OR asset_dl>
										<tr>
											<td><input type="checkbox" name="artofimage" value="#theid#" onclick="checkzip();"/></td>
											<td><a href="##" onclick="clickcbk('sendemailform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(theext)# #myFusebox.getApplicationData().defaults.converttomb("#theilength#")# MB</a></td>
										</tr>
										<cfset thecounter = thecounter + 1>
									</cfif>
								</cfif>
							</cfloop>
						</cfloop>
					</table>
				</td>
			</tr>
		<!--- Get doc --->
		<cfelseif attributes.thetype EQ "doc">
			<tr>
				<td></td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- The Original --->
						<input type="hidden" name="artoffile" value="">
						<cfif qry_asset.detail.perm NEQ "R" OR (qry_share_options.asset_format EQ "org" AND qry_share_options.asset_dl)>
							<tr>
								<td width="1%"><input type="checkbox" name="artoffile" value="file" onclick="checkzip();"/></td>
								<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artoffile',1)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("original")# #ucase(qry_asset.detail.file_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.file_size#")# MB)</a></td>
							</tr>
						</cfif>
					</table>
				</td>
			</tr>
		</cfif>
		<tr>
			<td colspan="2"> <hr> </td>
		</tr>
	</cfif>
	<!--- Message Box --->
	<tr>
		<td valign="top" colspan="2">#myFusebox.getApplicationData().defaults.trans("message")#</td>
	</tr>
	<tr>
		<td colspan="2"><textarea name="message">
			<p>EDIT THIS MESSAGE BEFORE SENDING!</p>

			<cfif attributes.frombasket NEQ "T">
				URLs:
				<!--- List URLs --->
				<cfif qry_asset.detail.link_kind NEQ "url">
					<!--- Images --->
					<cfif attributes.thetype EQ "img">
						<!--- Preview --->
						#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(qry_asset.detail.img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.theprevsize#")# MB) (#qry_asset.detail.thumbwidth#x#qry_asset.detail.thumbheight# pixel)<br/>
						#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.serve_file&type=img&file_id=#attributes.file_id#&v=p <br/><br/>
						<!--- Original --->
						<cfif qry_asset.detail.link_kind NEQ "lan">#myFusebox.getApplicationData().defaults.trans("original")##ucase(qry_asset.detail.img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.ilength#")# MB) (#qry_asset.detail.orgwidth#x#qry_asset.detail.orgheight# pixel)<br/>
						#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.serve_file&type=img&file_id=#attributes.file_id#&v=o <br/><br/></cfif>
						<!--- Related --->
						<cfloop query="qry_related">
							#ucase(img_extension)# #myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB (#orgwidth#x#orgheight# pixel)<br/>
							#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.serve_file&type=img&file_id=#img_id#&v=o <br/><br/>
						</cfloop>
					<!--- Videos --->
					<cfelseif attributes.thetype EQ "vid">
						<!--- Original --->
						<cfif qry_asset.detail.link_kind NEQ "lan">#myFusebox.getApplicationData().defaults.trans("original")##ucase(qry_asset.detail.vid_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.vlength#")# MB) (#qry_asset.detail.vwidth#x#qry_asset.detail.vheight# pixel)<br/>
						#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.serve_file&type=vid&file_id=#attributes.file_id#&v=o <br/><br/></cfif>
						<!--- Related --->
						<cfloop query="qry_related">
							#ucase(vid_extension)# #myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB (#vid_width#x#vid_height# pixel)<br/>
							#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.serve_file&type=vid&file_id=#vid_id#&v=o <br/><br/>
						</cfloop>
					<!--- Audios --->
					<cfelseif attributes.thetype EQ "aud">
						<!--- Original --->
						Original #ucase(qry_asset.detail.aud_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.aud_size#")# MB)<br/>
						#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.serve_file&type=aud&file_id=#attributes.file_id# <br/><br/>
						<!--- Related --->
						<cfloop query="qry_related">
							#ucase(aud_extension)# #myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB<br/>
							#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.serve_file&type=aud&file_id=#aud_id# <br/><br/>
						</cfloop>
					<!--- Docs --->
					<cfelse>
						#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.serve_file&type=doc&file_id=#attributes.file_id# <br/><br/>
					</cfif>
				<cfelse>
					#qry_asset.detail.link_path_url#<br/><br/>
				</cfif>
			</cfif>
		</textarea></td>
	</tr>
	<tr>
		<td colspan="2"><div id="successemail" style="width:70%;float:left;padding:10px;color:green;font-weight:bold;display:none;"></div><div style="float:right;padding:10px;"><input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("send_email")#" class="button"></div></td>
	</tr>
</table>
</form>
<script type="text/javascript">
	 function checkzip()
	 {
		var ischecked = false;
	 	$('##sendemailform input[type=checkbox]').each(function () 
	 	{
			if (this.checked) 
				{ischecked  = true;}
		});
	           if (!ischecked || $("##zipname").val().length == 0)
	          		{
	          			$("input[name=sendaszip][value=F]").prop('checked', true);
	          		}
	 }
	$("##sendemailform").validate({
		submitHandler: function(form) 
		{
		checkzip();
		CKEDITOR.instances["message"].updateElement();
		// Show status
		$("##successemail").css("display","");
   		$("##successemail").html('#JSStringFormat(myFusebox.getApplicationData().defaults.trans("message_sent"))#');
		// Get values
		var url = formaction("sendemailform");
		var items = formserialize("sendemailform");
		// Submit Form
		$.ajax(
			{
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
		   		$("##successemail").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
		   	}
		});
		return false;
		},
		rules: 
		{
			to: {required:true, email:true},
			cc: {email:true},
			bcc: {email:true},
			subject: {required:true},
		}
	});
</script>
</cfoutput>