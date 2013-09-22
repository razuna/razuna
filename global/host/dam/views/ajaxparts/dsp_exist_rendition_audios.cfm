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
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#" onsubmit="filesubmit();return false;">
	<input type="hidden" name="#theaction#" value="#xfa.save#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="folder_id" value="#qry_detail.detail.folder_id_r#">
	<input type="hidden" name="file_id" id="file_id" value="#attributes.file_id#">
	<input type="hidden" name="aud_group_id" id="aud_group_id" value="#attributes.aud_group_id#">
	<input type="hidden" name="theorgname" id="theorgname" value="#qry_detail.detail.aud_name#">
	<input type="hidden" name="theorgext" id="theorgext" value="#qry_detail.detail.aud_extension#">
	<input type="hidden" name="thepath" id="thepath" value="#thisPath#">
	<input type="hidden" name="theos" value="#server.os.name#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.aud_name_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="convert_width_3gp" value="">
	<input type="hidden" name="convert_height_3gp" value="">
	<input type="hidden" name="link_kind" id="link_kind" value="#qry_detail.detail.link_kind#">
	<div class="collapsable"><div class="headers">Create new renditions</div></div>
			<br />
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr class="list">
					<td width="1%" nowrap="true" align="center"><input type="checkbox" name="convert_to" value="mp3"></td>
					<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',0)" style="text-decoration:none;">MP3</a></td>
					<td width="450" nowrap="true"><select name="convert_bitrate_mp3" id="convert_bitrate_mp3">
					<option value="32">32</option>
					<option value="48">48</option>
					<option value="64">64</option>
					<option value="96">96</option>
					<option value="128">128</option>
					<option value="160">160</option>
					<option value="192" selected="true">192</option>
					<option value="256">256</option>
					<option value="320">320</option>
					</select></td>
					<td rowspan="5" valign="top" width="500">
						<strong>#myFusebox.getApplicationData().defaults.trans("audio_original")#</strong>
						<br />
						#myFusebox.getApplicationData().defaults.trans("file_name")#: #qry_detail.detail.aud_name#
						<br />
						#myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.aud_extension)#
						<br />
						#myFusebox.getApplicationData().defaults.trans("data_size")#: #qry_detail.thesize# MB
					</td>
				</tr>
				<tr class="list">
					<td align="center"><input type="checkbox" name="convert_to" value="ogg"></td>
					<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',2)" style="text-decoration:none;">OGG</a></td>
					<td><select name="convert_bitrate_ogg" id="convert_bitrate_ogg">
					<option value="10">82</option>
					<option value="20">102</option>
					<option value="30">115</option>
					<option value="40">137</option>
					<option value="50">147</option>
					<option value="60" selected="true">176</option>
					<option value="70">192</option>
					<option value="80">224</option>
					<option value="90">290</option>
					<option value="100">434</option>
					</select></td>
				</tr>
				<tr class="list">
					<td align="center"><input type="checkbox" name="convert_to" value="wav"></td>
					<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',1)" style="text-decoration:none;">WAV</a></td>
					<td></td>
				</tr>
				<tr class="list">
					<td align="center"><input type="checkbox" name="convert_to" value="flac"></td>
					<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',3)">FLAC</a></td>
					<td></td>
				</tr>
				<tr>
					<td colspan="4"><input type="button" name="convertbutton" value="#myFusebox.getApplicationData().defaults.trans("convert_button")#" class="button" onclick="convertexistaudrenditions('form#attributes.file_id#');"> <div id="statusconvertreditions" style="padding:10px;color:green;background-color:##FFFFE0;display:none;"></div><div id="statusrenditionconvertdummy"></div></td>
				</tr>
			</table>
		</form>	
</cfoutput>