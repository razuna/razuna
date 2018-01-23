<cfset incval = structnew()>
<cfset incval.theform = "form_create_renditions">
<cfset myFusebox = attributes.fusebox>
<cfoutput>
	<tr>
		<td width="1%" nowrap="nowrap">
			<input type="checkbox" name="convert_#attributes.type#" value="#attributes.format#">
		</td>
		<td width="10%" nowrap="nowrap">#ucase(attributes.format)#</td>
		<td width="10%" nowrap="nowrap">
			<input type="text" size="4" name="convert_width_#attributes.format#" id="convert_width_#attributes.format#" maxlength="4">
			<span> x </span>
			<input type="text" size="4" name="convert_height_#attributes.format#" id="convert_height_#attributes.format#" maxlength="4">
		</td>
		<!--- Videos --->
		<cfif attributes.type EQ 'vid'>
			<td nowrap="true" width="100%">
				<cfset incval.theformat = "ogv">
				<cfinclude template="../views/ajaxparts/inc_video_presets.cfm" />
			</td>
		<cfelseif attributes.type EQ 'aud' AND attributes.format EQ 'mp3'>
			<td width="100%" nowrap="true">
				<select name="convert_bitrate_mp3" id="convert_bitrate_mp3">
					<option value="32">32</option>
					<option value="48">48</option>
					<option value="64">64</option>
					<option value="96">96</option>
					<option value="128">128</option>
					<option value="160">160</option>
					<option value="192" selected="true">192</option>
					<option value="256">256</option>
					<option value="320">320</option>
				</select>
				<span>bitrate</span>
			</td>
		<cfelseif attributes.type EQ 'aud' AND attributes.format EQ 'ogg'>
			<td width="100%" nowrap="nowrap">
				<select name="convert_bitrate_ogg" id="convert_bitrate_ogg">
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
				</select>
				<span>bitrate</span>
			</td>
		</cfif>
	</tr>
</cfoutput>