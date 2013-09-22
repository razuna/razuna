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
<cfcomponent hint="Default queries within the admin" extends="extQueryCaching">

<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("general")>

	<!--- Clearcache --->
	<cffunction name="clearcache" access="public" returntype="void">
		<!--- Reset the cache of this host --->
		<cfset resetcachetokenall()>
	</cffunction>

<!--- Get all hosts --->
	<cffunction hint="Give back all hosts" name="allhosts">
		<cfquery datasource="#application.razuna.datasource#" name="hostslist">
		SELECT host_id, host_name, host_path, host_create_date, host_db_prefix, host_lang
		FROM hosts
		ORDER BY lower(host_name)
		</cfquery>
		<cfreturn hostslist>
	</cffunction>

<!--- FUNCTION: SWITCH LANGUAGE --->
	<cffunction name="switchlang" returntype="string" access="public" output="false">
		<cfargument name="thelang" default="" required="yes" type="string">
		<!--- Set the session lang --->
		<cfset session.thelang = arguments.thelang>
		<!--- Get the lang id --->
		<cfinvoke component="defaults" method="trans" transid="thisid" thetransfile="#lcase(arguments.thelang)#" returnvariable="theid">
		<!--- Set the session lang id --->
		<cfset session.thelangid = theid>
		<cfreturn />
	</cffunction>

<!--- GET THE WISDOM TEXT --->
	<cffunction hint="GET THE WISDOM TEXT" name="wisdom" output="false">
		<cfquery datasource="#application.razuna.datasource#" name="wis">
			<!--- Oracle --->
			<cfif application.razuna.thedatabase EQ "oracle">
				SELECT wis_text, wis_author
				FROM (
					SELECT wis_text, wis_author FROM wisdom
					ORDER BY dbms_random.VALUE
					)
				WHERE ROWNUM = 1
			<!--- H2 / MySQL --->
			<cfelseif application.razuna.thedatabase EQ "mysql" OR  application.razuna.thedatabase EQ "h2">
				SELECT wis_text, wis_author
				FROM wisdom
				ORDER BY rand()
				LIMIT 1
			<!--- MSSQL --->
			<cfelseif application.razuna.thedatabase EQ "mssql">
				SELECT TOP 1 wis_text, wis_author
				FROM wisdom
				ORDER BY NEWID()
			<!--- DB2 --->
			<cfelseif application.razuna.thedatabase EQ "db2">
				SELECT wis_text, wis_author, rand()
				FROM wisdom
				ORDER BY 3
				FETCH FIRST 1 ROW ONLY
			</cfif>
		</cfquery>
		<cfreturn wis>
	</cffunction>

<!--- Get size of asset --->
	<cffunction name="getfilesize">
		<cfargument name="filepath" type="string">
		<cfset fs = createObject("java","java.io.File").init(arguments.filepath).length()>
		<cfreturn fs>
	</cffunction>
	
<!--- CONVERT BYTES TO KB/MB --------------------------------------------------------------------->
	<cffunction hint="CONVERT BYTES TO MB" name="converttomb" output="false">
		<cfargument name="thesize" default="" required="yes" type="string">
		<cfargument name="unit" default="MB" required="no" type="string">
		<!--- Set local variable --->
		<cfset var divisor = 0>
		<cfswitch expression="#arguments.unit#">
			<!--- Divide the size for KB --->
			<cfcase value="KB">
				<cfset divisor = 1024>
			</cfcase>
			<!--- Divide the size for GB --->
			<cfcase value="GB">
				<cfset divisor = 1073741824>
			</cfcase>
			<!--- Divide the size for MB --->
			<cfdefaultcase>
				<!--- <cfif #arguments.forvideo# EQ "T">
					<cfset divisor = 1000000>
				<cfelse> --->
					<cfset divisor = 1048576>
				<!--- </cfif> --->
			</cfdefaultcase>
		</cfswitch>
		<!--- Divide the size --->
		<!--- <cfif #arguments.forvideo# EQ "T">
			<cfset themb = #arguments.thesize# / divisor>
		<cfelse> --->
			<cfset themb = #arguments.thesize# / divisor>
		<!--- </cfif> --->
	
		<!--- then do the round --->
		<cfif #themb# lt 0.009>
			<cfset themb=0.01>
		<!--- <cfset themb=Round(themb)> --->
		<cfelseif #themb# lt 10>
			<cfset themb=NumberFormat(Round(themb * 100) / 100,"0.00")>
		<cfelseif #themb# lt 100>
			<cfset themb=NumberFormat(Round(themb * 10) / 10,"90.0")>
		</cfif>
	
		<cfreturn themb>
		<!--- if we ever do something else
		var bytes = 1;
		var kb = 1024;
		var mb = 1048576;
		var gb = 1073741824;
		--->
	</cffunction>

<!--- CONVERT ILLEGAL CHARS ---------------------------------------------------------------------->
	<cffunction hint="CONVERT ILLEGAL CHARS" name="convertname" output="false">
		<cfargument name="thename" required="yes" type="string">
		<!--- Detect file extension --->
		<cfinvoke component="assets" method="getFileExtension" theFileName="#thename#" returnvariable="fileNameExt">
		<cfset thefilename = "#fileNameExt.theName#">
		<!--- Convert space to an underscore --->
		<cfset thefilename = REReplaceNoCase(thefilename, " ", "_", "ALL")>
		<!--- All foreign chars are now converted, except the - --->
		<cfset thefilename = REReplaceNoCase(thefilename, "[^[:alnum:]^\-\_]", "", "ALL")>
		<!--- Danish Chars --->
		<cfset thefilename = REReplaceNoCase(thefilename, "([å]+)", "aa", "ALL")>
		<cfset thefilename = REReplaceNoCase(thefilename, "([æ]+)", "ae", "ALL")>
		<cfset thefilename = REReplaceNoCase(thefilename, "([ø]+)", "o", "ALL")>
		<!--- German Chars --->
		<cfset thefilename = REReplaceNoCase(thefilename, "([ü]+)", "ue", "ALL")>
		<cfset thefilename = REReplaceNoCase(thefilename, "([ä]+)", "ae", "ALL")>
		<cfset thefilename = REReplaceNoCase(thefilename, "([ö]+)", "oe", "ALL")>
		<!--- French Chars --->
		<cfset thefilename = REReplaceNoCase(thefilename, "([è]+)", "e", "ALL")>
		<cfset thefilename = REReplaceNoCase(thefilename, "([à]+)", "a", "ALL")>
		<cfset thefilename = REReplaceNoCase(thefilename, "([é]+)", "e", "ALL")>
		<!--- If all fails then --->
		<cfset thefilename = REReplaceNoCase(thefilename, "[^a-zA-Z0-9\-\_\s]", "", "ALL")>
		<!--- Re-add the extension to the name --->
		<cfif fileNameExt.theExt NEQ "">
			<cfset thefilename = "#thefilename#.#fileNameExt.theExt#">
		</cfif>
		<cfreturn thefilename>
	</cffunction>

