<cfcomponent>

  <cffunction name="onServerStart">
	<cfset consoleoutput(true)>
	<cfset console("------------SERVER STARTUP------------------")>

	<cfset console("---START: Cache Setup---")>
	<!--- Create the cache --->
	<!--- <cfset cacheregionnew(
	  region="razcache",
	  props=
	  {
		type : 'memorydisk'
	  }
	)> --->

	<!--- READ the documentation at http://wiki.razuna.com/display/ecp/Configure+Caching !!! --->

	<!--- Memcached / CouchBase --->
	<!---
	<cfset cacheregionnew(
	region="razcache",
	props=
		{
		type : 'memcached',
		server : '127.0.0.1:11211',
		waittimeseconds : 5
		}
	)>
	--->

	<!--- REDIS --->
	<!--- <cftry>
		<cfset cacheregionnew(
			region="razcache",
			props=
				{
					type : 'redis',
					server : 'redis://127.0.0.1:6379',
					waittimeseconds : 5
				}
		)>
		<cfcatch type="any">
			<cfset consoleoutput(true)>
			<cfset console("------------ REDIS error !!!!!!!!!!!!!!!!!!!!!!!!!")>
			<cfset console(cfcatch)>
		</cfcatch>
	</cftry> --->
	<!--- MongoDB --->
	<!---
	<cfset cacheregionnew(
	region="razcache",
	props=
		{
	  type : 'mongo',
	  server : '10.0.0.1:27017 10.0.0.2:27017',
	  db : 'razcache',
	  collection : 'nameofregion',
	  user : 'username',
	  password : 'password'
	  }
	)>
	--->
	<cfset console("---DONE: Cache Setup---")>

	<cftry>
	  <cfset console("------------ENABLING CRON------------------")>
	  <cfset cronEnable(true) />
	  <cfcatch type="any">
		<cfset consoleoutput(true)>
		<cfset console("------------ Cron error !!!!!!!!!!!!!!!!!!!!!!!!!")>
		<cfset console(cfcatch)>
	  </cfcatch>
	</cftry>
	<cftry>
	  <cfset console("------------ENABLING CRON DIRECTORY------------------")>
	   <cfset CronSetDirectory("/cron") />
	  <cfcatch type="any">
		<cfset consoleoutput(true)>
		<cfset console("------------ Cron error !!!!!!!!!!!!!!!!!!!!!!!!!")>
		<cfset console(cfcatch)>
	  </cfcatch>
	</cftry>

	<cftry>
	  <cfset console("------------REMOVING ANY LOCK OR OTHER TEMP FILES------------------")>
	  <cfdirectory action="list" directory="#GetTempDirectory()#" name="tmpList" type="file" />
	  <cfloop query="tmpList">
	  	<cfif name CONTAINS ".sh" OR name CONTAINS ".tmp" OR name CONTAINS ".temp" OR name CONTAINS ".csv" OR name CONTAINS ".xls" OR name CONTAINS ".xlsx" OR name CONTAINS ".lock" OR name CONTAINS ".bat">
			<cftry>
				<cfset console("#now()# ---------------- Removing file in temp dir: #GetTempDirectory()#/#name#")>
				<cffile action="delete" file="#GetTempDirectory()#/#name#" />
				<cfcatch type="any">
					<cfset console("------------ ERROR REMOVING TEMP FILE : #GetTempDirectory()#/#name# !!!!!!!!!!!!!!!!!!!!!!!!!")>
					<cfset console(cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>
	  </cfloop>
	  <cfcatch type="any">
		<cfset consoleoutput(true)>
		<cfset console("------------ ERROR REMOVING TEMP FILES !!!!!!!!!!!!!!!!!!!!!!!!!")>
		<cfset console(cfcatch)>
	  </cfcatch>
	</cftry>

	<cfset console("---------------FINISHED---------------------")>

  </cffunction>

</cfcomponent>