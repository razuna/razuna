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
<cfcomponent extends="extQueryCaching">

<!--- GET THE LANGUAGES --->
<cffunction name="getlangs" output="false">
	<cftry>
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("settings")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="thelangs" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getlangs */ lang_id, lang_name
		FROM #session.hostdbprefix#languages
		WHERE lang_active = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		ORDER BY lang_id
		</cfquery>
		<!--- If no record is found then insert the default English one --->
		<cfif thelangs.recordcount EQ 0>
			<!--- Check if english is here or not --->
			<cfquery datasource="#application.razuna.datasource#" name="thelangseng" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getlangeng */ lang_id
			FROM #session.hostdbprefix#languages
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND lang_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">
			</cfquery>
			<cfif thelangseng.recordcount EQ 0>
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#languages
				(lang_id, lang_name, lang_active, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="English" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="t" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			<cfelse>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#languages
				SET lang_active = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
				WHERE lang_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
			<!--- Reset Cache --->
			<cfset variables.cachetoken = resetcachetoken("general")>
			<!--- Query again --->
			<cfquery datasource="#application.razuna.datasource#" name="thelangs" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getlangsagain */ lang_id, lang_name
			FROM #session.hostdbprefix#languages
			WHERE lang_active = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			ORDER BY lang_id
			</cfquery>
		</cfif>
		<!--- Return --->
		<cfreturn thelangs>
		<cfcatch type="any">
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="Error with database">
				<cfdump var="#cfcatch#" label="error">
				<cfdump var="#session#" label="sessions">
			</cfmail>
		</cfcatch>
	</cftry>
</cffunction>

<!--- GET THE LANGUAGES FOR ADMIN --->
<cffunction name="getlangsadmin" output="false">
	<cfargument name="thepath" default="" required="yes" type="string">
	<!--- Get the xml files in the translation dir --->
	<cfdirectory action="list" directory="#arguments.thepath#/translations" name="thelangs" >
	<cfquery dbtype="query" name="thelangs">
	SELECT *
	FROM thelangs where TYPE = 'Dir' and name != 'Custom'
	ORDER BY name
	</cfquery>
	<cfreturn thelangs>
</cffunction>

<!--- PARSE THE LANGUAGE AND TRANSLATION FROM THE XML FILE --->
<cffunction name="trans" output="false" returntype="string" hint="Get the correct translation">
	<cfargument name="transid" default="" required="yes" type="string">
	<cfargument name="values" hint="Array of values to substitute for $1, $2 etc in the resource string" type="array" required="false" default="#arrayNew(1)#" />
	<cfargument name="thetransfile" default="#session.thelang#" required="false" type="string">
	<!--- init function internal vars --->
	<!---<cfset var xmlFile=expandpath("translations/#arguments.thetransfile#")/>
	<cfset var xmlVar = "">
	<cffile action="read" file="#xmlFile#" variable="xmlVar" charset="utf-8">
	<cfset xmlVar=xmlParse(xmlVar)/>
	<cfset xmlVar=xmlSearch(xmlVar, "translations/transid[@name='#arguments.transid#']")>
	<cfreturn trim(#xmlVar[1].transtext.xmlText#)>--->
	<cfreturn application.razuna.trans.getString(resourceBundleName = 'HomePage', key = arguments.transid, locale = arguments.thetransfile, values = arguments.values)>
</cffunction>

<!--- PARSE THE LANGUAGE ID FOR ADMIN --->
<cffunction name="xmllangid" output="false" returntype="string" hint="Get the correct translation">
	<cfargument name="thetransfile" required="yes" type="string">
	<!--- init function internal vars --->
	<cfset var xmlVar = "">
	<cffile action="read" file="#arguments.thetransfile#" variable="xmlVar" charset="utf-8">
	<cfset xmlVar=xmlParse(xmlVar)/>
	<cfset xmlVar=xmlSearch(xmlVar, "translations/transid[@name='thisid']")>
	<cfreturn trim(#xmlVar[1].transtext.xmlText#)>
</cffunction>

<cffunction name="propertiesfilelangid" output="false" returntype="string" hint="Get the correct translation">
	<cfargument name="thetransfile" required="yes" type="string">

	<cfset propertyFile = createObject('java', 'java.util.Properties') />
	<cfset propertyFile.load( createObject('java', 'java.io.InputStreamReader').init( createObject('java', 'java.io.FileInputStream').init( #arguments.thetransfile# ),'utf-8' ) ) />
	<cfreturn propertyFile.getProperty( 'thisid')>
</cffunction>



<!--- Get absolute path from relative path --->
<cffunction name="getAbsolutePath" returntype="string"
						output="false" access="public" hint="Get absolute path from relative path">
	<cfargument name="pathSourceAbsolute" type="string" required="true" hint="path to calling file, including file-name as from GetCurrentTemplatePath()">
	<cfargument name="pathTargetRelative" type="string" required="true" hint="relative path to target file from calling-files directory like ../../folder/file.cfm ">
	<!--- function internal vars --->
	<cfset var iLoop = 0>
	<!--- function body --->
	<cfset Arguments.pathSourceAbsolute = Reverse(GetDirectoryFromPath(Arguments.pathSourceAbsolute))>
	<cfloop from="1" to="#ListLen(Arguments.pathTargetRelative, "/\")#" index="iLoop">
		<cfif ListFirst(Arguments.pathTargetRelative, "/\") neq "..">
			<cfbreak>
		</cfif>
		<cfset Arguments.pathSourceAbsolute = Right(Arguments.pathSourceAbsolute, Len(Arguments.pathSourceAbsolute) - FindOneOf("/\", Arguments.pathSourceAbsolute, 2) + 1)>
		<cfset Arguments.pathTargetRelative = ListRest(Arguments.pathTargetRelative, "/\")>
	</cfloop>
	<cfreturn Reverse(Arguments.pathSourceAbsolute) & Arguments.pathTargetRelative/>
</cffunction>

<!--- GET THE PATH OF THIS HOST --->
<cffunction hint="Get the path of this host" name="hostpath" output="false" returntype="string">
	<cfset var hostp = 0>
	<cfquery datasource="#application.razuna.datasource#" name="hostp">
	SELECT host_path
	FROM hosts
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(hostp.host_path)>
</cffunction>

<!--- Get the loading gif images --->
<cffunction name="loadinggif" output="false" returntype="string">
	<cfargument name="dynpath" type="string" required="false" default="">
	<cfreturn '<img src="#arguments.dynpath#/global/host/dam/images/loading.gif" width="16" height="16" border="0" style="padding:10px;">'>
</cffunction>

<!--- GET HOW MANY LANGUAGES THIS HOST IS ALLOWED --->
<cffunction hint="Get how many languages this host has installed" name="howmanylang" output="false" returntype="numeric">
	<cfset var langs = 0>
	<cfquery datasource="#application.razuna.datasource#" name="langs">
		SELECT host_lang 
		FROM hosts
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn val(langs.host_lang)>
</cffunction>

<!--- GET THE LANGUAGE TAG --->
<cffunction hint="Get the exact language tag" name="thislang" output="false" returntype="string">
	<cfargument name="theid" default="" required="yes" type="string">
	<cfset var thislang = 0>
	<cfquery datasource="#application.razuna.datasource#" name="thislang">
	SELECT set_pref 
	FROM #session.hostdbprefix#settings
	WHERE LOWER(set_id) = <cfqueryparam value="#lcase(arguments.theid)#" cfsqltype="cf_sql_varchar">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(thislang.set_pref)>
</cffunction>

<!--- -------------------------------------------------------------------------- --->
<!--- PARSE THE XML FOR THE TEMPLATES --->
<cffunction name="parsexml" output="false">
	<cfargument name="thefile" type="string" default="" required="yes">
	<cfargument name="thevalue" type="string" default="" required="yes">
	<cfset var xmlVar = "">
	<cffile action="read" file="#arguments.thefile#" variable="xmlVar" charset="utf-8">
	<cfset xmlVar=xmlParse(xmlVar)/>
	<cfset xmlVar=xmlSearch(xmlVar, "#arguments.thevalue#")>
	<cfreturn trim(#xmlVar[1].xmlText#)>
</cffunction>

<!--- GET THE DATE FORMAT OF THIS HOST --->
<cffunction hint="GET THE DATE FORMAT OF THIS HOST" name="getdateformat" output="false" returntype="string">
	<!--- init function internal vars --->
	<cfset var qDateFormat = 0>
	<cfset var mydate = "">
	<cfquery datasource="#application.razuna.datasource#" name="qDateFormat">
	SELECT set2_date_format, set2_date_format_del
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfswitch expression="#qDateFormat.set2_date_format#">
		<cfcase value="euro">
			<cfset mydate="dd#qDateFormat.set2_date_format_del#mm#qDateFormat.set2_date_format_del#yyyy">
		</cfcase>
		<cfcase value="us">
			<cfset mydate="mm#qDateFormat.set2_date_format_del#dd#qDateFormat.set2_date_format_del#yyyy">
		</cfcase>
		<cfcase value="sql">
			<cfset mydate="yyyy#qDateFormat.set2_date_format_del#mm#qDateFormat.set2_date_format_del#dd">
		</cfcase>
	</cfswitch>
	<cfreturn trim(mydate)>
</cffunction>

<!--- CONVERT BYTES TO KB/MB --------------------------------------------------------------------->
<cffunction hint="CONVERT BYTES TO MB" name="converttomb" output="false">
	<cfargument name="thesize" default="0" required="yes" type="numeric">
	<cfargument name="unit" default="MB" required="no" type="string">
	<!--- Set local variable --->
	<cfset var divisor = 0>
	<cfif arguments.thesize EQ "">
		<cfset arguments.thesize = 0>
	</cfif>
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
		<cfset themb = arguments.thesize / divisor>
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
	<!--- Return --->
	<cfreturn themb>
	<!--- if we ever do something else
	var bytes = 1;
	var kb = 1024;
	var mb = 1048576;
	var gb = 1073741824;
	--->
</cffunction>


</cfcomponent>