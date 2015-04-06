<cferror template="error.cfm" type="exception">
<cfsilent>

	<cfapplication name="openbdmanual" sessionmanagement="false" clientmanagement="false">
	
	<cfif NOT StructKeyExists( application, "docs" )>
		<cfset application.docs	= CreateObject("component","docs").init()>
	</cfif>

</cfsilent>