<cfcomponent output="false">

<cffunction name="get" returntype="any" access="remote" returnformat="json">
	<cfargument name="id">

	<cfset var arr 	= []>
	<cfif arguments.id == 0>
		<cfset arguments.id = "/">
	</cfif>

	<cfset var webpath	= arguments.id>
	<cfset var dirlist 	= true>

	<cfdirectory action="list" directory="#ExpandPath( webpath )#" name="dirlist" />

	<!--- Do the directories first --->
	<cfquery dbtype="query" name="dirOnly">select * from dirlist where type='Dir'</cfquery>
	<cfset QuerySort( dirOnly, "name", "TEXTNOCASE", "ASC" )>
	<cfset arr = buildNode( dirOnly, arr, webpath )>


	<cfquery dbtype="query" name="fileOnly">select * from dirlist where type='File'</cfquery>
	<cfset QuerySort( fileOnly, "name", "TEXTNOCASE", "ASC" )>
	<cfset arr = buildNode( fileOnly, arr, webpath )>

	<cfreturn arr>
</cffunction>



<cffunction name="buildNode" returntype="array">
	<cfargument name="dirlist">
	<cfargument name="arr">
	<cfargument name="webpath">

	<cfloop query="dirlist">
		<cfif type eq "file" && !name.endsWith(".cfc") && !name.endsWith(".cfm") && !name.endsWith(".inc")>
			<cfcontinue>
		</cfif>

		<cfset s = StructNew()>

		<cfset s.data									= {}>
		<cfset s.data.title 					= name>
		<cfset s.attributes 					= {}>
		<cfset s.attributes.id 				= webpath & name>
		<cfset s.attributes.filetype	= type>
		<cfset s.attributes.f 				= "">

		<cfif type eq "dir">
			<cfset s.state = "closed">
			<cfset s.attributes.id = s.attributes.id & "/">
		<cfelse>
			<cfset s.data.icon = "script">
			<cfset s.attributes.f = Replace( ExpandPath(webpath&name), "\", "/", "ALL" )>
		</cfif>

		<cfset ArrayAppend( arr, s )>
	</cfloop>

	<cfreturn arr>
</cffunction>


</cfcomponent>