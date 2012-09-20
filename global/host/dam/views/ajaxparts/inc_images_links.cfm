<cfoutput>
	<div class="collapsable"><div class="headers">&gt; Existing Renditions</div></div>
	<br />
	<cfif qry_detail.detail.link_kind NEQ "url">
		<!--- Preview --->
		<strong>#myFusebox.getApplicationData().defaults.trans("preview")#</strong> (#ucase(qry_detail.detail.thumb_extension)#, #qry_detail.theprevsize# MB, #qry_detail.detail.thumbwidth#x#qry_detail.detail.thumbheight# pixel)<br /> 
		<cfif qry_detail.detail.shared EQ "F">
			<a href="http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=p" target="_blank">
		<cfelse>
			<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#" target="_blank">
		</cfif>
		View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=p">Download</a>
		<!--- Nirvanix --->
		<cfif application.razuna.storage EQ "nirvanix" AND qry_detail.detail.shared EQ "T">
			<br><i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#</i>
		</cfif>
		 | <a href="##" onclick="toggleslide('divp#attributes.file_id#','inputp#attributes.file_id#');">Direct Link</a>
		<div id="divp#attributes.file_id#" style="display:none;"><input type="text" id="inputp#attributes.file_id#" style="width:100%;" value="http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=p" /></div>
		<!--- Original --->
		<cfif attributes.folderaccess NEQ "R">
			<br /><br />
			<cfif qry_detail.detail.link_kind NEQ "lan">
				<cfif qry_detail.detail.shared EQ "F">
					<strong>Original</strong> (#ucase(qry_detail.detail.img_extension)#, #qry_detail.thesize# MB, #qry_detail.detail.orgwidth#x#qry_detail.detail.orgheight# pixel)
					<br />
					<a href="http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=o" target="_blank">
				<cfelse>
					<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.img_filename_org#">
				</cfif>
				View
			</cfif>
			<cfif qry_detail.detail.link_kind NEQ "lan">
				</a>
			</cfif>
			 | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=o" target="_blank">Download</a>
			<!--- Nirvanix --->
			<cfif application.razuna.storage EQ "nirvanix" AND qry_detail.detail.shared EQ "T">
				<br><i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.img_filename_org#</i>
			</cfif>
			 | <a href="##" onclick="toggleslide('divo#attributes.file_id#','inputo#attributes.file_id#');">Direct Link</a>
			<div id="divo#attributes.file_id#" style="display:none;"><input type="text" id="inputo#attributes.file_id#" style="width:100%;" value="http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=o" /></div>
		</cfif>
	<cfelseif attributes.folderaccess NEQ "R">
		<a href="#qry_detail.detail.link_path_url#" target="_blank">#myFusebox.getApplicationData().defaults.trans("link_to_original")#</a>
	</cfif>
	<!--- Show related images (if any) --->
	<div id="relatedimages"></div>
	<!--- Show additional version --->
	<div id="additionalversions"></div>
</cfoutput>