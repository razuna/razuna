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
		<cfinvoke component="defaults" method="trans" transid="thisid" thetransfile="#arguments.thelang#" returnvariable="theid">
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
		<!--- Check to make sure size is numeric --->
		<cfif not isnumeric(thesize)>
			<cfreturn 0>
		</cfif>
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

	<!--- Get size of a folder or file in bytes --->
	<cffunction name="getsize" returntype="numeric" hint="returns size of a directory or file using java io functions in bytes">
		<cfargument name="file" type="any" required="true">
		<cfset var size = 0>
		<cfset var oFile = arguments.file>
		<cfset var fileList = "">
		<cfset var i = 0>
		<cfif isSimpleValue(oFile)>
			<cfset oFile = CreateObject("java", "java.io.File").init(arguments.file)>
		</cfif>
		<cfif oFile.isDirectory()>
			<cfset fileList = oFile.listFiles()>
			<cfif isarray(filelist)>
				<cfloop from="1" to="#ArrayLen(fileList)#" index="thisfile">
					<cfset size = size + getSize(fileList[thisfile])>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset  size = size + oFile.length()>
		</cfif>
		<cfreturn size>
	</cffunction>
	<!--- Convert  bytes to human readable format. Mimics 'du -sh' command on non windows platforms  --->
	<cffunction name="convertbytes" returntype="String" hint="converts bytes into appropriate kb, mb, gb or tb size.">
		<cfargument name="bytes" required="true" type="numeric">
		<cfif arguments.bytes gte 1099511627776>
			<cfset size = numberformat(arguments.bytes/1099511627776,'_._') & "T">
		<cfelseif arguments.bytes gte 1073741824>
			<cfset size = numberformat(arguments.bytes/1073741824,'_._') & "G">
		<cfelseif arguments.bytes gte 1048576>
			<cfset size = numberformat(arguments.bytes/1048576,'_._')  & "M">	
		<cfelseif arguments.bytes gte 1024>
			<cfset size = numberformat(arguments.bytes/1024,'_._') & "K">
		<cfelse>
			<cfset size = arguments.bytes & "B">				
		</cfif>
		<cfreturn size>
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
		<cfset thefilename = REReplaceNoCase(thefilename, "[^[:alnum:]^\-\_\.]", "", "ALL")>
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
		<cfset thefilename = REReplaceNoCase(thefilename, "[^a-zA-Z0-9\-\_\.\s]", "", "ALL")>
		<!--- Re-add the extension to the name --->
		<cfif fileNameExt.theExt NEQ "">
			<cfset thefilename = "#thefilename#.#fileNameExt.theExt#">
		</cfif>
		<cfreturn thefilename>
	</cffunction>

<!--- GET ALL ALLOWED FILE TYPES ---------------------------------------------------------------------->
	<cffunction name="filetypes" output="false">
		<cfset var qry = "">
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
			<cfset theconnectstring = "AUTO_RECONNECT=TRUE;AUTO_SERVER=TRUE">
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
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>

