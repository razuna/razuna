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
	<cfquery name="org_share_setting" dbtype="query">
		SELECT * FROM qry_share_options WHERE asset_format= 'org'
	</cfquery>
	<div class="collapsable"><div class="headers">&gt; Existing Renditions - <a href="##" onclick="loadrenaud();return false;">Refresh</a></div></div>
	<br />
	<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
		<cfif attributes.folderaccess NEQ "R" OR (org_share_setting.recordcount EQ 1 AND org_share_setting.asset_dl EQ 1)>
			<tr>
				<td width="100%" nowrap="true">
					<cfif qry_detail.detail.link_kind NEQ "url">
						<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> (#ucase(qry_detail.detail.aud_extension)#)
						<br /> 
						<a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud" target="_blank" style="color:white;text-decoration:none;"><button type="button" class="awesome small green">#myFusebox.getApplicationData().defaults.trans("download")#</button></a>
						<a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sa&f=#attributes.file_id#" target="_blank" style="padding-left:20px;">Play</a>
						 <cfif qry_detail.detail.link_kind NEQ "lan">
						 | <a href="##" onclick="toggleslide('divo#attributes.file_id#','inputo#attributes.file_id#');return false;">Direct Link</a>
						 | <a href="##" onclick="toggleslide('dive#attributes.file_id#','inpute#attributes.file_id#');return false;">Embed</a>
						</cfif>
						<!--- Direct link --->
						<div id="divo#attributes.file_id#" style="display:none;">
							<input type="text" id="inputo#attributes.file_id#" style="width:100%;" value="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.sa&f=#attributes.file_id#&v=o" />
							<br />
							<cfif application.razuna.storage EQ "local">
								<input type="text" id="inputo#attributes.file_id#d" style="width:100%;" value="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.aud_name_org#" />
							<cfelse>
								<input type="text" id="inputo#attributes.file_id#d" style="width:100%;" value="#qry_detail.detail.cloud_url_org#" />
							</cfif>
							<!--- Plugin --->
							<cfset args = structNew()>
							<cfset args.detail = qry_detail.detail>
							<cfset args.thefiletype = "aud">
							<cfinvoke component="global.cfc.plugins" method="getactions" theaction="show_in_direct_link" args="#args#" returnvariable="pl">
							<!--- Show plugin --->
							<cfif structKeyExists(pl,"pview")>
								<cfloop list="#pl.pview#" delimiters="," index="i">
									<br />
									#evaluate(i)#
								</cfloop>
							</cfif>
						</div>
						<!--- Embed Code --->
						<div id="dive#attributes.file_id#" style="display:none;">
							<textarea id="inpute#attributes.file_id#" style="width:500px;height:60px;" readonly="readonly"><iframe frameborder="0" src="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.sa&f=#attributes.file_id#&v=o" scrolling="auto" width="100%" height="150"></iframe></textarea>
						</div>
					<cfelse>
						<a href="#qry_detail.detail.link_path_url#" target="_blank">#myFusebox.getApplicationData().defaults.trans("link_to_original")#</a>
					</cfif>
				</td>
			</tr>
		<!--- Original file not available --->
		<cfelse>
			<tr>
				<td>
					The original file has not been made available
				</td>
			</tr>
		</cfif>
		<!--- Show related audios (if any) --->
		<tr>
			<td style="padding:0;margin:0;">
				<div id="relatedaudios"></div>
			</td>
		</tr>
		<!--- Show additional version --->
		<tr>
			<td colspan="2" style="padding:0;margin:0;">
				<div id="additionalversions"></div>
			</td>
		</tr>
	</table>
	<br />
	<cfif attributes.folderaccess NEQ "R">
		<div class="collapsable"><div class="headers">&gt; Create new renditions</div></div>
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
				<td colspan="4"><input type="button" name="convertbutton" value="#myFusebox.getApplicationData().defaults.trans("convert_button")#" class="button" onclick="convertaudios('form#attributes.file_id#');"> <div id="statusconvert" style="padding:10px;color:green;background-color:##FFFFE0;display:none;"></div><div id="statusconvertdummy"></div></td>
			</tr>
		</table>
		<!--- Additional Renditions --->
		<cfif cs.tab_additional_renditions>
			<div class="collapsable">
				<a href="##" onclick="$('##moreversions').slideToggle('slow');return false;"><div class="headers">&gt; #myFusebox.getApplicationData().defaults.trans("adiver_header")#</div></a>
				<div id="moreversions" style="display:none;padding-top:10px;"></div>
			</div>
		</cfif>
	</cfif>
</cfoutput>
