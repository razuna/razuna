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
<form name="sendftpform" id="sendftpform" onsubmit="loadftpsite();">
<input type="hidden" name="file_id" value="#attributes.file_id#">
<input type="hidden" name="thetype" value="#attributes.thetype#">
<input type="hidden" name="thepath" value="#thisPath#">
<input type="hidden" name="frombasket" value="#attributes.frombasket#">
<cfif attributes.frombasket EQ "T">
<input type="hidden" name="artofimage" id="sendftpform_artofimage" value="">
<input type="hidden" name="artofvideo" id="sendftpform_artofvideo" value="">
<input type="hidden" name="artofaudio" id="sendftpform_artofaudio" value="">
<input type="hidden" name="artoffile" id="sendftpform_artoffile" value="">
</cfif>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
	<cfif attributes.frombasket EQ "T">
		<tr>
			<td colspan="2">#myFusebox.getApplicationData().defaults.trans("basket_email_send_desc")#</td>
		</tr>
	</cfif>
	<tr>
		<td>#myFusebox.getApplicationData().defaults.trans("ftp_server")#</td>
		<td><input type="text" name="ftp_server" id="ftp_server" size="60" value="#session.ftp_server#"></td>
	</tr>
	<tr>
		<td>#myFusebox.getApplicationData().defaults.trans("username")#</td>
		<td><input type="text" name="ftp_user" id="ftp_user" size="60" value="#session.ftp_user#"></td>
	</tr>
	<tr>
		<td>#myFusebox.getApplicationData().defaults.trans("password")#</td>
		<td><input type="password" name="ftp_pass" id="ftp_pass" size="60"></td>
	</tr>
	<tr>
		<td nowrap="true" style="padding-bottom:15px;">#myFusebox.getApplicationData().defaults.trans("ftp_passive")#</td>
		<td><input name="ftp_passive" type="radio" value="no" checked="true">#myFusebox.getApplicationData().defaults.trans("no")# <input name="ftp_passive" type="radio" value="yes">#myFusebox.getApplicationData().defaults.trans("yes")#</td>
	</tr>
	<cfif attributes.frombasket EQ "F">
		<!--- Videos --->
		<cfif attributes.thetype EQ "vid">
			<tr>
				<td width="1%" nowrap="nowrap" valign="top">#myFusebox.getApplicationData().defaults.trans("format")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- The Original video --->
						<input type="hidden" name="artofimage" id="artofimage" value="">
						<tr>
							<td width="1%"><input type="checkbox" name="artofimage" id="artofimage" value="video" checked="true" /></td>
							<td width="100%"><a href="##" onclick="clickcbk('sendftpform','artofimage',1)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("original")# #ucase(qry_asset.vid_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.vlength#")# MB) (#qry_asset.vwidth#x#qry_asset.vheight# pixel)</a></td>
						</tr>
						<!--- The preview video
						<tr>
							<td><input type="checkbox" name="artofimage" value="video_preview"/></td>
							<td><a href="##" onclick="clickcbk('sendftpform','artofimage',1)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(qry_asset.vid_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.vprevlength#")# MB) (#qry_asset.vid_preview_width#x#qry_asset.vid_preview_heigth# pixel)</a></td>
						</tr> --->
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<tr>
								<td><input type="checkbox" name="artofimage" id="artofimage" value="#vid_id#"/></td>
								<td><a href="##" onclick="clickcbk('sendftpform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(vid_extension)# #myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB (#vid_width#x#vid_height# pixel)</a></td>
							</tr>
							<cfset thecounter = thecounter + 1>
						</cfloop>
					</table>
				</td>
			</tr>
		<!--- Get related images --->
		<cfelseif attributes.thetype EQ "img">
			<tr>
				<td width="1%" nowrap="nowrap" valign="top">#myFusebox.getApplicationData().defaults.trans("format")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- Thumbnail --->
						<tr>
							<td width="1%"><input type="checkbox" name="artofimage" id="artofimage" value="thumb" checked="true" /></td>
							<td width="100%"><a href="##" onclick="clickcbk('sendftpform','artofimage',0)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(qry_asset.detail.img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.theprevsize#")# MB) (#qry_asset.detail.thumbwidth#x#qry_asset.detail.thumbheight# pixel)</a></td>
						</tr>
						<!--- Original --->
						<tr>
							<td><input type="checkbox" name="artofimage" id="artofimage" value="original"/></td>
							<td><a href="##" onclick="clickcbk('sendftpform','artofimage',1)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("original")# #ucase(qry_asset.detail.img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.ilength#")# MB) (#qry_asset.detail.orgwidth#x#qry_asset.detail.orgheight# pixel)</a></td>
						</tr>
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<tr>
								<td><input type="checkbox" name="artofimage" id="artofimage" value="#img_id#"/></td>
								<td><a href="##" onclick="clickcbk('sendftpform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(img_extension)# #myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB (#orgwidth#x#orgheight# pixel)</a></td>
							</tr>
							<cfset thecounter = thecounter + 1>
						</cfloop>
					</table>
				</td>
			</tr>
		<!--- Get related audios --->
		<cfelseif attributes.thetype EQ "aud">
			<tr>
				<td width="1%" nowrap="nowrap" valign="top">#myFusebox.getApplicationData().defaults.trans("format")#</td>
				<td>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridno">
						<!--- The Original --->
						<input type="hidden" name="artofimage" value="">
						<tr>
							<td width="1%"><input type="checkbox" name="artofimage" value="audio"/></td>
							<td width="100%"><a href="##" onclick="clickcbk('sendemailform','artofimage',1)" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("original")# #ucase(qry_asset.detail.aud_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#qry_asset.detail.aud_size#")# MB)</a></td>
						</tr>
						<!--- List the converted formats --->
						<cfset thecounter = 2>
						<cfloop query="qry_related">
							<tr>
								<td><input type="checkbox" name="artofimage" value="#aud_id#"/></td>
								<td><a href="##" onclick="clickcbk('sendemailform','artofimage',#thecounter#)" style="text-decoration:none;">#ucase(aud_extension)# #myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB</a></td>
							</tr>
							<cfset thecounter = thecounter + 1>
						</cfloop>
					</table>
				</td>
			</tr>
		</cfif>
		<!--- check zip file --->
		<cfif listLast(attributes.filename,'.') NEQ "zip">
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("create_zip")#</td>
			<td><input name="createzip" type="radio" value="no" checked="true">#myFusebox.getApplicationData().defaults.trans("no")# <input name="createzip" type="radio" value="yes">#myFusebox.getApplicationData().defaults.trans("yes")#</td>
		</tr>
		</cfif>
		<tr>
			<td valign="top">#myFusebox.getApplicationData().defaults.trans("attachment")#</td>
			<td>
				<table border="0" cellpadding="0" cellspacing="0" class="gridno">
					<tr>
						<td colspan="2"><input type="text" size="50" name="zipname" id="zipname" value="#rereplace(attributes.filename,"[\\/.+]","","all")#"></td>
					</tr>
						<input type="hidden" name="sendaszip" value="T">
				</table>
			</td>
		</tr>
	</cfif>
	<tr>
		<td colspan="2" align="right"><input type="button" name="submitbutton" id="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("button_show_ftp")#" class="button" onclick="loadftpsite();"></td>
	</tr>