<!--- GET ALL ALLOWED FILE TYPES ---------------------------------------------------------------------->
	<cffunction name="filetypes" output="false">
		<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT type_id
			FROM file_types
		</cfquery>
		<!--- Set it in a list --->
		<cfset types.list = ValueList(qry.type_id,"$|.")>
		<cfset types.lcase = "." & "#lcase(types.list)#">
		<cfset types.ucase = "." & "#ucase(types.list)#">
		<cfreturn types>
	</cffunction>

<!--- Check for plattform --->
	<cffunction name="isWindows" returntype="boolean" access="public" output="false">
		<!--- function internal variables --->
		<!--- function body --->
		<cfreturn FindNoCase("Windows", server.os.name)>
	</cffunction>

<!--- Get Sequence --->
	<cffunction name="getsequence" returntype="query" access="public" output="false">
		<cfargument name="database" type="string">
		<cfargument name="dsn" type="string">
		<cfargument name="thetable" type="string">
		<cfargument name="theid" type="string">
		<!--- Get Next number --->
		<cftransaction>
			<cfquery datasource="#arguments.dsn#" name="qryseq">
			SELECT max(#arguments.theid#)+1 AS id
			FROM #arguments.thetable#
			</cfquery>
		</cftransaction>
		<!--- Return --->
		<cfreturn qryseq>
	</cffunction>

<!--- Do the execution for imagemagick and so on --->
	<cffunction name="doexe" access="public" output="false" returntype="string">
		<cfargument name="what" type="string">
		<cfargument name="params" type="string">
		<cfargument name="destination" type="string">
		<cfargument name="dsn" type="string">
		
		<cfset var ttresizeimage = createuuid()>
		
		<cfthread name="#ttresizeimage#" intstruct="#arguments#">
		
			<!--- Query to get the settings --->
			<cfquery datasource="#attributes.intstruct.dsn#" name="qry_settings">
			SELECT set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth
			FROM #session.hostdbprefix#settings_2
			WHERE set2_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Get tools --->
			<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
			<!--- Check the platform and then decide on the different executables --->
			<cfif isWindows()>
				<cfset var theimconvert = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
				<cfset var theimcomposite = """#arguments.thestruct.thetools.imagemagick#/composite.exe""">
				<cfset var theidentify = """#arguments.thestruct.thetools.imagemagick#/identify.exe""">
				<cfset var theffmpeg = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
			<cfelse>
				<cfset var theimconvert = "#arguments.thestruct.thetools.imagemagick#/convert">
				<cfset var theimcomposite = "#arguments.thestruct.thetools.imagemagick#/composite">
				<cfset var theidentify = "#arguments.thestruct.thetools.imagemagick#/identify">
				<cfset var theffmpeg = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
			</cfif>
			<!--- Init Java Object --->
			<cfset objruntime = createObject( "java", "java.lang.Runtime").getRuntime() >
			<cfset var thenice = "nice -n +10">
			<!--- What to execute --->
			<cfif attributes.intstruct.what EQ "convert">
				<cfset var theexe = theimconvert>
			<cfelseif attributes.intstruct.what EQ "ffmpeg">
				<cfset var theexe = theffmpeg>
			</cfif>
			<!--- Put it together --->
			<cfset var thefinalexe = "#thenice# #theexe# #attributes.intstruct.params#">
			
			<!--- Execute --->
			<cfset objruntime.exec(thefinalexe)>
			
		</cfthread>
		<!--- Wait for thread --->
		<cfthread action="join" name="#ttresizeimage#" timeout="9000" />
				
		<cfloop condition="NOT fileexists('#arguments.destination#')">
			<cfset sleep(5000)>
		</cfloop>
		
		<cfreturn "done">
	</cffunction>

	<!--- Check for existing datasource in bd_config --->
	<cffunction name="checkdatasource" access="public" output="false">
		<cfinvoke component="bd_config" method="getDatasources" dsn="#session.firsttime.database#" returnVariable="thedsn" />
		<cfreturn thedsn />
	</cffunction>
	
	<!--- Check for connecting to datasource in bd_config --->
	<cffunction name="verifydatasource" access="public" output="false">
		<cfset var theconnection = false>
		<cftry>
			<cfinvoke component="bd_config" method="verifyDatasource" dsn="#session.firsttime.database#" returnVariable="theconnection" />
			<cfdump var="#theconnection#">
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfreturn theconnection />
	</cffunction>
	
	<!--- Set datasource in bd_config --->
	<cffunction name="setdatasource" access="public" output="false">
		<!--- Param --->
		<cfparam name="theconnectstring" default="">
		<cfparam name="hoststring" default="">
		<cfparam name="verificationQuery" default="">
		<cfparam name="session.firsttime.database_type" default="">
		<!--- Set the correct drivername --->
		<cfif session.firsttime.database_type EQ "h2">
			<cfset thedrivername = "org.h2.Driver">
			<cfset theconnectstring = "AUTO_RECONNECT=TRUE;CACHE_TYPE=SOFT_LRU;AUTO_SERVER=TRUE">
		<cfelseif session.firsttime.database_type EQ "mysql">
			<cfset thedrivername = "com.mysql.jdbc.Driver">
			<cfset theconnectstring = "zeroDateTimeBehavior=convertToNull">
		<cfelseif session.firsttime.database_type EQ "mssql">
			<cfset thedrivername = "net.sourceforge.jtds.jdbc.Driver">
		<cfelseif session.firsttime.database_type EQ "oracle">
			<cfset thedrivername = "oracle.jdbc.OracleDriver">
		<cfelseif session.firsttime.database_type EQ "db2">
			<cfset thedrivername = "com.ibm.db2.jcc.DB2Driver">
			<cfset hoststring = "jdbc:db2://#session.firsttime.db_server#:currentSchema=RAZUNA;">
			<cfset verificationQuery = "select 5 from sysibm.sysdummy1">
		</cfif>
		<!--- Set the datasource --->
		<cftry>
			<cfinvoke component="bd_config" method="setDatasource">
				<cfinvokeargument name="name" value="#session.firsttime.database#">
				<cfinvokeargument name="databasename" value="#session.firsttime.db_name#">
				<cfinvokeargument name="server" value="#session.firsttime.db_server#">
				<cfinvokeargument name="port" value="#session.firsttime.db_port#">
				<cfinvokeargument name="username" value="#session.firsttime.db_user#">
				<cfinvokeargument name="password" value="#session.firsttime.db_pass#">
				<cfinvokeargument name="action" value="#session.firsttime.db_action#">
				<cfinvokeargument name="existingDatasourceName" value="#session.firsttime.database#">
				<cfinvokeargument name="drivername" value="#thedrivername#">
				<cfinvokeargument name="h2Mode" value="Oracle">
				<cfinvokeargument name="connectstring" value="#theconnectstring#">
				<cfinvokeargument name="hoststring" value="#hoststring#">
				<cfinvokeargument name="verificationQuery" value="#verificationQuery#">
			</cfinvoke>
			<cfcatch type="any">
				<cfset consoleoutput(true)>
				<cfset console(cfcatch)>
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>

<!--- Send Feedback ---------------------------------------------------------------------->
	<cffunction name="send_feedback" output="false">
		<cfargument name="thestruct" type="struct">
		<cfmail to="support@razuna.com" from="server@razuna.com" replyto="#arguments.thestruct.email#" subject="Feedback from within Razuna" type="html">
Date: #now()#
<br>
From: #arguments.thestruct.author#
<br>
eMail: #arguments.thestruct.email#
<br>
URL: #arguments.thestruct.url#
<br><br>
Comment:<br>
#ParagraphFormat(arguments.thestruct.comment)#
		</cfmail>
		<cfreturn />
	</cffunction>

<!--- Get assets shared options ---------------------------------------------------------------------->
	<cffunction name="get_share_options" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Check if this is for the basket --->
		<cfif structkeyexists(arguments.thestruct,"qrybasket")>
			<cfset var qry = 0>
			<!--- Loop over basket query --->
			<cfloop query="arguments.thestruct.qrybasket">
				<cfquery datasource="#application.razuna.datasource#" name="qry_asset" cachedwithin="1" region="razcache">
				SELECT /* #variables.cachetoken#get_share_options */ asset_id_r, group_asset_id, asset_format, asset_dl, asset_order, asset_selected
				FROM #session.hostdbprefix#share_options
				WHERE group_asset_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#cart_product_id#">
				AND asset_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#cart_file_type#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Create list --->
				<cfloop query="qry_asset">
					<cfset qry = qry & asset_id_r & "-" & asset_format & "-" & asset_dl & "-" & asset_selected & ",">
				</cfloop>
			</cfloop>
		<!--- Check if this is for the widget download --->
		<cfelseif structkeyexists(arguments.thestruct,"widget_download") AND structkeyexists(arguments.thestruct,"wid")>
			<!--- Put together the value lists for quering --->
			<cfif arguments.thestruct.kind EQ "img">
				<cfset var thelist = valuelist(arguments.thestruct.qry_detail.detail.img_id) & "," & valuelist(arguments.thestruct.qry_related.img_id)>
			<cfelseif arguments.thestruct.kind EQ "vid">
				<cfset var thelist = valuelist(arguments.thestruct.qry_detail.detail.vid_id) & "," & valuelist(arguments.thestruct.qry_related.vid_id)>
			<cfelseif arguments.thestruct.kind EQ "aud">
				<cfset var thelist = valuelist(arguments.thestruct.qry_detail.detail.aud_id) & "," & valuelist(arguments.thestruct.qry_related.aud_id)>
			</cfif>
			<!--- If thelist is only a comma --->
			<cfif thelist EQ ",">
				<cfset var thelist = 0>
			</cfif>
			<!--- Query --->
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#get_share_options2 */ 
			asset_id_r, group_asset_id, asset_format, asset_dl, asset_order, asset_selected
			FROM #session.hostdbprefix#share_options
			WHERE group_asset_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thelist#" list="Yes">)
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelse>
			<!--- Query --->
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#get_share_options3 */ 
			asset_id_r, group_asset_id, asset_format, asset_dl, asset_order, asset_selected
			FROM #session.hostdbprefix#share_options
			WHERE group_asset_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

<!--- Save assets shared options ---------------------------------------------------------------------->
	<cffunction name="save_share_options" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfif arguments.thestruct.selected EQ "undefined">
			<cfset arguments.thestruct.selected = 0>
		</cfif>
		<cfif arguments.thestruct.order EQ "undefined">
			<cfset arguments.thestruct.order = 0>
		</cfif>
		<cfif arguments.thestruct.dl EQ "undefined">
			<cfset arguments.thestruct.dl = 0>
		</cfif>
		<!--- delete existing --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#share_options
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND asset_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.type#">
		AND asset_format = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.format#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Set selected to 0 --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#share_options
		SET asset_selected = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		WHERE group_asset_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		</cfquery>
		<!--- Check what the checked values are and convert --->
		<cfif arguments.thestruct.dl>
			<cfset var download = "1">
		<cfelse>
			<cfset var download = "0">
		</cfif>
		<cfif arguments.thestruct.order>
			<cfset var order = "1">
		<cfelse>
			<cfset var order = "0">
		</cfif>
		<cfif arguments.thestruct.selected>
			<cfset var selected = "1">
		<cfelse>
			<cfset var selected = "0">
		</cfif>
		<!--- Do Insert --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#share_options
		(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, asset_selected, rec_uuid)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.format#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#download#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#order#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#selected#">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		)
		</cfquery>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("general")>
		<cfreturn />
	</cffunction>

<!--- Get assets shared options ---------------------------------------------------------------------->
	<cffunction name="share_reset_dl" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfset var folderlist = "">
		<cfset var qryfiles = "">
		<!--- Get this folderid and all subfolders in a list --->
		<cfinvoke component="folders" method="recfolder" thelist="#arguments.thestruct.folder_id#" returnvariable="folderlist">
		<!--- Now loop over the folder list and do the reset --->
		<cfloop list="#folderlist#" delimiters="," index="i">
			<!--- Set i into var --->
			<cfset thefolderid = i>
			<!--- Get all the files in this folder --->
			<cfinvoke component="folders" method="getallassetsinfolder" folder_id="#i#" returnvariable="qryfiles">
			<!--- Loop over the files and update shared options --->
			<cfloop query="qryfiles">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#share_options
				SET 
				asset_dl = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.setto#">,
				folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderid#">
				WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
				AND asset_format = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="org">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#share_options
				SET 
				asset_dl = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.settothumb#">,
				folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderid#">
				WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
				AND asset_format = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="thumb">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfloop>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("files")>
		<cfset variables.cachetoken = resetcachetoken("general")>
		<!--- Return --->
		<cfreturn />
	</cffunction>

<!--- Get ALL Upload Templates ---------------------------------------------------------------------->
	<cffunction name="upl_templates" output="false">
		<cfargument name="theactive" type="boolean" required="false" default="false">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT upl_temp_id, upl_active, upl_name, upl_description
		FROM #session.hostdbprefix#upload_templates
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif arguments.theactive>
			AND upl_active = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
		</cfif>
		</cfquery>
		<cfreturn qry />
	</cffunction>

<!--- Remove Upload Templates ---------------------------------------------------------------------->
	<cffunction name="upl_templates_remove" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#upload_templates
		WHERE upl_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#upload_templates_val
		WHERE upl_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfreturn  />
	</cffunction>

<!--- Get DETAILED Upload Templates ---------------------------------------------------------------------->
	<cffunction name="upl_template_detail" output="false">
		<cfargument name="upl_temp_id" type="string" required="true">
		<!--- New struct --->
		<cfset var qry = structnew()>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.upl">
		SELECT upl_who, upl_active, upl_name, upl_description
		FROM #session.hostdbprefix#upload_templates
		WHERE upl_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.upl_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Query values --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.uplval">
		SELECT upl_temp_field, upl_temp_value, upl_temp_type, upl_temp_format
		FROM #session.hostdbprefix#upload_templates_val
		WHERE upl_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.upl_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>
	
<!--- Save Upload Templates ---------------------------------------------------------------------->
	<cffunction name="upl_template_save" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfparam name="arguments.thestruct.upl_active" default="0">
		<cfparam name="arguments.thestruct.convert_to" default="">
		<!--- Delete all records with this ID in the MAIN DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#upload_templates
		WHERE upl_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_temp_id#">
		</cfquery>
		<!--- Save to main DB --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#upload_templates
		(upl_temp_id, upl_date_create, upl_date_update, upl_who, upl_active, host_id, upl_name, upl_description)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_temp_id#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_active#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_name#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_description#">
		)
		</cfquery>
		<!--- Delete all records with this ID in the DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#upload_templates_val
		WHERE upl_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_temp_id#">
		</cfquery>
		<!--- Check which format to convert to. The selected ones we have to get values --->
		<cfloop list="#arguments.thestruct.convert_to#" index="i">
			<!--- Get the file type and the format --->
			<cfset thetype = listfirst(i,"-")>
			<cfset theformat = listlast(i,"-")>
			<!--- Save the convert to --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#upload_templates_val
			(upl_temp_id_r, upl_temp_field, upl_temp_value, upl_temp_type, upl_temp_format, host_id, rec_uuid)
			VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_temp_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="convert_to">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theformat#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thetype#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theformat#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
			<!--- Save the additional values --->
			<cfloop collection="#arguments.thestruct#" item="col">
				<cfif col EQ "convert_bitrate_#theformat#" OR col EQ "convert_height_#theformat#" OR col EQ "convert_width_#theformat#" OR col EQ "convert_dpi_#theformat#" OR col EQ "convert_wm_#theformat#">
					<cfset tf = lcase(col)>
					<cfset tv = evaluate(tf)>
					<cfif tv NEQ "">
						<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#upload_templates_val
						(upl_temp_id_r, upl_temp_field, upl_temp_value, upl_temp_type, upl_temp_format, host_id, rec_uuid)
						VALUES(
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_temp_id#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#tf#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#tv#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thetype#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theformat#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
						<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
						)
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>	
		</cfloop>
		<cfreturn />
	</cffunction>