<!--- Send Feedback ---------------------------------------------------------------------->
	<cffunction name="send_feedback" output="false">
		<cfargument name="thestruct" type="struct">
		<cfinvoke component="defaults" method="trans" transid="feedback_from_razuna" returnvariable="feedback_within_razuna" />
		<cfmail to="support@razuna.com" from="server@razuna.com" replyto="#arguments.thestruct.email#" subject="#feedback_within_razuna#" type="html">
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
		<cfset var qry = "">
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
				ORDER BY asset_format DESC
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
			ORDER BY asset_format ASC
			</cfquery>
		<cfelseif structkeyexists(arguments.thestruct,"thumb_img_id")>
			<!--- Get the thumb --->
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#get_share_options3 */ 
			asset_id_r, group_asset_id, asset_format, asset_dl, asset_order, asset_selected
			FROM #session.hostdbprefix#share_options
			WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.thumb_img_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			ORDER BY asset_format ASC
			</cfquery>
		<cfelse>
			<!--- Query --->
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#get_share_options3 */ 
			asset_id_r, group_asset_id, asset_format, asset_dl, asset_order, asset_selected
			FROM #session.hostdbprefix#share_options
			WHERE group_asset_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			ORDER BY asset_format ASC
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
		<cfset var checkorgentry ="">
		<cfset var checkthumbentry ="">
		<cfset var foldershareprops ="">
		<cfset var asset_dl_org = "">
		<cfset var asset_dl_thumb = "">
		<!--- COLLECTIONS SHARE SETTING--->
		<!--- If this is a collection then only change sharing for the assets in the collection --->
		<cfif isdefined("arguments.thestruct.collection_id")>
			<cfset asset_dl_org = arguments.thestruct.setto>
			<cfset asset_dl_thumb = arguments.thestruct.settothumb>
			<cfquery datasource="#application.razuna.datasource#" name="qryfiles">
				SELECT file_id_r id, col_file_type type FROM #session.hostdbprefix#collections_ct_files
				WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.collection_id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
			</cfquery>
			<!--- Loop over the files and update shared options --->
			<cfloop query="qryfiles">
				<cfinvoke component="global.cfc.global" method="update_asset_share" assetid="#qryfiles.id#" type="#qryfiles.type#" asset_dl_org="#asset_dl_org#" asset_dl_thumb="#asset_dl_thumb#">
			</cfloop>
			<cfreturn>
		</cfif>
		<!--- FOLDERS SHARE SETTING --->
		<!--- Get this folderid and all subfolders in a list --->
		<cfinvoke component="folders" method="recfolder" thelist="#arguments.thestruct.folder_id#" returnvariable="folderlist">
		<!--- Now loop over the folder list and do the reset --->
		<cfloop list="#folderlist#" delimiters="," index="thefolderid">
			<!--- 
			If this is the original folder on whom reset was called then the share properties applied to all of its assets will be the ones passed in the form. 
			If this is a sub folder within the original folder then share properties stored in database will be applied to all of its assets.
			--->
			<cfif thefolderid eq arguments.thestruct.folder_id> <!--- If folder is original folder that set share properties to form parameters passed --->
				<cfset asset_dl_org = arguments.thestruct.setto>
				<cfset asset_dl_thumb = arguments.thestruct.settothumb>
			<cfelse><!--- If folder is a sub folder the get the share properties from database for this folder --->
				<cfquery datasource="#application.razuna.datasource#" name="foldershareprops">
					SELECT share_dl_org, share_dl_thumb FROM #session.hostdbprefix#folders 
					WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderid#">
				</cfquery>
				<cfset asset_dl_org = iif(foldershareprops.share_dl_org eq 't',1,0)>
				<cfset asset_dl_thumb = iif(foldershareprops.share_dl_thumb eq 't',1,0)>
			</cfif>
			<!--- Get all the files in this folder --->
			<cfinvoke component="folders" method="getallassetsinfolder" folder_id="#thefolderid#" returnvariable="qryfiles">
			<!--- Loop over the files and update shared options --->
			<cfloop query="qryfiles">
				<cfinvoke component="global.cfc.global" method="update_asset_share" assetid="#qryfiles.id#" folderid="#thefolderid#" type="#qryfiles.type#" asset_dl_org="#asset_dl_org#" asset_dl_thumb="#asset_dl_thumb#">
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

	<cffunction name="update_asset_share" returntype="void" hint="updates share value for asset">
		<cfargument name="assetid" required="true">
		<cfargument name="type" required="true">
		<cfargument name="asset_dl_org" required="true">
		<cfargument name="asset_dl_thumb" required="true">
		<cfargument name="folderid" default="">

		<cfquery datasource="#application.razuna.datasource#" name="checkorgentry">
			SELECT 1 FROM #session.hostdbprefix#share_options  
			WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#assetid#">
			AND asset_format = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="org">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
		</cfquery>
		<!--- Insert/update original entires in share_options table and apply same appropriate permissions --->
		<cfif checkorgentry.recordcount eq 0>
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#share_options (host_id,asset_id_r, asset_type,asset_format,group_asset_id,<cfif folderid NEQ ""> folder_id_r,</cfif> asset_order,asset_dl, rec_uuid)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#assetid#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#type#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="org">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#assetid#">,
				<cfif folderid NEQ "">
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#folderid#">,
				</cfif>
				
				<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#asset_dl_org#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
		<cfelse>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#share_options
			SET 
			asset_dl = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#asset_dl_org#">
			<cfif folderid NEQ "">,folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#folderid#"></cfif>
			WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#assetid#">
			AND asset_format = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="org">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>

		<cfif type eq "img"><!---  Insert/update preview entires for images only --->
			<cfquery datasource="#application.razuna.datasource#" name="checkthumbentry">
				SELECT 1 FROM #session.hostdbprefix#share_options  
				WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#assetid#">
				AND asset_format = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="thumb">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
			</cfquery>

			<cfif checkthumbentry.recordcount eq 0>
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#share_options (host_id,asset_id_r, asset_type, asset_format,group_asset_id, <cfif folderid NEQ "">folder_id_r, </cfif>asset_order,asset_dl, rec_uuid)
				VALUES(
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#assetid#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#type#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="thumb">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#assetid#">,
					<cfif folderid NEQ ""><cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#folderid#">,</cfif>
					<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#asset_dl_thumb#">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
				</cfquery>
			<cfelse>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#share_options
				SET 
				asset_dl = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#asset_dl_thumb#">
				<cfif folderid NEQ "">,folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#folderid#"></cfif>
				WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#assetid#">
				AND asset_format = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="thumb">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>	
		</cfif>
	</cffunction>

<!--- Get ALL Upload Templates ---------------------------------------------------------------------->
	<cffunction name="upl_templates" output="false">
		<cfargument name="theactive" type="boolean" required="false" default="false">
		<cfset var qry = "">
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
		<cfif isDefined("arguments.thestruct.useavid")>
			<cfset idcol  = "av_id">
		<cfelse>
			<cfset idcol  = "asset_id_r">
		</cfif>
		<!--- Param --->
		<cfset var qry = structnew()>
		<!--- Query links --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.links" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#get_versions_link */ av_id, asset_id_r, av_link_title, av_link_url, folder_id_r, av_type, av_thumb_url
		FROM #session.hostdbprefix#additional_versions
		WHERE #idcol# = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_link = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
		</cfquery>
		<!--- Query links --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.assets" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#get_versions_link2 */ av_id, asset_id_r, av_link_title, av_link_url, thesize, thewidth, theheight, av_type, hashtag, folder_id_r, av_thumb_url
		FROM #session.hostdbprefix#additional_versions
		WHERE #idcol# = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
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
		<cfparam name="arguments.thestruct.format" default="av">
		<cfparam name="arguments.thestruct.download" default="1">
		<cfparam name="arguments.thestruct.order" default="1">
		<cfparam name="arguments.thestruct.selected" default="0">
		<cfparam name="arguments.thestruct.newid" default="#createuuid('')#">
		<cfparam name="arguments.thestruct.av_thumb_url" default="" >
		
		<cfif not isdefined("arguments.thestruct.prefs")>
			<cfset arguments.thestruct.prefs = structnew()>
		</cfif>

		<cfset var upcstruct  = isupc(arguments.thestruct.folder_id)>
		<cfif upcstruct.upcenabled>
			<!--- Get UPC number for asset  from database --->
			<cfquery datasource="#application.razuna.datasource#" name="get_upc">
					SELECT img_upc_number as upcnumber FROM  #session.hostdbprefix#images
					WHERE img_id =<cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
					UNION ALL
					SELECT aud_upc_number as upcnumber FROM  #session.hostdbprefix#audios
					WHERE aud_id =<cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
					UNION ALL
					SELECT vid_upc_number as upcnumber FROM  #session.hostdbprefix#videos
					WHERE vid_id =<cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
					UNION ALL
					SELECT file_upc_number as upcnumber FROM  #session.hostdbprefix#files
					WHERE file_id =<cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfinvoke component="global" method="ExtractUPCInfo" returnvariable="upcinfo">
				<cfinvokeargument name="upcnumber" value="#get_upc.upcnumber#"/>
				<cfinvokeargument name="upcgrpsize" value="#upcstruct.upcgrpsize#"/>
			</cfinvoke>
			<!--- Only if product string is numeric then change filename --->
			<cfif isNumeric(upcinfo.upcprodstr)>
				<!--- Check if last char of filename is an alphabet. If so then it will be appeneded to resulting UPC filename --->
				<cfset var fn_last_char = "">
				<cfif find('.', arguments.thestruct.av_link_title)>
					 <cfset fn_last_char = right(listfirst(arguments.thestruct.av_link_title,'.'),1)> 
					<cfif not isnumeric(fn_last_char)>
						<cfset var fn_ischar = true>
					<cfelse>
						<cfset fn_ischar = false>
						<cfset fn_last_char = "">
					</cfif>
				</cfif>
				<cfset var filenum = getToken(arguments.thestruct.av_link_title,2,'.') >
				<cfif isnumeric(filenum)>
					<cfset arguments.thestruct.av_link_title = upcinfo.upcprodstr & '#fn_last_char#.#filenum#'>
				<cfelse>
					<cfset arguments.thestruct.av_link_title = upcinfo.upcprodstr & fn_last_char>
				</cfif>
			</cfif>
		</cfif>

		<!--- Save --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#additional_versions
		(av_id, av_link_title, av_link_url, asset_id_r, folder_id_r, host_id, av_type, av_link, thesize, thewidth, theheight, hashtag, av_thumb_url)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">,
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
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.md5hash#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.av_thumb_url#">
		)
		</cfquery>
		
		<!--- Set Sharing Options --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#share_options
		(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, asset_selected, rec_uuid)
		VALUES(
		       <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">,
		       <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		       <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
		       <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
		       <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.type#">,
		       <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.format#">,
		       <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.download#">,
		       <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.order#">,
		       <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.selected#">,
		       <cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
		</cfquery>
		<!--- RAZ-2837 : Copy/Update original file's metadata to rendition --->
		<cfif structKeyExists(arguments.thestruct.prefs,'set2_rendition_metadata') AND arguments.thestruct.prefs.set2_rendition_metadata EQ 'true'>
			<cfset var assettype = arguments.thestruct.type>
			<cfset var thetbl = ''>
			<cfif assettype eq 'aud'>
				<cfset var thetbl = 'audios'>
			<cfelseif assettype eq 'vid'>
				<cfset var thetbl = 'videos'>
			<cfelseif assettype eq 'img'>
				<cfset var thetbl = 'images'>
			</cfif>
			<cfif thetbl neq ''>
				<!--- RAZ-2837: Get descriptions and keywords --->
				<cfquery datasource="#application.razuna.datasource#" name="qry_details">
					SELECT  lang_id_r, #assettype#_description as thedesc, #assettype#_keywords as thekeys
					FROM #session.hostdbprefix##thetbl#_text
					WHERE #assettype#_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfif qry_details.recordcount neq 0>
					<!--- Add to descriptions and keywords --->
					<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix##thetbl#_text
						(id_inc, #assettype#_id_r, lang_id_r, #assettype#_description, #assettype#_keywords, host_id)
						VALUES(
						<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="#qry_details.lang_id_r#" cfsqltype="cf_sql_numeric">, 
						<cfqueryparam value="#ltrim(qry_details.thedesc)#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#ltrim(qry_details.thekeys)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
					</cfquery>
				</cfif>
				<!-- CFC: Check for custom fields -->
				<cfset arguments.thestruct.cf_show = assettype>
				<cfinvoke component="global.cfc.custom_fields" method="getfields" returnvariable="arguments.thestruct.qry_cf" argumentcollection="#arguments#"/>
				<cfif arguments.thestruct.qry_cf.recordcount NEQ 0>
					<cfloop query="arguments.thestruct.qry_cf">
						<cfquery datasource="#application.razuna.datasource#">
							INSERT INTO #session.hostdbprefix#custom_fields_values
							(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
							VALUES(
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#cf_id#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#cf_value#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
							<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
							)
						</cfquery>
					</cfloop>	
				</cfif>
			</cfif>
		</cfif>

		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("general")>
		<cfreturn />
	</cffunction>

<!--- Remove versions link ---------------------------------------------------------------------->
	<cffunction name="remove_av_link" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<cfset var getinfo = "">
		<cfquery datasource="#application.razuna.datasource#" name="getinfo">
		SELECT av_link_title, av_type, 
		CASE
		WHEN av_type = 'img'  THEN (SELECT folder_id_r FROM #session.hostdbprefix#images WHERE img_id = a.asset_id_r)
		WHEN av_type = 'aud' THEN  (SELECT folder_id_r FROM #session.hostdbprefix#audios WHERE aud_id = a.asset_id_r)
		WHEN av_type = 'vid' THEN  (SELECT folder_id_r FROM #session.hostdbprefix#videos WHERE vid_id = a.asset_id_r)
		ELSE (SELECT folder_id_r FROM #session.hostdbprefix#files WHERE file_id = a.asset_id_r)
		END folder_id
		FROM #session.hostdbprefix#additional_versions a
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		</cfquery>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#additional_versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND av_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		</cfquery>
		<!--- Remove version data --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#images_text
		WHERE img_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#videos_text
		WHERE vid_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#audios_text
		WHERE aud_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#custom_fields_values
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Log entry --->
		<cfinvoke component="extQueryCaching" method="log_assets">
			<cfinvokeargument name="theuserid" value="#session.theuserid#">
			<cfinvokeargument name="logaction" value="Delete">
			<cfinvokeargument name="logdesc" value="Deleted Additional Rendition: #getinfo.av_link_title#">
			<cfinvokeargument name="logfiletype" value="#getinfo.av_type#">
			<cfinvokeargument name="assetid" value="#arguments.thestruct.file_id#">
			<cfinvokeargument name="folderid" value="#getinfo.folder_id#">
		</cfinvoke>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("general")>
		<cfreturn />
	</cffunction>

<!--- getav ---------------------------------------------------------------------->
	<cffunction name="getav" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<cfset var qry = "">
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
		<cfset var qry = "">
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
		<cfset var qry = "">
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
		<cfset var qry = "">
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
		<!--- Set thepath variable --->
		<cfset var thepath = "">
		<!--- Get installed fonts and create list --->	
		<cfexecute name="#theimconvert#" arguments="-list font" variable="x" timeout="60" />
		<!--- Loops over result and grab the path to the XML --->
		<cfloop list="#x#" delimiters=" " index="i">
			<cfif i CONTAINS ".xml">
				<cfset thepath = trim(i)>
			</cfif>
		</cfloop>
		<cfif thepath contains ".xml">
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
		<cfelse>
			<!--- Set default font --->
			<cfset qry.fontlist = 'Times Regular:Times-Roman,Helvetica Regular:Helvetica'>
		</cfif>
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
		WHERE attributes != 'H'
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
	
	<!--- GET ADDITIONAL VERSIONS --->
	<cffunction name="getAdditionalVersions" output="true" >
		<cfargument name="thestruct" type="struct" >
		 <!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("general")>
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getAdditionalImages */ av_id, asset_id_r, folder_id_r, av_type, av_link_title, av_link_url, host_id, 
			av_link, thesize, thewidth, theheight
			FROM #session.hostdbprefix#additional_versions
			WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#"> 
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction> 
	
	<cffunction name="isUPC"  hint="Check whether host, user and folder are UPC enabled" returntype="Struct">
		<!--- For UPC to be enabled 3 conditions must be fulfilled:
		1) The host must have UPC enabled in settings
		2) Folder  must have UPC label
		3) User must be part of a group which has UPC size set
		 --->
		<cfargument name ="folder_id" required="true" hint="folder to check for UPC label">
		<cfset var upcstruct = structnew()>
		<cfset upcstruct.upcenabled = false>
		<cfset upcstruct.upcgrpsize = "">
		<cfset upcstruct.upcgrpid = "">
		<cfset upcstruct.createupcfolder = false>
		<!--- Check if UPC enabled in settings --->
		<cfquery datasource="#application.razuna.datasource#" name="is_upc_enabled">
			SELECT set2_upc_enabled FROM #session.hostdbprefix#settings_2
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>

		<!--- Check if folder has UPC label --->
		<cfquery datasource="#application.razuna.datasource#" name="is_folder_upc_label">
			SELECT 1 FROM #session.hostdbprefix#labels l, ct_labels c, #session.hostdbprefix#folders f
			WHERE l.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND (l.label_text = 'UPC' OR l.label_text = 'upc')
			AND  c.ct_id_r =  f.folder_id
			AND  c.ct_type = 'folder'
			AND  c.ct_label_id  = l.label_id
			AND f.folder_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<!--- Check if user is part of a group for which UPC size is set--->
		<cfquery datasource="#application.razuna.datasource#" name="grp_upc_size">
			SELECT g.upc_size, g.grp_id, g.upc_folder_format FROM groups g, ct_groups_users u
			WHERE g.grp_id = u.ct_g_u_grp_id
			AND u.ct_g_u_user_id = '#session.theuserid#'
			AND g.upc_size is not null
			AND g.upc_size != ''
		</cfquery>

		 <cfif is_upc_enabled.set2_upc_enabled eq 'true' and  is_folder_upc_label.recordcount neq 0 and isnumeric(grp_upc_size.upc_size)>
		 	<cfset upcstruct.upcenabled = true>
		 	<cfset upcstruct.upcgrpsize = grp_upc_size.upc_size>
		 	<cfset upcstruct.upcgrpid = grp_upc_size.grp_id>
		 	<cfset upcstruct.createupcfolder = grp_upc_size.upc_folder_format>
		 </cfif>
		 <cfreturn upcstruct>
	</cffunction>

	<cffunction name="ExtractUPCInfo"  hint="Extracts UPC naming details based on group UPC size set for user and UPC number for asset" returntype="Struct">
		<cfargument name="upcnumber" required="true" hint="UPC number for asset">
		<cfargument name="upcgrpsize" required="true" hint="UPC group size set">
		<cfset var upcstruct = structnew()>
		<cfset upcstruct.extract_upcnumber = "">
		<cfset upcstruct.upcprodstr = "">
		<cfset upcstruct.upcmanufstr = "">
		<!--- Extract UPC number --->
		<cfset arguments.thestruct.dl_query.upc_number = arguments.upcnumber>
		<cfinvoke component="folders" method="Extract_UPC" returnvariable="extract_upcnumber">
			<cfinvokeargument name="thestruct" value="#arguments.thestruct#" />
			<cfinvokeargument name="sUPC" value="#arguments.upcnumber#">
			<cfinvokeargument name="iUPC_Option" value="#arguments.upcgrpsize#">
		</cfinvoke>
		<!--- Get Manufacturer String which will be the folder name --->
		<cfinvoke component="folders" method="Find_Manuf_String" returnvariable="manuf_str">
			<cfinvokeargument name="strManuf_UPC" value="#extract_upcnumber#">
		</cfinvoke>
		<!--- Get Product String which will be the file name --->
		<cfinvoke component="folders" method="Find_Prod_String" returnvariable="prod_str">
			<cfinvokeargument name="strManuf_UPC" value="#extract_upcnumber#">
		</cfinvoke>
		<cfset upcstruct.extract_upcnumber = extract_upcnumber>
		<cfset upcstruct.upcmanufstr = manuf_str>
		<cfset upcstruct.upcprodstr = prod_str>
		<cfreturn upcstruct>
	</cffunction>
	
	<cffunction name="fixdbintegrityissues" returntype="void" hint="Put any database code here to fix issues with invalid data in database e.g. set boolean fields to have default boolean values instead of empty values which will throw errors in boolean type conditions etc.">
		<!--- Use this format to specify tables and columns in the table to set to a specified value instead of an empty string
			<cfset setempty2val["table1"] = "col1:'val1',col2:NULL">
			<cfset setempty2val["table2"] = "col1:'val1',col2:'val2'">
		--->
		<cfset setempty2val["raz1_settings_2"] = "set2_upc_enabled:'false',set2_md5check:NULL, set2_colorspace_rgb:'false',set2_custom_file_ext:'false',set2_email_use_ssl:'false',set2_email_use_tls:'false',set2_rendition_metadata:'false',">
		<cfloop collection="#setempty2val#" item="tbl">
			<cfloop list="#StructFind(setempty2val, tbl)#" index="col" delimiter=",">
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					UPDATE #tbl# SET #gettoken(col,1,':')#= #preservesinglequotes(gettoken(col,2,':'))# WHERE #gettoken(col,1,':')# = '' OR #gettoken(col,1,':')# is null
				</cfquery>
				<cfcatch></cfcatch>
				</cftry>
		 	</cfloop>
		</cfloop>
	</cffunction>

	<!--- Updater logs --->
	<cffunction name="updaterLogs" returntype="query">
		<cfset var qry = "">
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT l.file_name, l.hashtag, l.date_upload, l.file_status, u.user_first_name, u.user_last_name
		FROM log_uploader l LEFT JOIN users u ON u.user_api_key = l.api_key
		WHERE l.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		GROUP BY l.hashtag, l.file_name
		ORDER BY l.date_upload DESC
		LIMIT 300
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Updater logs CLEAN --->
	<cffunction name="updaterLogsClean">
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM log_uploader
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cffunction>

	<!--- Create Alias --->
	<cffunction name="alias_create" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Loop over session.file_id --->
		<cfloop list="#session.file_id#" index="file">
			<!--- The first part is the id --->
			<cfset var fileid = listfirst(file,"-")>
			<!--- The second part is the type --->
			<cfset var filetype = listlast(file,"-")>
			<cfset var alias_exists = "">
			<!--- Check if alias already exists in folder or if folder is same folder as original  for alias --->
			<cfquery datasource="#application.razuna.datasource#" name="alias_exists">
				SELECT 1 FROM ct_aliases WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
				UNION 
				SELECT 1 FROM #session.hostdbprefix#images WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
				UNION
				SELECT 1 FROM #session.hostdbprefix#audios WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
				UNION
				SELECT 1 FROM #session.hostdbprefix#videos WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
				UNION
				SELECT 1 FROM #session.hostdbprefix#files WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			 </cfquery>
			 <cfif alias_exists.recordcount EQ 0>
				<!--- Add to DB --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO ct_aliases
				(asset_id_r, folder_id_r, type, rec_uuid)
				VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#filetype#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">
				)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("search")>
	</cffunction>

	<!--- Remove Alias --->
	<cffunction name="alias_remove" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Remove --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM ct_aliases
		WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.id#">
		AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
		</cfquery>
		<!--- Flush Cache --->
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("search")>
	</cffunction>

	<!--- Remove many Aliases --->
	<cffunction name="alias_remove_many" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Remove --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM ct_aliases
		WHERE rec_uuid in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.id#" list="true">)
		</cfquery>
		<!--- Flush Cache --->
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("search")>
	</cffunction>


	<!--- Check for alias --->
	<cffunction name="getAlias" output="false">
		<cfargument name="asset_id_r" type="string" required="true">
		<cfargument name="folder_id_r" type="string" required="true">
		<!--- Param --->
		<cfset var qry = ''>
		<cfset var exists = false>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT asset_id_r, folder_id_r 
		FROM ct_aliases
		WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#">
		AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folder_id_r#">
		</cfquery>
		<!--- If exists set to true --->
		<cfif qry.recordcount NEQ 0>
			<cfset exists = true>
		</cfif>
		<!--- Return --->
		<cfreturn exists />
	</cffunction>

	<!--- Move alias --->
	<cffunction name="moveAlias" output="false">
		<cfargument name="asset_id_r" type="string" required="true">
		<cfargument name="new_folder_id_r" type="string" required="true">
		<cfargument name="pre_folder_id_r" type="string" required="true">
		<cfset var alias_exists = "">
		<!--- If another alias already exists in folder or alias is being moved to folder where original asset resides then delete this entry else update --->
		<cfquery datasource="#application.razuna.datasource#" name="alias_exists">
		SELECT 1 FROM ct_aliases WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_folder_id_r#">
		UNION 
		SELECT 1 FROM #session.hostdbprefix#images WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_folder_id_r#">
		UNION
		SELECT 1 FROM #session.hostdbprefix#audios WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_folder_id_r#">
		UNION
		SELECT 1 FROM #session.hostdbprefix#videos WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_folder_id_r#">
		UNION
		SELECT 1 FROM #session.hostdbprefix#files WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#"> AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_folder_id_r#">
		</cfquery>
		<cfif alias_exists.recordcount NEQ 0>
			<!--- Delete --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM ct_aliases
			WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#">
			AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pre_folder_id_r#">
			</cfquery>
		<cfelse>
			<!--- Update --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE ct_aliases
			SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_folder_id_r#">
			WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#">
			AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pre_folder_id_r#">
			</cfquery>
		</cfif>
		<!--- Flush Cache --->
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("audios")>
	</cffunction>

	<!--- List alias usage --->
	<cffunction name="getUsageAlias" output="false" returntype="query">
		<cfargument name="asset_id_r" type="string" required="true">
		<!--- Var --->
		<cfset var qry = ''>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,30)#" region="razcache">
		SELECT folder_id_r, '' as folder_name
		FROM ct_aliases
		WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.asset_id_r#">
		</cfquery>
		<!--- Get the folder names --->
		<cfloop query="qry">
			<!--- Get the foldername --->
			<cfinvoke component="folders" method="getfoldername" folder_id="#folder_id_r#" returnvariable="_foldername" />
			<!--- Add to query --->
			<cfset querySetCell(qry, "folder_name", _foldername)>
		</cfloop>
		<!--- Return query --->
		<cfreturn qry />
	</cffunction>

	<cffunction name="compareLists" access="public" returnType="string" output="false" hint="Compares two lists and returns the intersection of the two. Returns empty string if none found.">
	    <cfargument name="List1" type="string" required="true" />
	    <cfargument name="List2" type="string" required="true" />
	    <cfscript>
		  var TempList = "";
		  var Delim1 = ",";
		  var Delim2 = ",";
		  var Delim3 = ",";
		  var i = 0;
		  // Handle optional arguments
		  switch(ArrayLen(arguments)) {
		    case 3:
		      {
		        Delim1 = Arguments[3];
		        break;
		      }
		    case 4:
		      {
		        Delim1 = Arguments[3];
		        Delim2 = Arguments[4];
		        break;
		      }
		    case 5:
		      {
		        Delim1 = Arguments[3];
		        Delim2 = Arguments[4];          
		        Delim3 = Arguments[5];
		        break;
		      }        
		  } 
		   /* Loop through the second list, checking for the values from the first list.
		    * Add any elements from the second list that are found in the first list to the
		    * temporary list
		    */  
		  for (i=1; i LTE ListLen(List2, "#Delim2#"); i=i+1) {
		    if (ListFindNoCase(List1, ListGetAt(List2, i, "#Delim2#"), "#Delim1#")){
		     TempList = ListAppend(TempList, ListGetAt(List2, i, "#Delim2#"), "#Delim3#");
		    }
		  }
		  Return TempList;
	    </cfscript>
	</cffunction>

	<cffunction name="subtractlists" access="public" output="false" hint="returns all elements of list one minus the elements of list two">
	   <cfargument name="list1"  required="true" default="" />
	   <cfargument name="list2"  required="false" default="" />
	 
	   <cfset var result = "">
	   <cfset var kk = "">
	    
	   <cfloop index="kk" list="#list1#">
	     <cfif listFindNoCase(arguments.list2,kk) eq 0>
	       <cfset result = listAppend(result,kk)>
	     </cfif>
	   </cfloop>
	    
	   <cfreturn result>
	</cffunction>

</cfcomponent>