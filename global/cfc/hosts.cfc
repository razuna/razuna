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
<cfcomponent hint="CFC for hosts" output="false">

<!--- FUNCTION: INIT --->
<cffunction name="init" returntype="hosts" access="public" output="false">
	<cfargument name="dsn" type="string" required="yes" />
	<cfargument name="database" type="string" required="yes" />
	<cfset variables.dsn = arguments.dsn />
	<cfset variables.database = arguments.database />
	<cfreturn this />
</cffunction>

<!--- FUNCTION: This is called from the first time setup --->
<cffunction name="setupdb" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Setup database --->
	<cfinvoke component="db_#arguments.thestruct.database#" method="setup" thestruct="#arguments.thestruct#">
	<!--- Create tables --->
	<cfinvoke component="db_#arguments.thestruct.database#" method="create_host" thestruct="#arguments.thestruct#">
	<!--- Add Host --->
	<cfinvoke method="add" thestruct="#arguments.thestruct#">
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- FUNCTION: CHECK FOR SAME NAME --->
<cffunction name="checkname" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#variables.dsn#" name="qry">
	SELECT host_name
	FROM hosts
	WHERE 
	<cfif structkeyexists(arguments.thestruct, "host_name")>
		lower(host_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.host_name)#">
	<cfelseif structkeyexists(arguments.thestruct, "host_path")>
		lower(host_path) = <cfqueryparam value="#lcase(arguments.thestruct.host_path)#" cfsqltype="cf_sql_varchar">
	<cfelseif structkeyexists(arguments.thestruct, "host_db_prefix")>
		lower(host_db_prefix) = <cfqueryparam value="#lcase(arguments.thestruct.host_db_prefix)#_" cfsqltype="cf_sql_varchar">
	</cfif>
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- FUNCTION: Add Host --->
<cffunction hint="Add Host" name="add" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- If we come from first time setup --->
	<cfif structkeyexists(arguments.thestruct,"from_first_time")>
		<cfset variables.dsn = arguments.thestruct.dsn>
		<cfset variables.database = arguments.thestruct.database>
	</cfif>
	<!--- Check for the same name --->
	<cfquery datasource="#variables.dsn#" name="same">
	SELECT host_name
	FROM hosts
	WHERE lower(host_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.host_name)#">
	</cfquery>
	<!--- No record with the same name exist thus add it else throw an error --->
	<cfif same.recordcount EQ 0>
		<!--- Get new host id --->
		<!--- <cfinvoke component="global" method="getsequence" returnvariable="hostid" database="#variables.database#" dsn="#variables.dsn#" thetable="hosts" theid="host_id"> --->
		<cftransaction>
			<cfquery datasource="#variables.dsn#" name="hostid">
			SELECT <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(max(host_id),0) + 1 AS id
			FROM hosts
			</cfquery>
			<cfquery datasource="#variables.dsn#">
			INSERT INTO hosts
			(host_id)
			VALUES(<cfqueryparam value="#hostid.id#" cfsqltype="cf_sql_numeric">)
			</cfquery>
		</cftransaction>
		<!--- Set host_db_prefix & host_path--->
		<cfset arguments.thestruct.host_path = "raz" & hostid.id>
		<cfset arguments.thestruct.host_db_prefix = "raz1_">
		<cfset arguments.thestruct.host_id = hostid.id>
		<cfset arguments.thestruct.dsn = variables.dsn>
		<!--- NIRVANIX --->
		<cfif application.razuna.storage EQ "nirvanix" AND NOT structkeyexists(arguments.thestruct,"restore")>
			<!--- Create a random password --->
			<cfset var passrand = createuuid()>
			<!--- Get master account --->
			<cfinvoke component="settings" method="getconfig" thenode="nirvanix_master_name" returnvariable="attributes.qry_settings_nirvanix.set2_nirvanix_name">
			<cfinvoke component="settings" method="getconfig" thenode="nirvanix_master_pass" returnvariable="attributes.qry_settings_nirvanix.set2_nirvanix_pass">
			<!--- Get session token --->
			<cfinvoke component="nirvanix" method="login" thestruct="#attributes#" returnvariable="variables.nvxsession" />
			<!--- Create Child Account --->
			<cfinvoke component="nirvanix" method="CreateChildAccount">
				<cfinvokeargument name="nvxsession" value="#variables.nvxsession#">
				<cfinvokeargument name="username" value="#hostid.id#">
				<cfinvokeargument name="password" value="#passrand#">
			</cfinvoke>
		</cfif>
		<cftransaction>
			<!--- Insert into Host db --->
			<cfquery datasource="#variables.dsn#">
			UPDATE hosts
			SET
			host_name = <cfqueryparam value="#arguments.thestruct.host_name#" cfsqltype="cf_sql_varchar">, 
			host_path = <cfqueryparam value="#arguments.thestruct.host_path#" cfsqltype="cf_sql_varchar">, 
			host_create_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
			host_db_prefix = <cfqueryparam value="#arguments.thestruct.host_db_prefix#" cfsqltype="cf_sql_varchar">, 
			host_shard_group = <cfqueryparam value="#arguments.thestruct.host_db_prefix#" cfsqltype="cf_sql_varchar">
			WHERE host_id = <cfqueryparam value="#hostid.id#" cfsqltype="cf_sql_numeric">
			</cfquery>
		</cftransaction>
			<cfif structkeyexists(arguments.thestruct,"from_first_time")>
				<!--- <cfinvoke component="global" method="getsequence" returnvariable="userid" database="#variables.database#" dsn="#variables.dsn#" thetable="users" theid="user_id"> --->
				<!--- Hash Password --->
				<cfset thepass = hash(arguments.thestruct.user_pass, "MD5", "UTF-8")>
				<!--- Insert the User into the DB --->
				<cfset newuserid = createuuid()>
				<cfquery datasource="#variables.dsn#">
				INSERT INTO users
				(user_id, user_login_name, user_email, user_pass, user_first_name, user_last_name, user_in_admin, user_create_date, user_active, user_in_dam)
				VALUES(
				<cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.thestruct.user_login_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.thestruct.user_email#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.thestruct.user_first_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.thestruct.user_last_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="T" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="T" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="T" cfsqltype="cf_sql_varchar">
				)
				</cfquery>
				<!--- Insert the user as systemadmin to the cross table --->
				<cfquery datasource="#variables.dsn#">
				INSERT INTO ct_groups_users
				(ct_g_u_user_id, ct_g_u_grp_id)
				VALUES(
				<cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- Set session for the user --->
				<cfset session.hostid = hostid.id>
				<cfset session.hostdbprefix = arguments.thestruct.host_db_prefix>
			</cfif>
			<!--- COPY NEWHOST DIR --->
			<cfinvoke method="directoryCopy">
				<cfinvokeargument name="source" value="#arguments.thestruct.pathhere#/newhost/hostfiles">
				<cfinvokeargument name="destination" value="#arguments.thestruct.pathoneup#/#arguments.thestruct.host_path#">
			</cfinvoke>
			<!--- ADD THE SYSTEMADMIN TO THE CROSS TABLE FOR THE HOSTS --->
			<cfinvoke component="global.cfc.groups_users" method="searchUsersOfGroups" returnvariable="theadmins" func_dsn="#variables.dsn#" list_grp_name="SystemAdmin">
			<cfoutput query="theadmins">
				<cftransaction>
					<cfquery datasource="#variables.dsn#">
					insert into ct_users_hosts
					(ct_u_h_user_id, ct_u_h_host_id)
					values(
					<cfqueryparam value="#user_id#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#hostid.id#" cfsqltype="cf_sql_numeric">
					)
					</cfquery>
				</cftransaction>
			</cfoutput>
			<!--- INSERT DEFAULT VALUES --->
			<cfinvoke method="insert_default_values" thestruct="#arguments.thestruct#">
			<!--- Create the fusebox files --->
			<cfinvoke method="newHostCreateApp">
				<cfinvokeargument name="module_folder" value="dam">
				<cfinvokeargument name="thisid" value="#hostid.id#">
				<cfinvokeargument name="host_path_replace" value="#arguments.thestruct.host_path#">
				<cfinvokeargument name="host_db_prefix_replace" value="#arguments.thestruct.host_db_prefix#">
				<cfinvokeargument name="pathoneup" value="#arguments.thestruct.pathoneup#">
			</cfinvoke>
			<!--- <cfinvoke method="newHostCreateApp">
				<cfinvokeargument name="module_folder" value="web">
				<cfinvokeargument name="thisid" value="#hostid.id#">
				<cfinvokeargument name="host_path_replace" value="#arguments.thestruct.host_path#">
				<cfinvokeargument name="host_db_prefix_replace" value="#arguments.thestruct.host_db_prefix#">
				<cfinvokeargument name="pathoneup" value="#arguments.thestruct.pathoneup#">
			</cfinvoke> --->
			<!--- NIRVANIX: Add child settings into settings_2 --->
			<cfif application.razuna.storage EQ "nirvanix" AND NOT structkeyexists(arguments.thestruct,"restore")>
				<cftransaction>
					<cfquery datasource="#variables.dsn#">
					UPDATE #arguments.thestruct.host_db_prefix#settings_2
					SET 
					set2_nirvanix_name = <cfqueryparam value="#attributes.qry_settings_nirvanix.set2_nirvanix_name#" cfsqltype="cf_sql_varchar">, 
					set2_nirvanix_pass = <cfqueryparam value="#attributes.qry_settings_nirvanix.set2_nirvanix_pass#" cfsqltype="cf_sql_varchar">
					WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				</cftransaction>
			</cfif>
		<!--- Flush Cache --->
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="hosts" />
	</cfif>
	<cfreturn  />
</cffunction>

<cffunction name="insert_default_values_remote" access="remote" output="true" returntype="Any">
	<cfargument name="dsn" type="string" required="true">
	<cfargument name="host_db_prefix" type="string" required="true">
	<cfargument name="host_path" type="string" required="true">
	<cfargument name="host_id" type="numeric" required="true">
	<!--- Params --->
	<cfset arguments.thestruct = structnew()>
	<cfset arguments.thestruct.dsn = arguments.dsn>
	<cfset arguments.thestruct.host_db_prefix = arguments.host_db_prefix>
	<cfset arguments.thestruct.host_id = arguments.host_id>
	<cfset arguments.thestruct.folder_in = "">
	<cfset arguments.thestruct.folder_in_batch = "">
	<cfset arguments.thestruct.folder_out = "">
	<cfset arguments.thestruct.email_from = "razuna@razuna.com">
	<cfset arguments.thestruct.langs_selected = "1_English">
	<cfset arguments.thestruct.set_lang_1 = "English">
	<!--- <cfset arguments.thestruct.url_website = "http://#cgi.server_name#/#arguments.host_path#/web"> --->
	<!--- Get application paths
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" /> --->
	<!--- insert default values --->
	<cfinvoke method="insert_default_values" thestruct="#arguments.thestruct#">
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Insert Default Values --->
<cffunction name="insert_default_values" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	
	<cftry>
		<!--- Param --->
		<cfparam default="" name="arguments.thestruct.oracle_url">
		<cfparam default="" name="arguments.thestruct.path_assets">
		<cfparam default="1_English" name="arguments.thestruct.langs_selected">
		<cfparam default="" name="arguments.thestruct.email_from">
		<!--- Now add selected languages --->
		<cfloop list="#arguments.thestruct.langs_selected#" delimiters="," index="x">
			<!--- Grab lang name --->
			<cfset langname = listlast(x,"_")>
			<!--- Grab ID --->
			<cfset langid = listfirst(x,"_")>
			<!--- Insert --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.host_db_prefix#languages
			(lang_id, lang_name, lang_active, host_id)
			VALUES(
			<cfqueryparam value="#langid#" cfsqltype="cf_sql_numeric">,
			<cfqueryparam value="#langname#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="t" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.host_id#" cfsqltype="cf_sql_numeric">
			)
			</cfquery>
			<!--- Setting DB: Titel Intra --->
			<cfset thelang = "arguments.thestruct.set_title_intra_" & x>
			<cfset thelang = replacenocase("#thelang#","arguments.thestruct.","","ALL")>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.host_db_prefix#settings
			(set_id, set_pref, host_id)
			VALUES(
			<cfqueryparam value="#ucase(thelang)#" cfsqltype="cf_sql_varchar">, 
			<cfqueryparam value="Razuna - Enterprise Digital Asset Management (DAM)" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.host_id#" cfsqltype="cf_sql_numeric">
			)
			</cfquery>
		</cfloop>
		<!--- SETTING 2 --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		insert into #arguments.thestruct.host_db_prefix#settings_2
		(set2_id, 
		set2_date_format, 
		set2_date_format_del, 
		set2_meta_author, 
		set2_meta_publisher, 
		set2_meta_copyright,
		set2_meta_robots, 
		set2_meta_revisit, 
		set2_create_imgfolders_where, 
		set2_img_format, 
		set2_img_thumb_width, 
		set2_img_thumb_heigth,
		set2_img_comp_width, 
		set2_img_comp_heigth, 
		set2_img_download_org, 
		set2_doc_download, 
		set2_intranet_gen_download, 
		set2_cat_web, 
		set2_cat_intra, 
		set2_url_website, 
		set2_payment_pre,
		set2_payment_bill, 
		set2_payment_pod, 
		set2_payment_cc, 
		set2_payment_cc_cards, 
		set2_payment_paypal, 
		set2_vid_preview_heigth, 
		set2_vid_preview_width, 
		set2_vid_preview_time,
		set2_vid_preview_start, 
		set2_vid_preview_author, 
		set2_cat_vid_web, 
		set2_cat_vid_intra, 
		set2_cat_aud_web, 
		set2_cat_aud_intra,
		set2_create_vidfolders_where, 
		set2_email_from, 
		set2_path_to_assets,
		host_id
		)
		Values
		(1, 
		'euro', 
		'/', 
		'razuna.com', 
		'razuna.com', 
		'razuna.com', 
		'all', 
		'7 days', 
		'0', 
		'jpg',
		'120', 
		'120', 
		'350', 
		'350', 
		'T', 
		'T', 
		'F', 
		'T', 
		'T', 
		'', 
		'T', 
		'T', 
		'T', 
		'F',
		'Visa,Mastercard,American Express', 
		'F', 
		124, 
		250, 
		'00:00:20', 
		'00:00:03',
		'Razuna', 
		'T', 
		'T', 
		'F', 
		'F', 
		0,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.email_from#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.path_assets#">,
		<cfqueryparam value="#arguments.thestruct.host_id#" cfsqltype="cf_sql_numeric">
		)
		</cfquery>
		<!--- Tools
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO tools
		(thetool, thepath)
		VALUES(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="imagemagick">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thetools.imagemagick#">
		)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO tools
		(thetool, thepath)
		VALUES(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="ffmpeg">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thetools.ffmpeg#">
		)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO tools
		(thetool, thepath)
		VALUES(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="exiftool">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thetools.exiftool#">
		)
		</cfquery>
		 --->
		<!--- Create the UploadBin Folder --->
		<!---
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into #arguments.thestruct.host_db_prefix#folders
		(FOLDER_ID, FOLDER_NAME, FOLDER_LEVEL, FOLDER_ID_R, FOLDER_MAIN_ID_R, host_id)
		Values('1', 'UploadBin', 1, '1', '1', #arguments.thestruct.host_id#<!--- <cfqueryparam value="#arguments.thestruct.host_id#" cfsqltype="cf_sql_numeric"> --->)
		</cfquery>
		--->
		<!--- and description with it --->
		<!---
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into #arguments.thestruct.host_db_prefix#folders_desc
		(FOLDER_ID_R, LANG_ID_R, FOLDER_DESC, host_id)
		Values('1', 1, 'This is the default folder for storing files that get uploaded within the administration. Feel free to move the files to other folders, but be careful with removing files because they might be used within the CMS part.', <!--- <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> --->#arguments.thestruct.host_id#)
		</cfquery>
		--->
		<!--- Create a new ID --->
		<cfset var newfolderid = replace(createuuid(),"-","","ALL")>
		<!--- Create the default Collections Folder --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into #arguments.thestruct.host_db_prefix#folders
		(FOLDER_ID, FOLDER_NAME, FOLDER_LEVEL, FOLDER_ID_R, FOLDER_MAIN_ID_R, FOLDER_IS_COLLECTION, host_id)
		Values('#newfolderid#', 'Collections', 1, '#newfolderid#', '#newfolderid#', 'T', #arguments.thestruct.host_id#)
		</cfquery>
		<!--- and description with it --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into #arguments.thestruct.host_db_prefix#folders_desc
		(FOLDER_ID_R, LANG_ID_R, FOLDER_DESC, host_id)
		Values('#newfolderid#', 1, 'This is the default collections folder for storing collections.', #arguments.thestruct.host_id#)
		</cfquery>
		<cfcatch type="any">
			<cfmail to="support@razuna.com" from="server@razuna.com" subject="Error during inserting default values" type="html">
				<cfdump var="#cfcatch#">
			</cfmail>
		</cfcatch>	
	</cftry>
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- create Application.cfm for any module --->
<cffunction name="newHostCreateApp" access="remote" output="true" hint="create fusebox.init.cfm for any module">
	<cfargument name="module_folder" type="string" required="yes" hint="web,dam...">
	<cfargument name="thisid" type="numeric" required="true">
	<cfargument name="host_path_replace" type="string" required="true">
	<cfargument name="host_db_prefix_replace" type="string" required="true">
	<cfargument name="pathoneup" type="string" required="true">
	<!--- function internal vars --->
	<cfset var something = "">
	<cfset var something2 = "">
	<!--- create the folder --->
	<cfif not DirectoryExists("#arguments.pathoneup#/#arguments.host_path_replace#/#arguments.module_folder#")>
		<cfdirectory action="create" directory="#arguments.pathoneup#/#arguments.host_path_replace#/#arguments.module_folder#" mode="775">
	</cfif>
	<!--- content of fusebox.init.cfm should be left-aligned => code moved to included-file --->
	<cfsavecontent variable="something"><cfinclude template="../../admin/newhost/#arguments.module_folder#_fuseboxinit.cfm"></cfsavecontent>
	<!--- Write the Application file in the Intra Folder --->
	<cffile action="write" file="#arguments.pathoneup#/#arguments.host_path_replace#/#arguments.module_folder#/fusebox.init.cfm" output="#something#" mode="775">
</cffunction>

!--- ------------------------------------------------------------------------------------- --->
<!--- Get all the records --->
<cffunction hint="Get all records" name="getall" returntype="query" output="false" access="public">
	<cfargument name="orderBy" type="string" required="false" default="host_name ASC" hint="""ORDER BY #yourtext#""">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#variables.dsn#" name="localquery">
		SELECT host_id, host_name
		FROM hosts
		ORDER BY #arguments.orderBy#
	</cfquery>
	<cfreturn localquery>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get one detailled record --->
<cffunction hint="Get one record" name="getdetail" returntype="query" output="false" access="public">
	<cfargument name="thestruct" type="Struct">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<!--- function-body --->
	<cfquery datasource="#variables.dsn#" name="localquery">
		SELECT host_id, host_name, host_path, host_db_prefix, host_lang, host_type, host_shard_group
		FROM hosts
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
	</cfquery>
	<cfreturn localquery>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- copy newhost dir --->
<cffunction name="directoryCopy" output="false" hint="copy newhost dir">
	<cfargument name="source" required="true" type="string">
	<cfargument name="destination" required="true" type="string">
	<cfargument name="move" required="false" type="string">
	<!--- Check if the move param exists if not we copy --->
	<cfif isdefined("move")>
		<cfset theaction = "move">
	<cfelse>
		<cfset theaction = "copy">
	</cfif>
	
	<cfset var contents = "" />
	<cfset var dirDelim = "/">

	<cfif server.OS.Name contains "Windows">
		<cfset dirDelim = "\" />
	</cfif>

	<cfif not(directoryExists(arguments.destination))>
		<cfdirectory action="create" directory="#arguments.destination#" mode="775">
	</cfif>

	<cfdirectory action="list" directory="#arguments.source#" name="contents">
	
	<cfloop query="contents">
		<cfif contents.type eq "file" AND contents.name IS NOT "thumbs.db" AND contents.name IS NOT "dwsync.xml">
			<cffile action="#theaction#" source="#arguments.source#/#name#" destination="#arguments.destination#/#name#" mode="775">
		<cfelseif contents.type eq "dir" AND contents.name IS NOT "CVS" AND contents.name IS NOT ".svn">
			<cfset directoryCopy(arguments.source & dirDelim & name, arguments.destination & dirDelim & name, arguments.move) />
		</cfif>
	</cfloop>
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Update Host --->
<cffunction name="update" output="false" access="public">
	<cfargument name="thestruct" type="Struct">

	<cfquery datasource="#variables.dsn#" name="qry_hostslist">
	SELECT host_lang, host_path, host_db_prefix p
	FROM hosts
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
	</cfquery>

	<!--- If the count of languages is higher then it was before then add a new language to the setting table --->
	<cfif #arguments.thestruct.host_lang# GT qry_hostslist.host_lang>
		<cfset howmanylangnow = #qry_hostslist.host_lang#>
		<cfset langdif = #arguments.thestruct.host_lang# - #howmanylangnow#>
		<cfset fromon = #qry_hostslist.host_lang# + 1>
		<!--- Languages --->
		<cfloop index="l" from="#fromon#" to="#arguments.thestruct.host_lang#">
			<cfset thelang = "set_lang_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				insert into #qry_hostslist.p#settings
				(set_id, host_id)
				values(
				<cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
				)
			</cfquery>
		</cfloop>
		<!--- Titels Intra --->
		<cfloop index="l" from="#fromon#" to="#arguments.thestruct.host_lang#">
			<cfset thelang = "set_title_intra_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				insert into #qry_hostslist.p#settings
				(set_id, set_pref, host_id)
				values(
				<cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="Razuna - Digital Asset Management" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
				)
			</cfquery>
		</cfloop>
		<!--- Titels WebSite --->
		<cfloop index="l" from="#fromon#" to="#arguments.thestruct.host_lang#">
			<cfset thelang = "set_title_website_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				insert into #qry_hostslist.p#settings
				(set_id, set_pref, host_id)
				values(
				<cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="Razuna - WebSite" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
				)
			</cfquery>
		</cfloop>
		<!--- Meta Keywords --->
		<cfloop index="l" from="#fromon#" to="#arguments.thestruct.host_lang#">
			<cfset thelang = "set_meta_keywords_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				insert into #qry_hostslist.p#settings
				(set_id, set_pref, host_id)
				values(
				<cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="Razuna, Open Source, Digital Asset Management, DAM, Media Asset Management, MAM" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
				)
			</cfquery>
		</cfloop>
		<!--- Meta Description --->
		<cfloop index="l" from="#fromon#" to="#arguments.thestruct.host_lang#">
			<cfset thelang = "set_meta_description_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				insert into #qry_hostslist.p#settings
				(set_id, set_pref, host_id)
				values(
				<cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="Razuna - the Open Source Enterprise Digital Asset Management (DAM/MAM) Solution with integrated Content Management (CMS)!" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
				)
			</cfquery>
		</cfloop>
		<!--- Meta Custom --->
		<cfloop index="l" from="#fromon#" to="#arguments.thestruct.host_lang#">
			<cfset thelang = "set_meta_custom_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				insert into #qry_hostslist.p#settings
				(set_id, host_id)
				values(
				<cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
				)
			</cfquery>
		</cfloop>
	</cfif>

	<!--- If the count of languages is LOWER then it was before then remove the language from the setting table --->
	<cfif #arguments.thestruct.host_lang# LT qry_hostslist.host_lang>
		<cfset fromon = #arguments.thestruct.host_lang# + 1>
		<!--- Languages --->
		<cfloop index="l" from="#qry_hostslist.host_lang#" to="#fromon#" step="-1">
			<cfset thelang = "set_lang_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				delete from #qry_hostslist.p#settings
				where set_id = <cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
			</cfquery>
		</cfloop>
		<!--- Titles Intra --->
		<cfloop index="l" from="#qry_hostslist.host_lang#" to="#fromon#" step="-1">
			<cfset thelang = "set_title_intra_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				delete from #qry_hostslist.p#settings
				where set_id = <cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
			</cfquery>
		</cfloop>
		<!--- Titles WebSite --->
		<cfloop index="l" from="#qry_hostslist.host_lang#" to="#fromon#" step="-1">
			<cfset thelang = "set_title_website_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
				delete from #qry_hostslist.p#settings
				where set_id = <cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
			</cfquery>
		</cfloop>
		<!--- Meta Keywords --->
		<cfloop index="l" from="#qry_hostslist.host_lang#" to="#fromon#" step="-1">
			<cfset thelang = "set_meta_keywords_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
			delete from #qry_hostslist.p#settings
			where set_id = <cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
			</cfquery>
		</cfloop>
		<!--- Meta Description --->
		<cfloop index="l" from="#qry_hostslist.host_lang#" to="#fromon#" step="-1">
			<cfset thelang = "set_meta_description_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
			delete from #qry_hostslist.p#settings
			where set_id = <cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
			</cfquery>
		</cfloop>
		<!--- Meta Custom --->
		<cfloop index="l" from="#qry_hostslist.host_lang#" to="#fromon#" step="-1">
			<cfset thelang = "set_meta_custom_#l#">
			<cfset thelang = #ucase(thelang)#>
			<cfquery datasource="#variables.dsn#">
			delete from #qry_hostslist.p#settings
			where set_id = <cfqueryparam value="#thelang#" cfsqltype="cf_sql_varchar">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
			</cfquery>
		</cfloop>
		<!--- Remove translations from database table
		<cfloop index="l" from="#qry_hostslist.host_lang#" to="#fromon#" step="-1">
			<cfquery datasource="#variables.dsn#">
				delete from #qry_hostslist.p#translations
				where lang_id_r = <cfqueryparam value="#l#" cfsqltype="cf_sql_numeric">
			</cfquery>
		</cfloop> --->
	</cfif>

	<cfquery datasource="#variables.dsn#">
	update hosts
	set host_lang = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_lang#">
	where host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
	</cfquery>
	
	<!--- Flush Cache --->
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="hosts" />

</cffunction>

<!--- This is from remote --->
<cffunction name="remove_remote" access="remote" output="true" returntype="Any">
	<cfargument name="id" type="string" required="true">
	<cfargument name="dsn" type="string" required="true">
	<cfargument name="database" type="string" required="true">
	<cfargument name="storage" type="string" required="true">
	<cfargument name="schema" type="string" required="true">
	<!--- Params --->
	<cfset arguments.thestruct = structnew()>
	<cfset arguments.thestruct.dsn = arguments.dsn>
	<cfset arguments.thestruct.id = arguments.id>
	<cfset arguments.thestruct.database = arguments.database>
	<cfset arguments.thestruct.storage = arguments.storage>
	<cfset arguments.thestruct.theschema = arguments.schema>
	<!--- Now call the below function --->
	<cfinvoke method="remove" thestruct="#arguments.thestruct#">
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Remove Host --->
<cffunction name="remove" output="false" access="public">
	<cfargument name="thestruct" type="Struct">
	<!--- Query host --->
	<cfquery datasource="#arguments.thestruct.dsn#" name="qry_rhost">
	SELECT host_path, host_shard_group
	FROM hosts
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
	</cfquery>
	<!--- Only if we find a record --->
	<cfif qry_rhost.recordcount EQ 1>
		<cftry>
			<!--- REMOVE THE DIRECTORY ON THE FILESYSTEM --->
			<cfif arguments.thestruct.storage NEQ "nirvanix">
				<cfset thisdir = "#arguments.thestruct.pathoneup#/#qry_rhost.host_path#">
				<cfif directoryExists(thisdir)>
					<cfdirectory action="delete" directory="#arguments.thestruct.pathoneup#/#qry_rhost.host_path#" mode="775" recurse="yes">
				</cfif>
			</cfif>
			<!--- Remove the Host entry --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			DELETE FROM hosts
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
			</cfquery>
			<!--- Remove any user linked to this host --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			DELETE FROM ct_users_hosts
			WHERE ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
			</cfquery>
			<!--- REMOVE DATA RELATED TO HOST FROM groups, permissions, modules --->
			<!--- groups-permissions --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			DELETE
			FROM ct_groups_permissions
			WHERE EXISTS(
						SELECT groups.grp_id
						FROM groups
						WHERE groups.grp_id = ct_groups_permissions.ct_g_p_grp_id
						AND groups.grp_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
						)
			OR EXISTS(
						SELECT permissions.per_id
						FROM permissions
						WHERE permissions.per_id = ct_groups_permissions.ct_g_p_per_id
						AND permissions.per_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
						)
			</cfquery>
			<!--- groups-users --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			DELETE FROM	ct_groups_users
			WHERE EXISTS(
						SELECT groups.grp_id
						FROM groups
						WHERE groups.grp_id = ct_groups_users.ct_g_u_grp_id
						AND groups.grp_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
						)
			</cfquery>
			<!--- remove entries from data-tables --->
			<!--- groups --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			DELETE FROM	groups
			WHERE grp_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
			</cfquery>
			<!--- permissions --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			DELETE FROM permissions
			WHERE per_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
			</cfquery>
			<!--- modules --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			DELETE FROM	modules
			WHERE mod_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
			</cfquery>
			<cfcatch type="any">
				<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="Error removing tables">
					<cfdump var="#cfcatch#" />
				</cfmail>
			</cfcatch>
		</cftry>
		<!--- Since 1.4 we only remove records in the DB and don't drop tables anymore --->
		
		<!--- Upper case the sharding group prefix --->
		<cfset host_shard_group = lcase(qry_rhost.host_shard_group)>
		
		<!--- ORACLE --->
		<cfif arguments.thestruct.database EQ "oracle">
			<cfquery datasource="#arguments.thestruct.dsn#" name="tbl">
			SELECT object_name 
			FROM user_objects 
			WHERE object_type='TABLE' 
			AND lower(object_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#host_shard_group#%">
			</cfquery>
			<!--- Loop over tables --->
			<cfloop query="tbl">
				<!--- Remove Data --->
				<cftry>
					<cfquery datasource="#arguments.thestruct.dsn#">
					DELETE FROM #object_name#
					WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
					</cfquery>
					<cfcatch type="any">
					</cfcatch>
				</cftry>
			</cfloop>
		<!--- DB2 --->
		<cfelseif arguments.thestruct.database EQ "db2">
			<!--- Get all foreign key constraints and set them to no enforced --->
			<cfquery datasource="#arguments.thestruct.dsn#" name="const">
			SELECT constname, tabname
			FROM syscat.tabconst
			WHERE tabschema = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ucase(arguments.thestruct.theschema)#">
			AND type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="F">
			</cfquery>
			<cfloop query="const">
				<cfquery datasource="#arguments.thestruct.dsn#">
				ALTER TABLE #ucase(arguments.thestruct.theschema)#.#ucase(tabname)# ALTER FOREIGN KEY #constname# NOT ENFORCED
				</cfquery>
			</cfloop>
			<!--- Get table where to remove records --->
			<cfquery datasource="#arguments.thestruct.dsn#" name="tbl">
			SELECT tabname
			FROM syscat.tables
			WHERE lower(tabschema) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#host_shard_group#%">
			</cfquery>
			<!--- Loop over tables --->
			<cfloop query="tbl">
				<!--- Remove Data --->
				<cftry>
					<cfquery datasource="#arguments.thestruct.dsn#">
					DELETE FROM #tabname#
					WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
					</cfquery>
					<cfcatch type="any">
					</cfcatch>
				</cftry>
			</cfloop>
			<!--- Enable constraints --->
			<cfloop query="const">
				<cfquery datasource="#arguments.thestruct.dsn#">
				ALTER TABLE #ucase(arguments.thestruct.theschema)#.#ucase(tabname)# ALTER FOREIGN KEY #constname# ENFORCED
				</cfquery>
			</cfloop>
		<!--- For other DBs --->
		<cfelse>
			<!--- Get tables with this prefix --->
			<cfquery datasource="#arguments.thestruct.dsn#" name="tbl">
			SELECT table_name
			FROM information_schema.tables
			WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#host_shard_group#%">
			</cfquery>
			<!--- Loop over tables --->
			<cfloop query="tbl">
				<!--- MSSQL --->
				<cfif arguments.thestruct.database EQ "mssql">
					<cfquery datasource="#arguments.thestruct.dsn#">
					ALTER TABLE #application.razuna.theschema#.#table_name# NOCHECK CONSTRAINT ALL
					</cfquery>
				</cfif>
				<!--- MySQL --->
				<cfif arguments.thestruct.database EQ "mysql">
					<cfquery datasource="#arguments.thestruct.dsn#">
					SET foreign_key_checks = 0
					</cfquery>
				</cfif>
				<!--- H2 --->
				<cfif arguments.thestruct.database EQ "h2">
					<cfquery datasource="#arguments.thestruct.dsn#">
					ALTER TABLE #table_name# SET REFERENTIAL_INTEGRITY false
					</cfquery>
				</cfif>
				<!--- Remove Data --->
				<cftry>
					<cfquery datasource="#arguments.thestruct.dsn#">
					DELETE FROM #table_name#
					WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.id#">
					</cfquery>
					<cfcatch type="any">
					</cfcatch>
				</cftry>
			</cfloop>
		</cfif>
		<!--- Flush Cache --->
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="hosts" />
	</cfif>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- RECREATE HOST --->
<cffunction name="hostupdate" output="true">
	<cfargument name="thestruct" type="Struct">
	<!--- function internal vars --->
	<!--- get host info for the below variables --->
	<cfset var qrythishost = getDetail(arguments.thestruct)>
	<cfset var iLoop = "">
	<!--- set variables which we need in the create app files below --->
	<cfset var thisid = arguments.thestruct.host_id>
	<cfset var host_path_replace = qrythishost.host_path>
	<cfset var host_db_prefix_replace = qrythishost.host_shard_group>
	<cfset var thefiles = 0>
	<cfset var sqlStmt = "">
	<!--- function body --->
	<!--- Remove DAM directories and files so we can copy them later on without problems --->
	<cftry>
		<!--- directories
		<cfdirectory action="delete" directory="#arguments.thestruct.pathoneup#/#host_path_replace#/dam/translations" mode="775" recurse="yes"> --->
		<!--- files --->
		<cfdirectory action="list" directory="#arguments.thestruct.pathoneup#/#host_path_replace#/dam/" name="thefiles">
		<cfloop query="thefiles">
			<cfif thefiles.type eq "file">
				<cffile action="delete" file="#arguments.thestruct.pathoneup#/#host_path_replace#/dam/#name#">
			</cfif>
		</cfloop>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<!--- COPY NEWHOST DAM DIR --->
	<cfinvoke method="directoryCopy">
		<cfinvokeargument name="source" value="#arguments.thestruct.pathhere#/newhost/hostfiles/dam">
		<cfinvokeargument name="destination" value="#arguments.thestruct.pathoneup#/#host_path_replace#/dam">
	</cfinvoke>
	<!--- Re-Write the fusebox files files --->
	<!--- <cfloop list="dam,web" index="iLoop"> --->
		<cfinvoke method="newHostCreateApp">
			<cfinvokeargument name="module_folder" value="dam">
			<cfinvokeargument name="thisid" value="#thisid#">
			<cfinvokeargument name="host_path_replace" value="#host_path_replace#">
			<cfinvokeargument name="host_db_prefix_replace" value="#host_db_prefix_replace#">
			<cfinvokeargument name="pathoneup" value="#arguments.thestruct.pathoneup#">
		</cfinvoke>
	<!--- </cfloop> --->
	<!--- Now update the language table from this host. Compare the change and id column
	<cfloop index="l" from="1" to="#qrythishost.host_lang#">
		<!--- Error check to see if the language is here, if not add all the translation from the master translation table --->
		<cfquery datasource="#variables.dsn#" name="ishere">
			SELECT trans_id
			FROM #host_db_prefix_replace#translations
			WHERE lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#l#">
		</cfquery>
		<cfif ishere.recordcount EQ 0>
			<cfquery datasource="#variables.dsn#">
				<cfset sqlStmt = "INSERT INTO #host_db_prefix_replace#translations (trans_id, lang_id_r, trans_text)
									SELECT trans_id, lang_id_r, trans_text
									FROM   translations
									WHERE  lang_id_r = #evaluate(l)# ">
				<cfstoredproc datasource="#variables.dsn#" procedure="#session.theoraschema#.exec_insertinto_sql">
					<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="sqlstatement" type="in" value="#sqlStmt#">
				</cfstoredproc>
			</cfquery>
		<!--- else do the update thing on the translations --->
		<cfelse>
			<!--- Insert all NEW Language tags from the master translation table --->
			<cfset sqlStmt = "INSERT INTO #host_db_prefix_replace#translations (trans_id, lang_id_r, trans_text)
							   (SELECT t.trans_id, t.lang_id_r, t.trans_text
								FROM   translations t
								WHERE NOT EXISTS (
									SELECT td.trans_id
									FROM   #host_db_prefix_replace#translations td
									WHERE  t.trans_id = td.trans_id)
								AND    t.lang_id_r = #evaluate(l)# )">
			<cfstoredproc datasource="#variables.dsn#" procedure="#session.theoraschema#.exec_insertinto_sql">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="sqlstatement" type="in" value="#sqlStmt#">
			</cfstoredproc>
			<!--- Update all fields which have not been changed by the user (trans_changed is null) --->
			<cfquery datasource="#variables.dsn#" name="toupdate">
				SELECT dt.trans_id, dt.lang_id_r, dt.trans_text
				FROM #host_db_prefix_replace#translations dt, translations t
				WHERE dt.lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#l#">
				AND dt.trans_id = t.trans_id
				AND (dt.trans_changed IS NULL OR dt.trans_changed = '')
				GROUP BY dt.trans_id, dt.lang_id_r, dt.trans_text
			</cfquery>
			<cfoutput query="toupdate">
				<cfquery datasource="#variables.dsn#">
					UPDATE #host_db_prefix_replace#translations
					SET trans_id   = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#trans_id#">,
					lang_id_r  = <cfqueryparam cfsqltype="cf_sql_numeric" value="#l#">,
					trans_text = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#trans_text#">
					WHERE lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#l#">
					AND trans_id  = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#trans_id#">
				</cfquery>
			</cfoutput>
		</cfif>
	</cfloop> --->
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Clear database: We have to go trough here since we don't initialize the DB CFC's directly --->
<cffunction name="cleardb" output="true">
	<cfinvoke component="db_#session.firsttime.database#" method="clearall" />
	<cfreturn />
</cffunction>

</cfcomponent>