<!--- Query additional versions link ---------------------------------------------------------------------->
	<cffunction name="get_versions_link" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("general")>
		<!--- Param --->
		<cfset var qry = structnew()>
		<!--- Query links --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.links" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#get_versions_link */ av_id, av_link_title, av_link_url
		FROM #session.hostdbprefix#additional_versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_link = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
		</cfquery>
		<!--- Query links --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.assets" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#get_versions_link2 */ av_id, av_link_title, av_link_url, thesize, thewidth, theheight, av_type, hashtag
		FROM #session.hostdbprefix#additional_versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_link = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		</cfquery>
		<cfreturn qry />
	</cffunction>

<!--- Save new additional versions link ---------------------------------------------------------------------->
	<cffunction name="save_add_versions_link" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfparam name="arguments.thestruct.av_link" default="1">
		<cfparam name="arguments.thestruct.thesize" default="0">
		<cfparam name="arguments.thestruct.thewidth" default="0">
		<cfparam name="arguments.thestruct.theheight" default="0">
		<cfparam name="arguments.thestruct.md5hash" default="">
		<!--- Save --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#additional_versions
		(av_id, av_link_title, av_link_url, asset_id_r, folder_id_r, host_id, av_type, av_link, thesize, thewidth, theheight, hashtag)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#createuuid("")#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_link_title#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_link_url#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_link#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.thesize#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.thewidth#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.theheight#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.md5hash#">
		)
		</cfquery>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("general")>
		<cfreturn />
	</cffunction>

