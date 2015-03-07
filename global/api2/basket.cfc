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
<cfcomponent output="false" extends="authentication">

	<!--- Add to basket --->
	<cffunction name="addToBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="basket_id" required="true" type="string" />
		<cfargument name="asset_id" required="true" type="string" />
		<cfargument name="asset_type" required="false" type="string" default="org" />
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Local vars --->
			<cfset var qry = '' />
			<cfset var responsecode = 0 />
			<!--- Set time for remove --->
			<cfset var removetime = DateAdd("h", -72, "#now()#")>
			<!--- Loop over the asset_id --->
			<cfloop list="#arguments.asset_id#" index="assetid" delimiters=",">
				<!--- Check if we already have the same id of the same basket id--->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT asset_id
				FROM api_basket
				WHERE asset_id = <cfqueryparam value="#assetid#" cfsqltype="cf_sql_varchar">
				AND basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
				AND asset_type = <cfqueryparam value="#arguments.asset_type#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- if not found insert --->
				<cfif qry.recordcount EQ 0>
					<cfquery datasource="#application.razuna.api.dsn#" name="qry">
					INSERT INTO api_basket
					(basket_id, asset_id, date_added, asset_type)
					VALUES (
						<cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#assetid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#arguments.asset_type#" cfsqltype="cf_sql_varchar">
					)
					</cfquery>
				</cfif>
			</cfloop>
			<!--- Remove records that are older than 72 hours --->
			<cfquery datasource="#application.razuna.api.dsn#">
			DELETE FROM api_basket
			WHERE date_added < <cfqueryparam value="#removetime#" cfsqltype="cf_sql_timestamp">
			</cfquery>
			<!--- Return --->
			<cfset thexml.responsecode = 0 />
			<cfset thexml.message = "File has been added to the basket" />
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml />
	</cffunction>

	<!--- Show basket --->
	<cffunction name="showBasket" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="basket_id" required="true" type="string" />
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Local vars --->
			<cfset var qry = '' />
			<!--- Query--->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT asset_id, asset_type
			FROM api_basket
			WHERE basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var qry = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Delete basket --->
	<cffunction name="deleteBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="basket_id" required="true" type="string" />
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Local vars --->
			<cfset var qry = '' />
			<cfset var responsecode = 0 />
			<!--- Query--->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			DELETE FROM api_basket
			WHERE basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Return --->
			<cfset thexml.responsecode = 0 />
			<cfset thexml.message = "All files in your basket have been removed" />
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<cfreturn thexml />
	</cffunction>

	<!--- Delete item in basket --->
	<cffunction name="deleteItemInBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="basket_id" required="true" type="string" />
		<cfargument name="asset_id" required="true" type="string" />
		<cfargument name="asset_type" required="false" type="string" default="org" />
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Local vars --->
			<cfset var qry = '' />
			<cfset var responsecode = 0 />
			<!--- Query all asset_ids with same basket id--->
			<cfquery datasource="#application.razuna.api.dsn#">
			DELETE FROM api_basket
			WHERE basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
			AND asset_id = <cfqueryparam value="#arguments.asset_id#" cfsqltype="cf_sql_varchar">
			AND asset_type = <cfqueryparam value="#arguments.asset_type#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Return --->
			<cfset thexml.responsecode = 0 />
			<cfset thexml.message = "File(s) in your basket have been removed" />
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<cfreturn thexml />
	</cffunction>

	<!--- Download basket --->
	<cffunction name="downloadBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="basket_id" required="true" type="string" />
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Create basket name --->
			<cfset var uuid = createuuid("")>
			<cfset var name_of_download = "basket-" & uuid & ".zip">
			<!--- Call private function --->
			<cfinvoke method="downloadBasketDo" api_key="#arguments.api_key#" basket_id="#arguments.basket_id#" uuid="#uuid#" name_of_download="#name_of_download#" />
			<!--- Return --->
			<cfset thexml.responsecode = 0 />
			<cfset thexml.message = name_of_download />
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<cfreturn thexml />
	</cffunction>

	<!--- Check availability of basket --->
	<cffunction name="checkForBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="zip_file" required="true" type="string" />
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<cftry>
				<cfset var path = ExpandPath("../tmp/") & arguments.zip_file />
				<cfset var thefile = GetFileInfo(path) />
				<!--- Return --->
				<cfset thexml.responsecode = 0 />
				<cfset thexml.message = true />
				<cfcatch type="any">
					<!--- Return --->
					<cfset thexml.responsecode = 0 />
					<cfset thexml.message = false />
				</cfcatch>
			</cftry>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<cfreturn thexml />
	</cffunction>



	<!--- --- INTERNAL FUNCTIONS --- --->

	<!--- Download basket internal --->
	<cffunction name="downloadBasketDo" access="private" output="false">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="basket_id" required="true" type="string" />
		<cfargument name="uuid" required="true" type="string" />
		<cfargument name="name_of_download" required="true" type="string" />
		<!--- Local vars --->
		<cfset var qry = ''>
		<cfset var responsecode = 0>
		<cfset var basketname = arguments.uuid>
		<cfset var path = ExpandPath("../tmp/")>
		<cfset var tmpdir = GetTempDirectory() & "#basketname#">
		<!--- Create directory --->
		<cfdirectory action="create" directory="#tmpdir#" mode="775" />
		<!--- Get all files in basket --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry">
		SELECT asset_id, asset_type
		FROM api_basket
		WHERE basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Loop trough the basket --->
		<cfloop query="qry">
			<!--- Get files --->
			<cfinvoke method="getFiles" api_key="#arguments.api_key#" asset_id="#asset_id#" asset_type="#asset_type#" tmpdir="#tmpdir#" />
			<!--- Get videos --->
			<cfinvoke method="getVideos" api_key="#arguments.api_key#" asset_id="#asset_id#" asset_type="#asset_type#" tmpdir="#tmpdir#" />
			<!--- Get audios --->
			<cfinvoke method="getAudios" api_key="#arguments.api_key#" asset_id="#asset_id#" asset_type="#asset_type#" tmpdir="#tmpdir#" />
			<!--- Get images --->
			<cfinvoke method="getImages" api_key="#arguments.api_key#" asset_id="#asset_id#" asset_type="#asset_type#" tmpdir="#tmpdir#" />
		</cfloop>
		<!--- All done. Now zip up the folder --->
		<cfset var downloadname = arguments.name_of_download>
		<!--- ZIP --->
		<cfzip action="create" zipfile="#GetTempDirectory()##downloadname#" source="#tmpdir#" recurse="true" timeout="300" />
		<!--- Remove the tmp dir --->
		<cfdirectory action="delete" directory="#tmpdir#" recurse="true" />
		<!--- Move ZIP file --->
		<cffile action="move" source="#GetTempDirectory()##downloadname#" destination="#path##downloadname#" mode="775" />
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Get Files --->
	<cffunction name="getFiles" access="private" output="false">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="asset_id" required="true" type="string" />
		<cfargument name="tmpdir" required="true" type="string" />
		<!--- Local --->
		<cfset var qry = "" />
		<!--- Get Cachetoken --->
		<cfset var cachetoken = getcachetoken(arguments.api_key,"files")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getFiles */ file_extension as extension, file_name as filename, file_name_org as filenameorg, link_kind, link_path_url, path_to_asset, cloud_url_org
		FROM #application.razuna.api.prefix["#arguments.api_key#"]#files
		WHERE file_id = <cfqueryparam value="#arguments.asset_id#" cfsqltype="cf_sql_varchar">
		AND host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- If record is found --->
		<cfif qry.recordcount NEQ 0>
			<cftry>
				<!--- Get file from storage --->
			 <cfinvoke method="getFromStorage" api_key="#arguments.api_key#" pathtoasset="#qry.path_to_asset#" filenameorg="#qry.filenameorg#" filename="#qry.filename#" tmpdir="#arguments.tmpdir#" linkkind="#qry.link_kind#" linkpathurl="#qry.link_path_url#" />
			 	<cfcatch type="any">
			 		<cfset consoleoutput(true)>
					<cfset console(cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Get Videos --->
	<cffunction name="getVideos" access="private" output="false">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="asset_id" required="true" type="string" />
		<cfargument name="tmpdir" required="true" type="string" />
		<!--- Local --->
		<cfset var qry = "" />
		<!--- Get Cachetoken --->
		<cfset var cachetoken = getcachetoken(arguments.api_key,"videos")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getVideos */ vid_extension as extension, vid_filename as filename, vid_name_org as filenameorg, link_kind, link_path_url, path_to_asset, cloud_url_org
		FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos
		WHERE vid_id = <cfqueryparam value="#arguments.asset_id#" cfsqltype="cf_sql_varchar">
		AND host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- If record is found --->
		<cfif qry.recordcount NEQ 0>
			<cftry>
				<!--- Get file from storage --->
			 <cfinvoke method="getFromStorage" api_key="#arguments.api_key#" pathtoasset="#qry.path_to_asset#" filenameorg="#qry.filenameorg#" filename="#qry.filename#" tmpdir="#arguments.tmpdir#" linkkind="#qry.link_kind#" linkpathurl="#qry.link_path_url#" />
			 	<cfcatch type="any">
			 		<cfset consoleoutput(true)>
					<cfset console(cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn  />
	</cffunction>

	<!--- Get Audios --->
	<cffunction name="getAudios" access="private" output="false">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="asset_id" required="true" type="string" />
		<cfargument name="tmpdir" required="true" type="string" />
		<!--- Local --->
		<cfset var qry = "" />
		<!--- Get Cachetoken --->
		<cfset var cachetoken = getcachetoken(arguments.api_key,"audios")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getAudios */ aud_extension as extension, aud_name as filename, aud_name_org as filenameorg, link_kind, link_path_url, path_to_asset, cloud_url_org
		FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios
		WHERE aud_id = <cfqueryparam value="#arguments.asset_id#" cfsqltype="cf_sql_varchar">
		AND host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- If record is found --->
		<cfif qry.recordcount NEQ 0>
			<cftry>
				<!--- Get file from storage --->
			 <cfinvoke method="getFromStorage" api_key="#arguments.api_key#" pathtoasset="#qry.path_to_asset#" filenameorg="#qry.filenameorg#" filename="#qry.filename#" tmpdir="#arguments.tmpdir#" linkkind="#qry.link_kind#" linkpathurl="#qry.link_path_url#" />
			 	<cfcatch type="any">
			 		<cfset consoleoutput(true)>
					<cfset console(cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn  />
	</cffunction>

	<!--- Get Images --->
	<cffunction name="getImages" access="private" output="false">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="asset_id" required="true" type="string" />
		<cfargument name="asset_type" required="true" type="string" />
		<cfargument name="tmpdir" required="true" type="string" />
		<!--- Local --->
		<cfset var qry = "" />
		<!--- Get Cachetoken --->
		<cfset var cachetoken = getcachetoken(arguments.api_key,"images")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getImages#arguments.asset_type# */ img_extension as extension, img_filename as filename, img_filename_org as filenameorg, link_kind, link_path_url, path_to_asset, cloud_url_org
		FROM #application.razuna.api.prefix["#arguments.api_key#"]#images
		WHERE img_id = <cfqueryparam value="#arguments.asset_id#" cfsqltype="cf_sql_varchar">
		AND host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- If record is found --->
		<cfif qry.recordcount NEQ 0>
			<cftry>
				<!--- If asset_type is thumb --->
				<cfif arguments.asset_type NEQ "org">
					<!--- We need to change fielnameorg and filename --->
					<cfset thumb_format = getThumbExt(arguments.api_key) />
					<cfset qry.filenameorg = "thumb_" & arguments.asset_id & "." & thumb_format />
					<cfset qry.filename = qry.filenameorg />
				</cfif>
				<!--- Get file from storage --->
			 <cfinvoke method="getFromStorage" api_key="#arguments.api_key#" pathtoasset="#qry.path_to_asset#" filenameorg="#qry.filenameorg#" filename="#qry.filename#" tmpdir="#arguments.tmpdir#" linkkind="#qry.link_kind#" linkpathurl="#qry.link_path_url#" />
			 	<cfcatch type="any">
			 		<cfset consoleoutput(true)>
					<cfset console(cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn  />
	</cffunction>

	<!--- Get files from storage --->
	<cffunction name="getFromStorage" access="private" output="false">
		<cfargument name="api_key" required="true" type="string" />
		<cfargument name="pathtoasset" required="true" type="string" />
		<cfargument name="filenameorg" required="true" type="string" />
		<cfargument name="filename" required="true" type="string" />
		<cfargument name="tmpdir" required="true" type="string" />
		<cfargument name="linkkind" required="true" type="string" />
		<cfargument name="linkpathurl" required="true" type="string" />
		<!--- Get path to assets --->
		<cfset arguments.assetspath = getAssetsPath(arguments.api_key) />
		<!--- Create thread  --->
		<cfset var ttd = createuuid()>
		<!--- Local --->
		<cfif application.razuna.storage EQ "local" AND arguments.linkkind EQ "">
			<!--- Copy file --->
			<cfthread name="#ttd#" intstruct="#arguments#">
				<cffile action="copy" source="#attributes.intstruct.assetspath#/#application.razuna.api.hostid["#attributes.intstruct.api_key#"]#/#attributes.intstruct.pathtoasset#/#attributes.intstruct.filenameorg#" destination="#attributes.intstruct.tmpdir#/#attributes.intstruct.filename#" mode="775">
			</cfthread>
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon" AND arguments.linkkind EQ "">
			<!--- set asset path --->
			<cfthread name="#ttd#" intstruct="#arguments#">
				<cfinvoke component="amazon" method="Download">
					<cfinvokeargument name="key" value="/#attributes.intstruct.pathtoasset#/#attributes.intstruct.filenameorg#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.tmpdir#/#attributes.intstruct.filename#">
					<cfinvokeargument name="awsbucket" value="#application.razuna.awsbucket#">
				</cfinvoke>
			</cfthread>
			<!--- Akamai --->
			<!--- <cfelseif application.razuna.storage EQ "akamai" AND arguments.linkkind EQ "">
				<cfthread name="#ttd#" intstruct="#arguments.thestruct#">
					<cfhttp url="#attributes.intstruct.akaurl##attributes.intstruct.akadoc#/#attributes.intstruct.thename#" file="#attributes.intstruct.thename#" path="#attributes.intstruct.newpath#"></cfhttp>
				</cfthread> --->
			<!--- If this is a URL we write a file in the directory with the PATH --->
			<cfelseif arguments.linkkind EQ "url">
				<cfthread name="#ttd#" intstruct="#arguments#">
					<cffile action="write" file="#attributes.intstruct.tmpdir#/#attributes.intstruct.filename#.txt" output="This asset is located on a external source. Here is the direct link to the asset: #attributes.intstruct.linkpathurl#" mode="775">
				</cfthread>
			<!--- If this is a linked asset --->
			<cfelseif arguments.linkkind EQ "lan">
				<cfthread name="#ttd#" intstruct="#arguments#">
					<cffile action="copy" source="#attributes.intstruct.linkpathurl#" destination="#attributes.intstruct.tmpdir#/#attributes.intstruct.filename#" mode="775">
				</cfthread>
			</cfif>
		<!--- Wait for the thread above until the file is downloaded fully --->
		<cfthread action="join" name="#ttd#" />
		<cfreturn  />
	</cffunction>

</cfcomponent>