</table>
</form>
<script type="text/javascript">
	// Focus
	$('##ftp_server').focus();
	// Function
	function loadftpsite(){
		// Submit Form
		if (($("##ftp_server").val() != "") && ($("##ftp_user").val() != "")){
			// Get passive selection
			for (var i = 0; i<document.sendftpform.elements.length; i++) {
	        if ((document.sendftpform.elements[i].name.indexOf('ftp_passive') > -1)) {
	            if (document.sendftpform.elements[i].checked) {
	                var passive = document.sendftpform.elements[i].value;
	            	}
	        	}
	    	}
			//Get createzip selection and check the file ext
			<cfif structkeyexists(attributes,"filename") AND listLast(attributes.filename,'.') NEQ "zip">
				for (var i = 0; i<document.sendftpform.elements.length; i++) {
		        if ((document.sendftpform.elements[i].name.indexOf('createzip') > -1)) {
		            if (document.sendftpform.elements[i].checked) {
		                var createzip = document.sendftpform.elements[i].value;
		            	}
		        	}
		    	}
			<cfelse>
			// Set defult value
				var createzip = "";
			</cfif>
	    	// Get the checked values (file id's)
			var artimg = '';
			var artvid = '';
			var artaud = '';
			var artdoc = '';
			<cfif attributes.frombasket NEQ "T">
				for (var i = 0; i<document.sendftpform.elements.length; i++) {
			       if ((document.sendftpform.elements[i].name.indexOf('artofimage') > -1)) {
			           if (document.sendftpform.elements[i].checked) {
			           	artimg += document.sendftpform.elements[i].value + ',';
			           	}
			      	}
			   	}
		   	</cfif>
		   	// Change Button
		   	document.getElementById('submitbutton').value='#myFusebox.getApplicationData().defaults.trans("please_wait")#...(sometime minutes)';
	    	// Load the FTP site
			<cfif attributes.frombasket NEQ "T">
				// Submit the values so we put them into sessions
				var url = '<cfoutput>#myself#</cfoutput>c.store_art_values';
				var items = '&artofimage=' + artimg + '&artofvideo=' + artvid + '&artofaudio=' + artaud + '&artoffile=' + artdoc;
				// Submit Form
				$.ajax({
					type: "POST",
					url: url,
				   	data: items
				});
				$('##thewindowcontent2').load('<cfoutput>#myself#</cfoutput>c.ftp_gologin', { file_id: document.sendftpform.file_id.value, ftp_server: document.sendftpform.ftp_server.value, ftp_user: document.sendftpform.ftp_user.value, ftp_pass: document.sendftpform.ftp_pass.value, ftp_passive: passive, thetype: document.sendftpform.thetype.value, thepath: document.sendftpform.thepath.value, zipname: document.sendftpform.zipname.value, sendaszip: document.sendftpform.sendaszip.value,createzip: createzip } );
			<cfelse>
				// Load the FTP window
				$('##thewindowcontent1').load('<cfoutput>#myself#</cfoutput>c.ftp_gologin', { sendaszip:"T", thetype:"", frombasket:"T", file_id: document.sendftpform.file_id.value, ftp_server: document.sendftpform.ftp_server.value, ftp_user: document.sendftpform.ftp_user.value, ftp_pass: document.sendftpform.ftp_pass.value, ftp_passive: passive, thepath: document.sendftpform.thepath.value,createzip: createzip });
			</cfif>
		}
		return false;
	}
</script>
</cfoutput>