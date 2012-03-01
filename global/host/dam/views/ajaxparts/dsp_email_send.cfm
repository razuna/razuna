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
<form name="sendemailform" id="sendemailform" action="#self#" method="post">
<input type="hidden" name="#theaction#" value="#xfa.submit#">
<input type="hidden" name="file_id" value="#attributes.file_id#">
<input type="hidden" name="thetype" value="#attributes.thetype#">
<input type="hidden" name="thepath" value="#thisPath#">
<input type="hidden" name="artofimage" id="sendemailform_artofimage" value="">
<input type="hidden" name="artofvideo" id="sendemailform_artofvideo" value="">
<input type="hidden" name="artofaudio" id="sendemailform_artofaudio" value="">
<input type="hidden" name="artoffile" id="sendemailform_artoffile" value="">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
	<cfif attributes.frombasket EQ "T">
		<tr>
			<td colspan="2">#defaultsObj.trans("basket_email_send_desc")#</td>
		</tr>
	</cfif>
	<tr>
		<td>#defaultsObj.trans("from")#</td>
		<td>#qryuseremail#</td>
	</tr>
	<tr>
		<td>#defaultsObj.trans("to")#</td>
		<td><input type="text" name="to" id="to" size="60" value="#attributes.email#"></td>
	</tr>
	<tr>
		<td>Cc</td>
		<td><input type="text" name="cc" size="60"></td>
	</tr>
	<tr>
		<td>Bcc</td>
		<td><input type="text" name="bcc" size="60"></td>
	</tr>
	<tr>
		<td>#defaultsObj.trans("email_subject")#</td>
		<td><input type="text" name="subject" id="subject" size="60"></td>
	</tr>
	<cfif attributes.frombasket EQ "F">
		<!--- Get related videos --->
		<cfif attributes.thetype EQ "vid">
			<tr>
				<td width="1%" nowrap="nowrap" valign="top">#defaultsObj.trans("format")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- The Original video --->
						<input type="hidden" name="artofimage" value="">
						<tr>
							<td width="1%"><input type="checkbox" name="artofimage" value="video"/></td>
							<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artofimage',1)" style="text-decoration:none;">Original <cfif qry_asset.detail.link_kind NEQ "url">#ucase(qry_asset.detail.vid_extension)# (#defaultsObj.converttomb("#qry_asset.detail.vlength#")# MB) (#qry_asset.detail.vwidth#x#qry_asset.detail.vheight# pixel)</cfif></a></td>
						</tr>
						<!--- The preview video
						<tr>
							<td><input type="checkbox" name="artofimage" value="video_preview"/></td>
							<td><a href="##" onclick="clickcbk('sendemailform','artofimage',1)" style="text-decoration:none;">#defaultsObj.trans("preview")# #ucase(qry_asset.vid_extension)# (#defaultsObj.converttomb("#qry_asset.vprevlength#")# MB) (#qry_asset.vid_preview_width#x#qry_asset.vid_preview_heigth# pixel)</a></td>
						</tr> --->
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<tr>
								<td><input type="checkbox" name="artofimage" value="#vid_id#"/></td>
								<td><a href="##" onclick="clickcbk('sendemailform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(vid_extension)# #defaultsObj.converttomb("#vlength#")# MB (#vid_width#x#vid_height# pixel)</a></td>
							</tr>
							<cfset thecounter = thecounter + 1>
						</cfloop>
					</table>
				</td>
			</tr>
		<!--- Get related images --->
		<cfelseif attributes.thetype EQ "img">
			<tr>
				<td width="1%" nowrap="nowrap" valign="top">#defaultsObj.trans("format")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- Thumbnail --->
						<tr>
							<td width="1%"><input type="checkbox" name="artofimage" value="thumb"/></td>
							<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artofimage',0)" style="text-decoration:none;">#defaultsObj.trans("preview")# #ucase(qry_asset.detail.img_extension)# (#defaultsObj.converttomb("#qry_asset.theprevsize#")# MB) (#qry_asset.detail.thumbwidth#x#qry_asset.detail.thumbheight# pixel)</a></td>
						</tr>
						<!--- Original --->
						<tr>
							<td><input type="checkbox" name="artofimage" value="original"/></td>
							<td><a href="##" onclick="clickcbk('sendemailform','artofimage',1)" style="text-decoration:none;">Original #ucase(qry_asset.detail.img_extension)# (#defaultsObj.converttomb("#qry_asset.detail.ilength#")# MB) (#qry_asset.detail.orgwidth#x#qry_asset.detail.orgheight# pixel)</a></td>
						</tr>
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<tr>
								<td><input type="checkbox" name="artofimage" value="#img_id#"/></td>
								<td><a href="##" onclick="clickcbk('sendemailform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(img_extension)# #defaultsObj.converttomb("#ilength#")# MB (#orgwidth#x#orgheight# pixel)</a></td>
							</tr>
							<cfset thecounter = thecounter + 1>
						</cfloop>
					</table>
				</td>
			</tr>
		<!--- Get related audios --->
		<cfelseif attributes.thetype EQ "aud">
			<tr>
				<td width="1%" nowrap="nowrap" valign="top">#defaultsObj.trans("format")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- The Original --->
						<input type="hidden" name="artofimage" value="">
						<tr>
							<td width="1%"><input type="checkbox" name="artofimage" value="audio"/></td>
							<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artofimage',1)" style="text-decoration:none;">Original #ucase(qry_asset.detail.aud_extension)# (#defaultsObj.converttomb("#qry_asset.detail.aud_size#")# MB)</a></td>
						</tr>
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<tr>
								<td><input type="checkbox" name="artofimage" value="#aud_id#"/></td>
								<td><a href="##" onclick="clickcbk('sendemailform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(aud_extension)# #defaultsObj.converttomb("#aud_size#")# MB</a></td>
							</tr>
							<cfset thecounter = thecounter + 1>
						</cfloop>
					</table>
				</td>
			</tr>
		<!--- Get doc --->
		<cfelseif attributes.thetype EQ "doc">
			<tr>
				<td width="1%" nowrap="nowrap" valign="top">#defaultsObj.trans("format")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- The Original --->
						<input type="hidden" name="artoffile" value="">
						<tr>
							<td width="1%"><input type="checkbox" name="artoffile" value="file"/></td>
							<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artoffile',1)" style="text-decoration:none;">Original #ucase(qry_asset.detail.file_extension)# (#defaultsObj.converttomb("#qry_asset.detail.file_size#")# MB)</a></td>
						</tr>
					</table>
				</td>
			</tr>
		</cfif>
		<cfif qry_asset.detail.link_kind NEQ "url">
			<tr>
				<td valign="top">#defaultsObj.trans("attachment")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" class="gridno">
						<tr>
							<td></td>
							<td>#defaultsObj.trans("send_as_zip")#</td>
						</tr>
						<tr>
							<td></td>
							<td><input type="radio" name="sendaszip" value="F" checked="true"> #defaultsObj.trans("no")# <input type="radio" name="sendaszip" value="T"> #defaultsObj.trans("yes")#</td>
						</tr>
						<tr>
							<td colspan="2"><input type="text" size="50" name="zipname" value="#attributes.filename#">.zip</td>
						</tr>
					</table>
				</td>
			</tr>
		<cfelse>
			<input type="hidden" name="sendaszip" value="F">
		</cfif>
	</cfif>
	<!--- Message Box --->
	<tr>
		<td valign="top">#defaultsObj.trans("message")#</td>
		<td><textarea name="message" rows="10" cols="60">
			<cfif attributes.frombasket NEQ "T">
				URLs:
				<!--- List URLs --->
				<cfif qry_asset.detail.link_kind NEQ "url">
					<!--- Images --->
					<cfif attributes.thetype EQ "img">
						<!--- Preview --->
						#defaultsObj.trans("preview")# #ucase(qry_asset.detail.img_extension)# (#defaultsObj.converttomb("#qry_asset.theprevsize#")# MB) (#qry_asset.detail.thumbwidth#x#qry_asset.detail.thumbheight# pixel)
						http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=p
						<!--- Original --->
						<cfif qry_asset.detail.link_kind NEQ "lan">Original #ucase(qry_asset.detail.img_extension)# (#defaultsObj.converttomb("#qry_asset.detail.ilength#")# MB) (#qry_asset.detail.orgwidth#x#qry_asset.detail.orgheight# pixel)
						http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=o</cfif>
						<!--- Related --->
						<cfloop query="qry_related">
							#ucase(img_extension)# #defaultsObj.converttomb("#ilength#")# MB (#orgwidth#x#orgheight# pixel)
							http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#img_id#&v=o
						</cfloop>
					<!--- Videos --->
					<cfelseif attributes.thetype EQ "vid">
						<!--- Original --->
						<cfif qry_asset.detail.link_kind NEQ "lan">Original #ucase(qry_asset.detail.vid_extension)# (#defaultsObj.converttomb("#qry_asset.detail.vlength#")# MB) (#qry_asset.detail.vwidth#x#qry_asset.detail.vheight# pixel)
						http://#cgi.http_host##cgi.script_name#?#theaction#=c.sv&f=#attributes.file_id#&v=o</cfif>
						<!--- Related --->
						<cfloop query="qry_related">
							#ucase(vid_extension)# #defaultsObj.converttomb("#vlength#")# MB (#vid_width#x#vid_height# pixel)
							http://#cgi.http_host##cgi.script_name#?#theaction#=c.sv&f=#vid_id#&v=o
						</cfloop>
					<!--- Audios --->
					<cfelseif attributes.thetype EQ "aud">
						<!--- Original --->
						Original #ucase(qry_asset.detail.aud_extension)# (#defaultsObj.converttomb("#qry_asset.detail.aud_size#")# MB)
						http://#cgi.http_host##cgi.script_name#?#theaction#=c.sa&f=#attributes.file_id#
						<!--- Related --->
						<cfloop query="qry_related">
							#ucase(aud_extension)# #defaultsObj.converttomb("#aud_size#")# MB
							http://#cgi.http_host##cgi.script_name#?#theaction#=c.sa&f=#aud_id#
						</cfloop>
					<!--- Docs --->
					<cfelse>
						http://#cgi.http_host##cgi.script_name#?#theaction#=c.sf&f=#attributes.file_id#
					</cfif>
				<cfelse>
					#qry_asset.detail.link_path_url#
				</cfif>
			</cfif>
		</textarea></td>
	</tr>
	<tr>
		<td colspan="2"><div id="successemail" style="width:70%;float:left;padding:10px;color:green;font-weight:bold;display:none;"></div><div style="float:right;padding:10px;"><input type="submit" name="submitbutton" value="#defaultsObj.trans("send_email")#" class="button"></div></td>
	</tr>
</table>
</form>
<script type="text/javascript">

$("##sendemailform").validate({
	// When the form is being submited
	submitHandler: function(form) {
		// Get values
		var url = formaction("sendemailform");
		var items = formserialize("sendemailform");
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
		   		$("##successemail").css("display","");
		   		$("##successemail").html('#JSStringFormat(defaultsObj.trans("message_sent"))#');
		   		$("##successemail").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
		   	}
		});
		return false;
	},
	rules: {
		to: "required",
		subject: "required"
	 }
})

/*
$("##sendemailform").submit(function(e){
	$("##successemail").css("display","");
	loadinggif('successemail');
	// Submit Form
	// Get values
	var url = formaction("sendemailform");
	var items = formserialize("sendemailform");
	// Submit Form
	$.ajax({
		type: "POST",
		url: url,
	   	data: items,
	   	success: function(){
	   		$("##successemail").html('#JSStringFormat(defaultsObj.trans("message_sent"))#');
	   		$("##successemail").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	   	}
	});
	return false;
})
*/
</script>
</cfoutput>