<!--- Remove versions link ---------------------------------------------------------------------->
	<cffunction name="remove_av_link" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#additional_versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		</cfquery>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("general")>
		<cfreturn />
	</cffunction>

<!--- getav ---------------------------------------------------------------------->
	<cffunction name="getav" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT av_link_title, av_link_url, av_link
		FROM #session.hostdbprefix#additional_versions
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_id#">
		</cfquery>
		<cfreturn qry />
	</cffunction>

<!--- Update AV ---------------------------------------------------------------------->
	<cffunction name="updateav" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#additional_versions
		SET
		av_link_title = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_link_title#">
		<cfif arguments.thestruct.av_link EQ 1>
			,
			av_link_url = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_link_url#">
		</cfif>
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_id#">
		</cfquery>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("general")>
		<cfreturn />
	</cffunction>
	
	<!--- GET RECORDS WITH EMTPY VALUES --->
	<cffunction name="checkassets" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfset var foundsome = false>
		<cfset var theids = "">
		<!--- Feedback --->
		<cfoutput><strong>Starting the Clean up process...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Query --->
		<cfif arguments.thestruct.thetype EQ "img">
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT
			folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
			path_to_asset, lucene_key, thumb_extension, img_id id, img_filename filename, img_filename_org filenameorg
			FROM #session.hostdbprefix#images
			WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif arguments.thestruct.thetype EQ "vid">
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT
			folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
			path_to_asset, lucene_key, vid_name_image, vid_id id, vid_filename filename, vid_name_org filenameorg
			FROM #session.hostdbprefix#videos
			WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif arguments.thestruct.thetype EQ "aud">
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT
			folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
			path_to_asset, lucene_key, aud_id id, aud_name filename, aud_name_org filenameorg
			FROM #session.hostdbprefix#audios
			WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif arguments.thestruct.thetype EQ "doc">
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT
			folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
			path_to_asset, lucene_key, file_id id, file_name filename, file_name_org filenameorg
			FROM #session.hostdbprefix#files
			WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- Feedback --->
		<cfoutput><strong>You have #qry.recordcount# records. We are starting to check each record now...</strong><br><br>Below you will find records that are missing the asset on the filesytem. Tip: If you want to remove all at once scroll down to the bottom.<br /><br /></cfoutput>
		<cfflush>
		<!--- Local --->
		<cfif application.razuna.storage EQ "local">
			<cfloop query="qry">
				<!--- Checking message --->
				<cfoutput>Checking: #filename#...<br></cfoutput>
				<cfflush>
				<!--- Check Original --->
				<cfif NOT fileexists("#arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#/#filenameorg#")>
					<cfset foundsome = true>
					<cfset theids = theids & "," & id>
					<cfoutput><strong style="color:red;">Missing Original Asset: #filename#</strong><br>We checked at: #arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#/#filenameorg#<br />
					<a href="index.cfm?fa=c.admin_cleaner_check_asset_delete&id=#id#&thetype=#arguments.thestruct.thetype#" target="_blank">Remove this asset in the database</a><br />
					<cfif arguments.thestruct.thetype EQ "doc"><br /></cfif>
					</cfoutput>
					<cfflush>
				</cfif>
				<!--- Check thumbnail --->
				<cfif arguments.thestruct.thetype EQ "img" OR arguments.thestruct.thetype EQ "vid">
					<cfif arguments.thestruct.thetype EQ "img">
						<cfset pathtocheck = "#arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#/thumb_#id#.#thumb_extension#">
					<cfelseif arguments.thestruct.thetype EQ "vid">
						<cfset pathtocheck = "#arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#/#vid_name_image#">
					</cfif>
					<cfif NOT fileexists("#pathtocheck#")>
						<cfset foundsome = true>
						<cfoutput><strong style="color:red;">Missing Thumbnail: #filename#</strong><br>We checked at: #pathtocheck#<br /><br />
						</cfoutput>
						<cfflush>
					</cfif>
				</cfif>
			</cfloop>
		<!--- Cloud --->
		<cfelseif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			<cfloop query="qry">
				<cfif cloud_url_org NEQ "">
					<!--- Checking message --->
					<cfoutput>Checking: #filename#...<br></cfoutput>
					<cfflush>
					<!--- Check Original --->
					<cfif cloud_url_org DOES NOT CONTAIN "://">
						<cfset cfhttp.responseheader.status_code = 500>
					<cfelse>
						<cfhttp url="#cloud_url_org#" />
					</cfif>
					<cfif cfhttp.responseheader.status_code NEQ 200>
						<cfset foundsome = true>
						<cfset theids = theids & "," & id>
						<cfoutput><strong style="color:red;">Missing Original Asset: #filename#</strong><br>We checked at: #cloud_url_org#<br />
						<a href="index.cfm?fa=c.admin_cleaner_check_asset_delete&id=#id#&thetype=#arguments.thestruct.thetype#" target="_blank">Remove this asset in the database</a><br />
						<cfif arguments.thestruct.thetype EQ "doc"><br /></cfif>
						</cfoutput>
						<cfflush>
					</cfif>
					<!--- Check thumbnail --->
					<cfif arguments.thestruct.thetype EQ "img" OR arguments.thestruct.thetype EQ "vid">
						<cfif cloud_url NEQ "">
							<cfif cloud_url DOES NOT CONTAIN "://">
								<cfset cfhttp.responseheader.status_code = 500>
							<cfelse>
								<cfhttp url="#cloud_url#" />
							</cfif>
							<cfif cfhttp.responseheader.status_code NEQ 200>
								<cfset foundsome = true>
								<cfoutput><strong style="color:red;">Missing Thumbnail: #filename#</strong><br>We checked at: #cloud_url#<br />
								</cfoutput>
								<cfflush>
							</cfif>
						</cfif>
					</cfif>
				<!--- If cloud url org is empty we display message --->
				<cfelse>
					<cfset foundsome = true>
					<cfset theids = theids & "," & id>
					<cfoutput><strong style="color:red;">Missing Original Asset: #filename#</strong><br />
					<a href="index.cfm?fa=c.admin_cleaner_check_asset_delete&id=#id#&thetype=#arguments.thestruct.thetype#" target="_blank">Remove this asset in the database</a><br />
					<cfif arguments.thestruct.thetype EQ "doc"><br /></cfif>
					</cfoutput>
					<cfflush>
				</cfif>
			</cfloop>
		</cfif>
		<!--- Feedback --->
		<cfif foundsome>
			<cfoutput><br /><strong>Looks like some assets are missing on the system.</strong><br /><br /></cfoutput>
			<cfflush>
			You can remove all the asset above with one single click below. Note: This will remove the assets from the database and the search index.<br />
			<cfoutput>
			<form action="index.cfm" method="post">
				<input type="hidden" name="fa" value="c.admin_cleaner_check_asset_delete" />
				<input type="hidden" name="id" value="#theids#" />
				<input type="hidden" name="thetype" value="#arguments.thestruct.thetype#" />
				<input type="submit" value="Remove above assets" name="submitbutton" class="button" />
			</form>
			</cfoutput>
		<cfelse>
			<cfoutput><br /><strong style="color:green;">Awesome. All looks stylish and clean. Rock on.</strong><br><br></cfoutput>
			<cfflush>
		</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>
	
	<!--- Call Account --->
	<cffunction name="getaccount" output="true">
		<cfargument name="thehostid" type="string" required="true">
		<cfargument name="thecgi" type="string" required="false">
		<!--- Params --->
		<cfset var account = "">
		<cfset var qry = "">
		<!--- Call Remote CFC --->
		<!--- <cfhttp url="http://razuna.com/includes/accounts.cfc">
			<cfhttpparam type="url" name="method" value="checkaccount" />
			<cfhttpparam type="url" name="thehostid" value="#arguments.thehostid#" />
		</cfhttp> --->
		<!--- Convert WDDX --->
		<!--- <cfwddx action="wddx2cfml" input="#cfhttp.filecontent#" output="account" /> --->
		<cfquery datasource="razuna_account" name="account" region="razcache" cachedwithin="#CreateTimeSpan(0,0,10,0)#">
		SELECT /* #arguments.thehostid# */ account_type
		FROM hosted_users
		WHERE host_id = <cfqueryparam value="#arguments.thehostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfquery datasource="razuna_account" name="qry" region="razcache" cachedwithin="#CreateTimeSpan(0,0,10,0)#">
		SELECT /* #arguments.thehostid# */ b.bill_id, b.bill_date, b.bill_total, u.user_id, u.account_type
		FROM hosted_bills b, hosted_users u
		WHERE u.host_id = <cfqueryparam value="#arguments.thehostid#" cfsqltype="cf_sql_numeric" />
		AND b.user_id = u.user_id
		and lower(b.bill_paid) = <cfqueryparam value="f" cfsqltype="cf_sql_varchar" />
		and b.reminder_count > 1
		</cfquery>
		<!--- If there is a record then the user is in debt --->
		<cfif qry.recordcount NEQ 0>
			<cfset session.indebt = true>
		<cfelse>
			<cfset session.indebt = false>
		</cfif>
		<cfif Request.securityObj.CheckSystemAdminUser()>
			<cfset session.indebt = false>
		</cfif>
		<!--- Return --->
		<cfreturn account>
	</cffunction>
	
	<!--- Rebuild URL --->
	<cffunction name="rebuildurl" output="true">
		<cfargument name="thestruct" type="struct">
		<cfargument name="assetid" type="string" required="false" default="0">
		<!--- Feedback --->
		<cfoutput><strong>Fetching images...</strong><br /><br /></cfoutput>
		<cfflush>
		<!--- Query images --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT img_id, path_to_asset, img_filename_org, thumb_extension
		FROM #session.hostdbprefix#images
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Feedback --->
		<cfoutput>#qry.recordcount# images found. Creating URL's now. Hold on...<br /><br /></cfoutput>
		<cfflush>
		<!--- Loop over images and redo the urls --->
		<cfloop query="qry">
			<!--- Feedback --->
			<cfoutput>. </cfoutput>
			<cfflush>
			<!--- put thumbnail path together --->
			<cfset t = path_to_asset & "/thumb_" & img_id & "." & thumb_extension>
			<!--- put org name together --->
			<cfset a = path_to_asset & "/" & img_filename_org>
			<!--- Nirvanix or Amazon --->
			<cfif application.razuna.storage EQ "nirvanix">
				<!--- Get signed URLS for thumb --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#t#" nvxsession="#arguments.thestruct.nvxsession#">
				<!--- Get signed URLS original --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#a#" nvxsession="#arguments.thestruct.nvxsession#">
			<cfelse>
				<!--- Get signed URLS for thumb --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#t#" awsbucket="#arguments.thestruct.awsbucket#">
				<!--- Get signed URLS original --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#a#" awsbucket="#arguments.thestruct.awsbucket#">
			</cfif>
			<!--- Update to DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images
			SET 
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">				
			WHERE img_id = <cfqueryparam value="#img_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><strong>Done with images!</strong><br /><br /></cfoutput>
		<cfflush>
		<!--- Feedback --->
		<cfoutput><strong>Fetching videos...</strong><br /><br /></cfoutput>
		<cfflush>
		<!--- Query images --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT vid_id, path_to_asset, vid_name_org, vid_name_image
		FROM #session.hostdbprefix#videos
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Feedback --->
		<cfoutput>#qry.recordcount# videos found. Creating URL's now. Hold on...<br /><br /></cfoutput>
		<cfflush>
		<!--- Loop and redo the urls --->
		<cfloop query="qry">
			<!--- Feedback --->
			<cfoutput>. </cfoutput>
			<cfflush>
			<!--- put thumbnail path together --->
			<cfset t = path_to_asset & "/" & vid_name_image>
			<!--- put org name together --->
			<cfset a = path_to_asset & "/" & vid_name_org>
			<!--- Nirvanix or Amazon --->
			<cfif application.razuna.storage EQ "nirvanix">
				<!--- Get signed URLS for thumb --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#t#" nvxsession="#arguments.thestruct.nvxsession#">
				<!--- Get signed URLS original --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#a#" nvxsession="#arguments.thestruct.nvxsession#">
			<cfelse>
				<!--- Get signed URLS for thumb --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#t#" awsbucket="#arguments.thestruct.awsbucket#">
				<!--- Get signed URLS original --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#a#" awsbucket="#arguments.thestruct.awsbucket#">
			</cfif>
			<!--- Update to DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#videos
			SET 
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">				
			WHERE vid_id = <cfqueryparam value="#vid_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><strong>Done with videos!</strong><br /><br /></cfoutput>
		<cfflush>
		<!--- Feedback --->
		<cfoutput><strong>Fetching audios...</strong><br /><br /></cfoutput>
		<cfflush>
		<!--- Query images --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT aud_id, path_to_asset, aud_name_org, aud_extension, aud_name_noext
		FROM #session.hostdbprefix#audios
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Feedback --->
		<cfoutput>#qry.recordcount# audios found. Creating URL's now. Hold on...<br /><br /></cfoutput>
		<cfflush>
		<!--- Loop and redo the urls --->
		<cfloop query="qry">
			<!--- Feedback --->
			<cfoutput>. </cfoutput>
			<cfflush>
			<!--- put thumbnail path together --->
			<cfset t = path_to_asset & "/" & aud_name_noext & ".wav">
			<!--- put org name together --->
			<cfset a = path_to_asset & "/" & aud_name_org>
			<!--- Nirvanix or Amazon --->
			<cfif application.razuna.storage EQ "nirvanix">
				<!--- Get signed URLS for thumb --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#t#" nvxsession="#arguments.thestruct.nvxsession#">
				<!--- Get signed URLS original --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#a#" nvxsession="#arguments.thestruct.nvxsession#">
			<cfelse>
				<!--- Get signed URLS for thumb --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#t#" awsbucket="#arguments.thestruct.awsbucket#">
				<!--- Get signed URLS original --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#a#" awsbucket="#arguments.thestruct.awsbucket#">
			</cfif>
			<!--- Update to DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#audios
			SET 
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">				
			WHERE aud_id = <cfqueryparam value="#aud_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><strong>Done with audios!</strong><br /><br /></cfoutput>
		<cfflush>
		<!--- Feedback --->
		<cfoutput><strong>Fetching files...</strong><br /><br /></cfoutput>
		<cfflush>
		<!--- Query images --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT file_id, path_to_asset, file_extension, file_name_org, file_name_noext
		FROM #session.hostdbprefix#files
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Feedback --->
		<cfoutput>#qry.recordcount# files found. Creating URL's now. Hold on...<br /><br /></cfoutput>
		<cfflush>
		<!--- Loop and redo the urls --->
		<cfloop query="qry">
			<!--- Feedback --->
			<cfoutput>. </cfoutput>
			<cfflush>
			<!--- put thumbnail path together --->
			<cfset t = path_to_asset & "/" & file_name_noext & ".jpg">
			<!--- put org name together --->
			<cfset a = path_to_asset & "/" & file_name_org>
			<!--- Nirvanix or Amazon --->
			<cfif application.razuna.storage EQ "nirvanix">
				<!--- Get signed URLS for thumb --->
				<cfif file_extension EQ "pdf">
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#t#" nvxsession="#arguments.thestruct.nvxsession#">
				</cfif>
				<!--- Get signed URLS original --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#a#" nvxsession="#arguments.thestruct.nvxsession#">
			<cfelse>
				<!--- Get signed URLS for thumb --->
				<cfif file_extension EQ "pdf">
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#t#" awsbucket="#arguments.thestruct.awsbucket#">
				</cfif>
				<!--- Get signed URLS original --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#a#" awsbucket="#arguments.thestruct.awsbucket#">
			</cfif>
			<!--- Update to DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#files
			SET 
			<cfif file_extension EQ "pdf">
				cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			</cfif>
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">				
			WHERE file_id = <cfqueryparam value="#file_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><strong>Done with files!</strong><br /><br /></cfoutput>
		<cfflush>
		<!--- Feedback --->
		<cfoutput><strong style="color:green;">All files have new been proccessed successfully. You can close this window now.</strong><br /><br /></cfoutput>
		<cfflush>
	</cffunction>
	
	<!--- Update dates --->
	<cffunction name="update_dates" output="false" returntype="void">
		<cfargument name="type" required="true" type="string">
		<cfargument name="fileid" required="true" type="string">
		<!--- Only if certain type --->
		<cfif arguments.type EQ "img" OR arguments.type EQ "vid" OR arguments.type EQ "aud" OR arguments.type EQ "doc">
			<!--- Params --->
			<cfif arguments.type EQ "img">
				<cfset var thedb = "images">
				<cfset var theid = "img_id">
				<cfset var d1 = "img_change_date">
				<cfset var d2 = "img_change_time">
				<!--- Flush --->
				<cfset resetcachetoken("images")>
			<cfelseif arguments.type EQ "vid">
				<cfset var thedb = "videos">
				<cfset var theid = "vid_id">
				<cfset var d1 = "vid_change_date">
				<cfset var d2 = "vid_change_time">
				<!--- Flush --->
				<cfset resetcachetoken("videos")>
			<cfelseif arguments.type EQ "aud">
				<cfset var thedb = "audios">
				<cfset var theid = "aud_id">
				<cfset var d1 = "aud_change_date">
				<cfset var d2 = "aud_change_time">
				<!--- Flush --->
				<cfset resetcachetoken("audios")>
			<cfelseif arguments.type EQ "doc">
				<cfset var thedb = "files">
				<cfset var theid = "file_id">
				<cfset var d1 = "file_change_date">
				<cfset var d2 = "file_change_time">
				<!--- Flush --->
				<cfset resetcachetoken("files")>
			</cfif>
			<!--- Update DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix##thedb#
			SET 
			#d1# = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
			#d2# = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			WHERE #theid# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			</cfquery>
		</cfif>
	</cffunction>

	<!--- Watermark Templates --->
	<cffunction name="getWMTemplates" output="false">
		<cfargument name="theactive" type="boolean" required="false" default="false">
		<!--- Query --->
		<cfquery dataSource="#application.razuna.datasource#" name="qry">
		SELECT wm_temp_id, wm_active, wm_name
		FROM #session.hostdbprefix#wm_templates
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif arguments.theactive>
			AND wm_active = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="true">
		</cfif>
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Get watermark templates ---------------------------------------------------------------------->
	<cffunction name="getWMtemplatedetail" output="false" access="remote" returnformat="JSON">
		<cfargument name="wm_temp_id" type="string" required="true">
		<cfargument name="thedns" type="string" required="false" default="">
		<cfargument name="thehostid" type="string" required="false" default="">
		<!--- Since we can call this from external sources --->
		<cfif arguments.thedns NEQ "">
			<cfset application.razuna.datasource = arguments.thedns>
			<cfset session.hostid = arguments.thehostid>
		</cfif>
		<!--- New struct --->
		<cfset var qry = structnew()>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.wm">
		SELECT wm_active, wm_name
		FROM #session.hostdbprefix#wm_templates
		WHERE wm_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.wm_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Query values --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.wmval">
		SELECT wm_use_image, wm_use_text, wm_image_opacity, wm_text_opacity, wm_image_position, wm_text_position, 
		wm_text_content, wm_text_font, wm_text_font_size, wm_image_path
		FROM #session.hostdbprefix#wm_templates_val
		WHERE wm_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.wm_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- If certain values are empty --->
		<cfif qry.wm.recordcount EQ 0>
			<cfset queryAddRow(qry.wm)>
			<cfset querySetCell(qry.wm, "wm_active", false)>
		</cfif>
		<cfif qry.wmval.recordcount EQ 0>
			<cfset queryAddRow(qry.wmval)>
			<cfset querySetCell(qry.wmval, "wm_use_image", false)>
			<cfset querySetCell(qry.wmval, "wm_use_text", false)>
		</cfif>
		<!--- Get tools --->
		<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
		<!--- Check the platform and then decide on the different executables --->
		<cfif isWindows()>
			<cfset var theimconvert = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
		<cfelse>
			<cfset var theimconvert = "#arguments.thestruct.thetools.imagemagick#/convert">
		</cfif>
		<!--- Get installed fonts and create list --->	
		<cfexecute name="#theimconvert#" arguments="-list font" variable="x" timeout="60" />
		<!--- Loops over result and grab the path to the XML --->
		<cfloop list="#x#" delimiters=" " index="i">
			<cfif i CONTAINS ".xml">
				<cfset thepath = trim(i)>
			</cfif>
		</cfloop>
		<!--- Parse XML --->
		<cffile action="read" file="#thepath#" variable="thexml" />
		<cfset var x = xmlParse(thexml)>
		<cfset var thexml = xmlSearch(x, "//typemap/type/")>
		<cfset var fontlist = "">
		<!--- Loop over XML and create list --->
		<cfloop array="#thexml#" index="f">
			<cfset fontlist = fontlist & "," & f[1].xmlAttributes.fullname & ":" & f[1].xmlAttributes.name>
		</cfloop>
		<!--- Set local fontlist into struct --->
		<cfset qry.fontlist = fontlist>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Save watermark templates ---------------------------------------------------------------------->
	<cffunction name="setWMtemplate" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfparam name="arguments.thestruct.wm_active" default="false">
		<cfparam name="arguments.thestruct.wm_use_image" default="false">
		<cfparam name="arguments.thestruct.wm_use_text" default="false">
		<!--- Delete record --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#wm_templates
		WHERE wm_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#wm_templates_val
		WHERE wm_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Add record --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#wm_templates
		(wm_temp_id, wm_name, wm_active, host_id)
		VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_temp_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_name#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_active#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		)
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#wm_templates_val
		(wm_temp_id_r, wm_use_image, wm_use_text, wm_image_opacity, wm_text_opacity, wm_image_position, wm_text_position, wm_text_content, wm_text_font, wm_text_font_size, wm_image_path, host_id, rec_uuid)
		VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_temp_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_use_image#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_use_text#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_image_opacity#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_text_opacity#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_image_position#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_text_position#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_text_content#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_text_font#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_text_font_size#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.wm_image_path#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#createUUID()#">
		)
		</cfquery>
	</cffunction>

	<!--- Remove Watermark Templates --->
	<cffunction name="removewmtemplate" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Delete record --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#wm_templates
		WHERE wm_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#wm_templates_val
		WHERE wm_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Remove the files on disk --->
		<cftry>
			<cfdirectory action="delete" directory="#arguments.thestruct.thepathup#global/host/watermark/#session.hostid#/#arguments.thestruct.id#" recurse="true" />
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cffunction>

	<!--- directorycopy --->
	<cffunction name="directorycopy" output="false" hint="copy newhost dir">
		<cfargument name="source" required="true" type="string">
		<cfargument name="destination" required="true" type="string">
		<cfargument name="fileaction" required="false" type="string" default="copy">
		<cfargument name="directoryaction" required="false" type="string" default="copy">
		<cfargument name="directoryrecursive" required="false" type="string" default="false">
		<!--- Param --->
		<cfset var contents = "" />
		<!--- Create the new directory if it does not exists --->
		<cfif !directoryExists(arguments.destination)>
			<cfdirectory action="create" directory="#arguments.destination#" mode="775">
		</cfif>
		<!--- List content --->
		<cfdirectory action="list" directory="#arguments.source#" name="contents">
		<!--- Filter content --->
		<cfquery dbtype="query" name="contents">
		SELECT *
		FROM contents
		WHERE size != 0
		AND attributes != 'H'
		AND name != 'thumbs.db'
		AND name NOT LIKE '.DS_STORE%'
		AND name NOT LIKE '__MACOSX%'
		AND name NOT LIKE '%scheduleduploads_%'
		AND name != '.svn'
		AND name != '.git'
		ORDER BY name
		</cfquery>
		<!--- Loop --->
		<cfoutput query="contents" startrow="1" maxrows="200">
			<!--- Files --->
			<cfif type EQ "file">
				<cfif fileexists("#arguments.source#/#name#")>
					<cffile action="#arguments.fileaction#" source="#arguments.source#/#name#" destination="#arguments.destination#/#name#" mode="775">
				</cfif>
			<!--- Dirs but only if we recursive option is true --->
			<cfelseif type EQ "dir" AND arguments.directoryrecursive>
				<!--- For copy --->
				<cfif arguments.directoryaction EQ "copy">
					<cfset directoryCopy(source=arguments.source & "/" & name, destination=arguments.destination & "/" & name, fileaction=arguments.fileaction, directoryaction=arguments.directoryaction, directoryrecursive=arguments.directoryrecursive) />
				<!--- For Move --->
				<cfelse>
					<cfdirectory action="rename" directory="#arguments.source#/#name#" newdirectory="#arguments.destination#/#name#" mode="775" />
				</cfif>
			</cfif>
		</cfoutput>
		<cfreturn />
	</cffunction>

</cfcomponent>