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
<cfcomponent hint="Default queries within the admin">

<!--- FUNCTION: INIT --->
	<cffunction name="init" returntype="global" access="public" output="false">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="database" type="string" required="yes" />
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.database = arguments.database />
		<cfreturn this />
	</cffunction>

<!--- Get all hosts --->
	<cffunction hint="Give back all hosts" name="allhosts">
		<cfquery datasource="#variables.dsn#" name="hostslist">
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
		<cfset session.thelang = #lcase(arguments.thelang)#>
		<!--- Get the lang id --->
		<cfinvoke component="defaults" method="trans" transid="thisid" thetransfile="#lcase(arguments.thelang)#.xml" returnvariable="theid">
		<!--- Set the session lang id --->
		<cfset session.thelangid = #theid#>
		<cfreturn />
	</cffunction>

<!--- GET THE WISDOM TEXT --->
	<cffunction hint="GET THE WISDOM TEXT" name="wisdom" output="false">
		<cfquery datasource="#variables.dsn#" name="wis" cachename="#session.hostid#wisdom" cachedomain="global">
			<!--- Oracle --->
			<cfif variables.database EQ "oracle">
				SELECT wis_text, wis_author
				FROM (
					SELECT wis_text, wis_author FROM wisdom
					ORDER BY dbms_random.VALUE
					)
				WHERE ROWNUM = 1
			<!--- H2 / MySQL --->
			<cfelseif variables.database EQ "mysql" OR  variables.database EQ "h2">
				SELECT wis_text, wis_author
				FROM wisdom
				ORDER BY rand()
				LIMIT 1
			<!--- MSSQL --->
			<cfelseif variables.database EQ "mssql">
				SELECT TOP 1 wis_text, wis_author
				FROM wisdom
				ORDER BY NEWID()
			<!--- DB2 --->
			<cfelseif variables.database EQ "db2">
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
		<cfargument name="thesize" default="" required="yes" type="numeric">
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
		<cfargument name="thename" default="" required="yes" type="string">
		<!--- Detect file extension --->
		<cfinvoke component="assets" method="getFileExtension" theFileName="#thename#" returnvariable="fileNameExt">
		<cfset thefilename = "#fileNameExt.theName#">
		<!--- Convert any alphanumeric character, plus the underscore --->
		<!--- All foreign chars are now converted, except the - --->
		<cfset thefilename = REReplace(thefilename, "([^[:word:]^-]+)", "_", "ALL")>
		<!--- <cfdump var="#thefilename#"> --->
		<!--- Convert any special alphanumeric character, except the - --->
		<cfset thefilename = REReplace(thefilename, "([^A-Za-z0-9_-]+)", "_", "ALL")>
		<!--- <cfdump var="#thefilename#"> --->
		<!--- Re-add the extension to the name --->
		<cfif #fileNameExt.theExt# NEQ "">
			<cfset thefilename = "#thefilename#.#fileNameExt.theExt#">
		</cfif>
		<cfreturn lcase(thefilename)>
	</cffunction>

