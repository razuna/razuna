<cfcomponent output="false">

<cfscript>
// Further details: http://openbd.org/manual/?/app_application_cfc

// The name of the application
this.name								= "bootstrapcfmlapp";

// We wish to enable the session managment
this.sessionmanagement 	= true;

// Sets the session timeout to be 1 hour; when logged in we will make the timeout 1 hour
this.sessiontimeout 		= CreateTimeSpan( 0, 1, 0, 0 );
</cfscript>



<!--- ---------------------------------------------
	This is where we can set some variables for the application scope

	http://openbd.org/manual/?/app_application
	--->
<cffunction name="onApplicationStart">
	<cfset application.starttime	= now()>
</cffunction>



<!--- ---------------------------------------------
	This is called for each request

	http://openbd.org/manual/?/app_application
	--->
<cffunction name="onRequestStart">
	<cfargument name="uri" required="true"/>


	<!---
		This tells the browser never to cache the secure pages so people are prevented from going
		'back' in their browser history to see this page
		--->
	<cfheader name="Cache-Control" value="no-cache,no-store,must-revalidate">
	<cfheader name="Pragma" value="no-cache">
	<cfheader name="Expires" value="Tues, 13 Sep 2011 00:00:00 GMT">

	<cfif StructKeyExists(form, "_user") && StructKeyExists(form, "_pass")>
		<!---	User is attempting to login at this point; we call one of the login functions	--->
		<cfif logInUserSimple( form._user, form._pass )>
			<cfset session.loggedin = true>
		<cfelse>
			<cfset StructDelete(session,"loggedin")>
			<cfset session.error	= "incorrect username or password">
			<cfset location("..")>
		</cfif>
	</cfif>


	<!---
		We do a check to make sure the user is still logged in; if not we throw
		them back to the main page
		--->
	<cfif !StructKeyExists( session, "loggedin" )>
		<cfset session.error	= "session has expired">
		<cfset location("..")>
	</cfif>

</cffunction>



<!--- ----------------------------------------------------------------------
	A very basic login script that will simply authenticate against some hardcoded
	values; not at all practical and only here for demonstration purposes
	--->
<cffunction name="logInUserSimple" returntype="boolean" access="private">
	<cfargument name="username" required="true"/>
	<cfargument name="password" required="true" />

	<cfif arguments.username == "demo" && arguments.password == "password">
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>

</cffunction>



<!--- ----------------------------------------------------------------------
	This one will authenticate against a table in a remote database; let us assume
	the database is under the datasource "mydatabase" and the table has fields:

	username varchar(32)
	password varchar(32) which is an MD5 of the password

	You should _never_ store the raw password in the database, instead think of
	storing it as an MD5/SHA1 with a unique salt against it.  Usually you use their
	username and another token as their salt.  That way every user does not have the
	same salt.  Making it hard to do a reverse dictionary lookup.

	This will then return back that particular users row as a structure and put it
	in the session scope for later retrieval
	--->
<cffunction name="logInUserDatabase" returntype="boolean" access="private">
	<cfargument name="username" required="true"/>
	<cfargument name="password" required="true" />

	<cfset var qry = true>
	<cfquery name="qry" datasource="mydatabase">
		select
			*
		from
			myusertable
		where
			username	= <cfqueryparam value="#LCase(arguments.username)#" />
			and password = MD5(<cfqueryparam value="#arguments.password#" />)
	</cfquery>

	<cfif qry.recordcount == 0>
		<cfreturn false>
	<cfelse>
		<cfset session.userrecord = QueryRowstruct( qry, 1 )>
		<cfreturn true>
	</cfif>
</cffunction>


</cfcomponent>