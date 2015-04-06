<cfsilent>

	<!---

		OpenBD Manual API: To get details on a tag or function, returned in JSON format

		Formart is: /manual/api/?/ {function / tag} / {tag (cfparam) or function (arrayappend) }

		Examples:

			To get details for function arrayappend function:

			http://www.openbd.org/manual/api/?/function/arrayappend

			To get details for tag CFPARAM :

			http://www.openbd.org/manual/api/?/tag/cfparam

	--->

<cfscript>

	api 				= new index();
	pageName 		= cgi.QUERY_STRING;

	if ( pageName.startsWith("/") ) {
		pageName 	= LCase( pageName.substring(1) );
	}

	part				= ListToArray( pageName, "/" );

	if ( arrayLen( part ) == 0 ) {
		apidata 	= {};
	} else if ( arrayLen( part ) == 1 ) {
		apidata 	= { "info.error" : "You need to pass through two paramters eg. /tag/cfparam" };
	} else {
		apidata 	= api.details( part[1] , part[2] );
	}

</cfscript>
</cfsilent>

<cfif ( !StructIsempty( apidata ) ) >
<cfheader name="Access-Control-Allow-Origin" value="*" />
<cfheader name="Content-type" value="application/json" />
<cfoutput>
	#serializeJSON(apidata)#
</cfoutput>

<cfelse>

	<cfinclude template="api.inc" />

</cfif>
