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
		<!--- settings save --->
		<cfset add_action(pid="#this.myID#", action="settings_save", comp="settings", func="setsettings")>
		<!--- Load this on the main page --->
		<cfset add_action(pid="#this.myID#", action="on_main_page", comp="page", func="start")>
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

		<!--- Create table --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_mytable
			(
				id 		#theint#, 
				w_test	#thevarchar#(200)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="database">Maybe add an alter or update execution in here</cfcatch>
		</cftry>

	</cffunction>

</cfcomponent>