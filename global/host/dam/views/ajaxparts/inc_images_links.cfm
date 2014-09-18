<cfoutput>
	<!--- Format sizes --->
	<cfif isnumeric(qry_detail.theprevsize)><cfset qry_detail.theprevsize = numberformat(qry_detail.theprevsize,'_.__')></cfif>
	<cfif isnumeric(qry_detail.thesize)><cfset qry_detail.thesize = numberformat(qry_detail.thesize,'_.__')></cfif>
	<div class="collapsable"><div class="headers">&gt; Existing Renditions - <a href="##" onclick="loadren();return false;">Refresh</a></div></div>
	<br />
	<cfquery name="thumb_share_setting" dbtype="query">
		SELECT * FROM qry_share_options WHERE asset_format= 'thumb'
	</cfquery>
	<cfif qry_detail.detail.link_kind NEQ "url">
		<table border="0" cellpadding="0" cellspacing="0" width="100%">
			<cfif attributes.folderaccess NEQ "R" OR (thumb_share_setting.recordcount EQ 1 AND thumb_share_setting.asset_dl EQ 1)>
				<tr>
					<td width="65" align="center">
						<cfif qry_detail.detail.shared EQ "F">
							<a href="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=p" target="_blank">
						<cfelse>
							<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#" target="_blank">
						</cfif>
							<!--- Preview --->
							<cfif application.razuna.storage EQ "amazon">
								<img src="#qry_detail.detail.cloud_url#" border="0" height="50">
							<cfelse>
								<img src="#thestorage##qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#?#qry_detail.detail.hashtag#&#uniqueid#" border="0" height="50">
							</cfif>
						</a>
					</td>
					<td width="10"></td>
					<td>
						<strong>#myFusebox.getApplicationData().defaults.trans("preview")#</strong> (#ucase(qry_detail.detail.thumb_extension)#, #qry_detail.theprevsize# MB, #qry_detail.detail.thumbwidth#x#qry_detail.detail.thumbheight# pixel)
						<br /> 
						<a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=p" style="color:white;text-decoration:none;"><button type="button" class="awesome small green">#myFusebox.getApplicationData().defaults.trans("download")#</button></a>
						<a href="##" onclick="toggleslide('divp#attributes.file_id#','inputp#attributes.file_id#');return false;" style="padding-left:20px;">Direct Link</a>
						<div id="divp#attributes.file_id#" style="display:none;">
							<input type="text" id="inputp#attributes.file_id#" style="width:100%;" value="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=p" />
							<br />
							<cfif application.razuna.storage EQ "local">
								<input type="text" id="inputp#attributes.file_id#d" style="width:100%;" value="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#" />
							<cfelse>
								<input type="text" id="inputp#attributes.file_id#d" style="width:100%;" value="#qry_detail.detail.cloud_url_org#" />
							</cfif>
							<!--- Plugin --->
							<cfset args = structNew()>
							<cfset args.detail = qry_detail.detail>
							<cfset args.thefiletype = "img">
							<cfset args.thepreview = true>
							<cfinvoke component="global.cfc.plugins" method="getactions" theaction="show_in_direct_link" args="#args#" returnvariable="pl">
							<!--- Show plugin --->
							<cfif structKeyExists(pl,"pview")>
								<cfloop list="#pl.pview#" delimiters="," index="i">
									#evaluate(i)#
								</cfloop>
							</cfif>
						</div>
					</td>
				</tr>
			</cfif>
			<cfquery name="org_share_setting" dbtype="query">
				SELECT * FROM qry_share_options WHERE asset_format= 'org'
			</cfquery>
			<!--- Original --->
			<cfif attributes.folderaccess NEQ "R" OR (org_share_setting.recordcount EQ 1 AND org_share_setting.asset_dl EQ 1)>
				<tr>
					<td width="65" align="center">
							<cfif qry_detail.detail.shared EQ "F">
								<a href="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=o" target="_blank">
							<cfelse>
								<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.img_filename_org#">
							</cfif>
							<!--- Preview --->
							<cfif application.razuna.storage EQ "amazon">
								<img src="#qry_detail.detail.cloud_url#" border="0" height="50">
							<cfelse>
								<img src="#thestorage##qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#?#qry_detail.detail.hashtag#&#uniqueid#" border="0" height="50">
							</cfif>
						</a>
					</td>
					<td width="10"></td>
					<td>
						<cfif qry_detail.detail.link_kind NEQ "lan">
							<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> (#ucase(qry_detail.detail.img_extension)#, #qry_detail.thesize# MB, #qry_detail.detail.orgwidth#x#qry_detail.detail.orgheight# pixel)
						</cfif>
						<cfif qry_detail.detail.link_kind EQ "lan">
							<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> (#ucase(qry_detail.detail.img_extension)#, #qry_detail.thesize# MB, #qry_detail.detail.orgwidth#x#qry_detail.detail.orgheight# pixel)
							<br />
						</cfif>
						<br>
						<a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=o" style="color:white;text-decoration:none;"><button type="button" class="awesome small green">#myFusebox.getApplicationData().defaults.trans("download")#</button></a>
						<cfif qry_detail.detail.link_kind NEQ "lan">
							<a href="##" onclick="toggleslide('divo#attributes.file_id#','inputo#attributes.file_id#');return false;" style="padding-left:20px;">Direct Link</a>
						</cfif>
						<div id="divo#attributes.file_id#" style="display:none;">
							<input type="text" id="inputo#attributes.file_id#" style="width:100%;" value="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=o" />
							<cfif application.razuna.storage EQ "local">
								<input type="text" id="inputo#attributes.file_id#d" style="width:100%;" value="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.img_filename_org#" />
							<cfelse>
								<input type="text" id="inputo#attributes.file_id#d" style="width:100%;" value="#qry_detail.detail.cloud_url_org#" />
							</cfif>
							<!--- Plugin --->
							<cfset args.thepreview = false>
							<cfinvoke component="global.cfc.plugins" method="getactions" theaction="show_in_direct_link" args="#args#" returnvariable="pl">
							<!--- Show plugin --->
							<cfif structKeyExists(pl,"pview")>
								<cfloop list="#pl.pview#" delimiters="," index="i">
									#evaluate(i)#
								</cfloop>
							</cfif>
						</div>
					</td>
				</tr>
			</cfif>
		</table>
	<cfelseif attributes.folderaccess NEQ "R">
		<a href="#qry_detail.detail.link_path_url#" target="_blank">#myFusebox.getApplicationData().defaults.trans("link_to_original")#</a>
	</cfif>
	<!--- Show related images (if any) --->
	<div id="relatedimages"></div>
	<!--- Show additional version --->
	<div id="additionalversions"></div>
</cfoutput>