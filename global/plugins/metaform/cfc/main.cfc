<cfcomponent output="false" extends="global.cfc.api">

	<!--- Set the ID of this plugin --->
	<cfset this.myID = getMyID("metaform")>

	<!--- 
	This runs when you activate the plugin and
	adds all the actions of the plugin
	--->
	<cffunction name="load" returntype="void">
		<!--- settings page --->
		<cfset add_action(pid="#this.myID#", action="settings", comp="settings", func="getsettings")>
		<!--- load on add --->
		<cfset add_action(pid="#this.myID#", action="on_file_add_done", comp="settings", func="loadForm")>
	</cffunction>

	<!--- 
	This runs when you activate the plugin and
	does all the actions to the database
	--->
	<cffunction name="db" returntype="void">
		<!--- Use simple database calls to do that --->
		<!--- The general razuna data source is available at: application.razuna.datasource --->
		<!--- You should wrap this in try/catch or add your own calls per version --->

		<!--- For MySQL you have to append the tableoptions here --->
		<cfset var tableoptions = "ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_bin">
		<!--- Detault types --->
		<cfset var theclob = "clob">
		<cfset var theint = "int">
		<cfset var thevarchar = "varchar">
		<cfset var thetimestamp = "timestamp">
		<!--- Map different types according to database --->
		<cfif application.razuna.thedatabase EQ "mysql">
			<cfset var theclob = "text">
		<cfelseif application.razuna.thedatabase EQ "mssql">
			<cfset var theclob = "NVARCHAR(max)">
			<cfset var thetimestamp = "datetime">
		<cfelseif application.razuna.thedatabase EQ "oracle">
			<cfset var theint = "number">
			<cfset var thevarchar = "varchar2">
		</cfif>
		<!--- Table --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_metaform 
			(
				mf_type		#thevarchar#(100),
				mf_value 	#thevarchar#(500),
				mf_order	#theint# DEFAULT '0',
				mf_cf		#thevarchar#(100),
				host_id		#theint#
			)
			<cfif application.razuna.thedatabase EQ "mysql">#tableoptions#</cfif>
			</cfquery>
			<cfcatch type="database">
				<cfset consoleoutput(true)>
				<cfset console(cfcatch)>
				Maybe add an alter or update execution in here
			</cfcatch>
		</cftry>

	</cffunction>

</cfcomponent>