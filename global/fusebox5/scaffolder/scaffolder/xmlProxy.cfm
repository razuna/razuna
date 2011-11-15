<cfsilent>
<!--- I retrieve an XML object from the metadata CFC and send to the browser as XML --->
<cfparam name="url.username" default="">
<cfparam name="url.password" default="">
<cfinvoke component="Metadata" method="getTablesAsXML" returnvariable="xTables">
    <cfinvokeargument name="datasource" value="#url.datasource#">
    <cfif isDefined("url.username")><cfinvokeargument name="username" value="#url.username#"></cfif>
    <cfif isDefined("url.password")><cfinvokeargument name="password" value="#url.password#"></cfif>
</cfinvoke>     
     
<cfset xmlOutput = toString(xTables)>
<cfsetting showdebugoutput="No">
</cfsilent><cfcontent reset="yes" type="text/xml"><cfoutput>#xmlOutput#</cfoutput>