<!--- GET ALL ALLOWED FILE TYPES ---------------------------------------------------------------------->
	<cffunction name="filetypes" output="false">
		<cfquery datasource="#variables.dsn#" name="qry">
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
			<!---
			<cfquery datasource="#arguments.dsn#">
			UPDATE sequences
			SET thevalue = <cfqueryparam value="#qryseq.id#" cfsqltype="cf_sql_numeric">
			WHERE lower(theid) = <cfqueryparam value="#arguments.theid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			--->
		</cftransaction>
		<!--- Flush Cache
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_log" /> --->
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
		
		
		<!--- <cfpause interval="10" /> --->
		
		<cfloop condition="NOT fileexists('#arguments.destination#')">
			<cfpause interval="5" />
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
		<cfinvoke component="bd_config" method="verifyDatasource" dsn="#session.firsttime.database#" returnVariable="theconnection" />
		<cfreturn theconnection />
	</cffunction>
	
	<!--- Set datasource in bd_config --->
	<cffunction name="setdatasource" access="public" output="false">
		<!--- Param --->
		<cfparam name="theconnectstring" default="">
		<cfparam name="hoststring" default="">
		<cfparam name="verificationQuery" default="">
		<!--- Set the correct drivername --->
		<cfif session.firsttime.database EQ "h2">
			<cfset thedrivername = "org.h2.Driver">
			<cfset theconnectstring = "AUTO_RECONNECT=TRUE;CACHE_TYPE=SOFT_LRU;AUTO_SERVER=TRUE">
		<cfelseif session.firsttime.database EQ "mysql">
			<cfset thedrivername = "com.mysql.jdbc.Driver">
			<cfset theconnectstring = "zeroDateTimeBehavior=convertToNull">
		<cfelseif session.firsttime.database EQ "mssql">
			<cfset thedrivername = "net.sourceforge.jtds.jdbc.Driver">
		<cfelseif session.firsttime.database EQ "oracle">
			<cfset thedrivername = "oracle.jdbc.OracleDriver">
		<cfelseif session.firsttime.database EQ "db2">
			<cfset thedrivername = "com.ibm.db2.jcc.DB2Driver">
			<cfset hoststring = "jdbc:db2://#session.firsttime.db_server#:currentSchema=RAZUNA;">
			<cfset verificationQuery = "select 5 from sysibm.sysdummy1">
		</cfif>
		<!--- Set the datasource --->
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
			<cfloop query="arguments.thestruct.qrybasket" cachename="gs#session.hostid##cart_product_id##cart_file_type#" cachedomain="#session.theuserid#_share_options">
				<cfquery datasource="#application.razuna.datasource#" name="qry_asset">
				SELECT asset_id_r, group_asset_id, asset_format, asset_dl, asset_order, asset_selected
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
		<cfelseif structkeyexists(arguments.thestruct,"widget_download")>
			<!--- Put together the value lists for quering --->
			<cfif arguments.thestruct.kind EQ "img">
				<cfset var thelist = valuelist(arguments.thestruct.qry_detail.detail.img_id) & "," & valuelist(arguments.thestruct.qry_related.img_id)>
			<cfelseif arguments.thestruct.kind EQ "vid">
				<cfset var thelist = valuelist(arguments.thestruct.qry_detail.detail.vid_id) & "," & valuelist(arguments.thestruct.qry_related.vid_id)>
			<cfelseif arguments.thestruct.kind EQ "aud">
				<cfset var thelist = valuelist(arguments.thestruct.qry_detail.detail.aud_id) & "," & valuelist(arguments.thestruct.qry_related.aud_id)>
			</cfif>
			<!--- Query --->
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="gs#session.hostid##thelist#" cachedomain="#session.theuserid#_share_options">
			SELECT asset_id_r, group_asset_id, asset_format, asset_dl, asset_order, asset_selected
			FROM #session.hostdbprefix#share_options
			WHERE group_asset_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thelist#" list="Yes">)
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelse>
			<!--- Query --->
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="gs#session.hostid##arguments.thestruct.file_id#" cachedomain="#session.theuserid#_share_options">
			SELECT asset_id_r, group_asset_id, asset_format, asset_dl, asset_order, asset_selected
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
		(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, asset_selected)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.format#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#download#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#order#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#selected#">
		)
		</cfquery>
		<!--- Flush Cache --->
		<cfinvoke method="clearcache" theaction="flushall" thedomain="#session.theuserid#_share_options" />
		<cfreturn />
	</cffunction>

<!--- Get assets shared options ---------------------------------------------------------------------->
	<cffunction name="share_reset_dl" output="false">
		<cfargument name="thestruct" type="struct">
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#share_options
		SET asset_dl = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.setto#">
		WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Flush Cache --->
		<cfinvoke method="clearcache" theaction="flushall" thedomain="#session.theuserid#_share_options" />
		<!--- Return --->
		<cfreturn />
	</cffunction>

<!--- Clear Cache ---------------------------------------------------------------------->
	<cffunction name="clearcache" output="false">
		<cfargument name="theaction" type="string" required="true">
		<cfargument name="thename" type="string" required="false">
		<cfargument name="thedomain" type="any" required="true">
		<!--- Flush Cache --->
		<cfif arguments.theaction EQ "flushall">
			<cfquery datasource="#application.razuna.datasource#" action="flushall" cachedomain="#arguments.thedomain#" />
		<!--- Nuclear --->
		<cfelseif arguments.theaction EQ "nuclear">
			<cfquery datasource="#application.razuna.datasource#" action="flushall" />
		</cfif>
		
		<cfreturn />
	</cffunction>

