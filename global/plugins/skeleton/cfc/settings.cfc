<cfcomponent output="false" extends="global.cfc.api">

	<!--- Get Settings --->
	<cffunction name="getSettings" access="public" output="false">
		<cfreturn now() />
	</cffunction>

	<!--- This saves the settings --->
	<cffunction name="setSettings" access="public" output="false" returntype="struct">
		<cfargument name="args" required="true">


		<!--- We do not need to call and view a page --->
		<cfset result.page = false>
		<cfreturn result />
	</cffunction>

	<!--- Example: Call this CFC directly --->
	<cffunction name="setSettingsRemote" access="remote" output="false" returntype="struct" returnformat="JSON">
		<cfargument name="args" required="true">
		

		<!--- We need to return a struct!!! --->
		<cfset result.page = false>
		<cfreturn result />
	</cffunction>

</cfcomponent>