<!--- Get ALL Upload Templates ---------------------------------------------------------------------->
	<cffunction name="upl_templates" output="false">
		<cfargument name="theactive" type="boolean" required="false" default="0">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT upl_temp_id, upl_active, upl_name, upl_description
		FROM #session.hostdbprefix#upload_templates
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif arguments.theactive EQ "T">
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
		<!--- Put convert_to value into list --->
		
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
			(upl_temp_id_r, upl_temp_field, upl_temp_value, upl_temp_type, upl_temp_format, host_id)
			VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_temp_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="convert_to">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theformat#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thetype#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theformat#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			)
			</cfquery>
			<!--- Save the additional values --->
			<cfloop collection="#arguments.thestruct#" item="col">
				<cfif col EQ "convert_bitrate_#theformat#" OR col EQ "convert_height_#theformat#" OR col EQ "convert_width_#theformat#">
					<cfset tf = lcase(col)>
					<cfset tv = evaluate(tf)>
					<cfif tv NEQ "">
						<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#upload_templates_val
						(upl_temp_id_r, upl_temp_field, upl_temp_value, upl_temp_type, upl_temp_format, host_id)
						VALUES(
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_temp_id#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#tf#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#tv#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thetype#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theformat#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
		<!--- Param --->
		<cfset var qry = structnew()>
		<!--- Query links --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.links" cachename="av#session.hostid##arguments.thestruct.file_id#" cachedomain="#session.theuserid#_av">
		SELECT av_id, av_link_title, av_link_url
		FROM #session.hostdbprefix#additional_versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_link = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
		</cfquery>
		<!--- Query links --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.assets" cachename="ava#session.hostid##arguments.thestruct.file_id#" cachedomain="#session.theuserid#_av">
		SELECT av_id, av_link_title, av_link_url
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
		<!--- New id --->
		<cfset var newid = replacenocase(createuuid(),"-","","ALL")>
		<!--- Save --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#additional_versions
		(av_id, av_link_title, av_link_url, asset_id_r, folder_id_r, host_id, av_type, av_link)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_link_title#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_link_url#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_link#">
		)
		</cfquery>
		<!--- Flush Cache --->
		<cfinvoke method="clearcache" theaction="flushall" thedomain="#session.theuserid#_av" />
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
		<cfinvoke method="clearcache" theaction="flushall" thedomain="#session.theuserid#_av" />
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
		<cfinvoke method="clearcache" theaction="flushall" thedomain="#session.theuserid#_av" />
		<cfreturn />
	</cffunction>
	
	<!--- GET RECORDS WITH EMTPY VALUES --->
	<cffunction name="checkassets" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfset var foundsome = false>
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
			WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif arguments.thestruct.thetype EQ "vid">
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT
			folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
			path_to_asset, lucene_key, vid_name_image, vid_id id, vid_filename filename, vid_name_org filenameorg
			FROM #session.hostdbprefix#videos
			WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif arguments.thestruct.thetype EQ "aud">
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT
			folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
			path_to_asset, lucene_key, aud_id id, aud_name filename, aud_name_org filenameorg
			FROM #session.hostdbprefix#audios
			WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif arguments.thestruct.thetype EQ "doc">
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT
			folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
			path_to_asset, lucene_key, file_id id, file_name filename, file_name_org filenameorg
			FROM #session.hostdbprefix#files
			WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- Feedback --->
		<cfoutput><strong>You have #qry.recordcount# records. We are starting to check each record now...</strong><br><br>Below you will find records that are missing the asset on the filesytem.<br /><br /></cfoutput>
		<cfflush>
		<!--- Local --->
		<cfif application.razuna.storage EQ "local">
			<cfloop query="qry">
				<!--- Check Original --->
				<cfif NOT fileexists("#arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#/#filenameorg#")>
					<cfset foundsome = true>
					<cfoutput><strong style="color:red;">Missing Original Asset: #filename#</strong><br>We checked at: #arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#/#filenameorg#<br />
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
						<cfoutput><strong style="color:red;">Missing Thumbnail: #filename#</strong><br>We checked at: #pathtocheck#<br />
						</cfoutput>
						<cfflush>
					</cfif>
				</cfif>
			</cfloop>
		<!--- Cloud --->
		<cfelseif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			<cfloop query="qry">
				<!--- Check Original --->
				<cfhttp url="#cloud_url_org#" timeout="20" />
				<cfif cfhttp.statuscode DOES NOT CONTAIN "200">
					<cfset foundsome = true>
					<cfoutput><strong style="color:red;">Missing Original Asset: #filename#</strong><br>We checked at: #cloud_url_org#<br />
					</cfoutput>
					<cfflush>
				</cfif>
				<!--- Check thumbnail --->
				<cfif arguments.thestruct.thetype EQ "img" OR arguments.thestruct.thetype EQ "vid">
					<cfhttp url="#cloud_url#" timeout="20" />
					<cfif cfhttp.statuscode DOES NOT CONTAIN "200">
						<cfset foundsome = true>
						<cfoutput><strong style="color:red;">Missing Thumbnail: #filename#</strong><br>We checked at: #cloud_url#<br />
						</cfoutput>
						<cfflush>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		<!--- Feedback --->
		<cfif foundsome>
			<cfoutput><br /><strong>Looks like some assets are missing on the system.</strong><br /><br /></cfoutput>
			<cfflush>
		<cfelse>
			<cfoutput><br /><strong style="color:green;">Awesome. All looks stylish and clean. Rock on.</strong><br><br></cfoutput>
			<cfflush>
		</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>
	
	<!--- Call Account --->
	<cffunction name="getaccount" output="true">
		<cfargument name="thecgi" type="string">
		<cfargument name="thehostid" type="string">
		<!--- Call Remote CFC --->
		<cfinvoke webservice="http://razuna.com/includes/accounts.cfc?wsdl" 
			method="checkaccount"
			thehostid="#arguments.thehostid#"
			thecgi="#arguments.thecgi#" 
			returnVariable="qry_account"
			timeout="3">
		<!--- If there is a record then the user is in debt --->
		<cfif qry_account.recordcount NEQ 0>
			<cfset session.indebt = true>
		</cfif>
		<!--- Return --->
		<cfreturn qry_account>
	</cffunction>
	
</cfcomponent>