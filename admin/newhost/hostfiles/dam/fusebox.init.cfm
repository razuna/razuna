<!---
	fusebox.init.cfm is included by the framework at the start of every request.
	It is included within a cfsilent tag so it cannot generate output. It is
	intended to be for per-request initialization and manipulation of the
	Fusebox fuseaction variables.
	
	You can set attributes.fuseaction, for example, to override the default
	fuseaction.
	
	A typical usage is to set "self" and "myself" variables, as shown below,
	for use inside display fuses when creating links.

	Fusebox 5 and earlier - set variables explicitly:
	<cfset self = "index.cfm" />
	<cfset myself = "#self#?#myFusebox.getApplication().fuseactionVariable#=" />
	
	Fusebox 5.1 and later - set variables implicitly from the Fusebox itself.
	
	Could also modify the self location here:
	<cfset myFusebox.setSelf("/myapp/start.cfm") />
--->
<cfset self = myFusebox.getSelf() />
<cfset myself = myFusebox.getMyself() />
<cfset theaction = application.fusebox.fuseactionVariable />

<!--- Set the name of the default datasource --->
<CFOBJECT COMPONENT="global.cfc.settings" NAME="settingsObj">

<!--- Parse the database --->
<cfset session.thedatabase = #settingsObj.getconfig("database")#>
<!--- Parse the datasource --->
<cfset session.theschema = #settingsObj.getconfig("schema")#>
<!--- Parse the setting id --->
<cfset session.setid = #settingsObj.getconfig("setid")#>
<!--- Parse the storage --->
<cfset session.storage = #settingsObj.getconfig("storage")#>
<!--- Nirvanix AppKey --->
<cfset session.nvxappkey = settingsObj.getconfig("nirvanix_appkey")>
<!--- Nirvanix URL Services --->
<cfset session.nvxurlservices = settingsObj.getconfig("nirvanix_url_services")>

<cfif structkeyexists(session,"hostid") AND session.hostid EQ "">
	<cfset session.hostid = 0>
</cfif>

<cfparam name="session.hostid" default="0">

<!--- Set the global database connection name --->
<cfset globals.datasource = "#settingsobj.getconfig("datasource")#">

<!--- The WEBROOT --->
<cfset webroot = #rereplacenocase("#cgi.PATH_INFO#", "[a-z_]+.cfm", "", "ALL")#>

<!--- Dynamic path --->
<cfif listfirst(cgi.SCRIPT_NAME,"/") EQ "razuna">
	<cfset dynpath="/razuna">
<cfelse>
	<cfset dynpath="">
</cfif>

<!--- PATH OF ONE DIR ABOVE THIS ONE --->
<cfset pathoneup=ExpandPath("../")>

<cfset thisPath=ExpandPath(".")>

<!--- Set global params --->
<cfparam name="fa" default="">

<!--- Set global params --->
<cfparam name="attributes.to" default="">

<!--- Set the session for the language --->
<cfparam name="session.thelang" default="English">

<!--- Set the session for the login --->
<cfparam name="session.login" default="F">

<!--- Set the session for the domain prefix --->
<cfparam name="session.hostdbprefix" default="demo_">

<!--- Set this app --->
<cfparam name="session.thisapp" default="admin">

<!--- Call the default components which we need on every page. To do this the FB way is quite cubersome --->
<cfinvoke component="global.cfc.defaults" method="init" returnvariable="defaultsObj">
	<cfinvokeargument name="dsn" value="#globals.datasource#">
	<cfinvokeargument name="database" value="#session.thedatabase#">
</cfinvoke>

<cfscript>
// SES converter
arQrystring = ArrayNew(1);
if ( Find("/",cgi.path_info) eq 1 and Find("/index.cfm",cgi.path_info) eq 0 ) {
    qrystring = cgi.path_info;
    arQrystring = ListToArray(cgi.path_info,'/');
} else if ( Len(Replace(cgi.path_info,"#self#/","")) ) {
    qrystring = ListRest(Replace(cgi.path_info,"#self#/","#self#|"),"|");
    arQrystring = ListToArray(qrystring,"/");
} else if ( FindNoCase("#self#/",cgi.script_name) gt 0 ) {
    qrystring = ListRest(Replace(cgi.script_name,"#self#/","#self#|"),"|");
    arQrystring = ListToArray(qrystring,"/");
}
for ( q = 1 ; q lte ArrayLen(arQrystring) ; q = q + 2 ) {
    if ( q lte ArrayLen(arQrystring) - 1 and not ( arQrystring[ q ] is theaction and arQrystring[q+1] is self ) ) {
        attributes['#arQrystring[ q ]#'] = arQrystring[q+1];
    }
}
</cfscript>

<cfif StructKeyExists(Session, "theuserid") and Session.theuserid neq "" and StructKeyExists(Session, "hostid")>
	<!--- Component : SECURITY : stored in request scope for better performance--->
	<cftry>
		<cfinvoke component="global.cfc.security" method="init" returnvariable="Request.securityobj" dsn="#globals.datasource#" />
		<cfinvoke component="#Request.securityobj#" method="initUser" host_id="#Session.hostid#" user_id="#Session.theuserid#" mod_short="dsc">
		<cfcatch type="database"></cfcatch>
	</cftry>
</cfif>

<!--- Log User Out when Session.login has expired. Timeout of Sessions is set above --->
<cfif not IsDefined("Attributes.fa") or (Attributes.fa neq "c.login" and Attributes.fa neq "c.dologin" AND attributes.fa NEQ "c.forgotpass" AND attributes.fa NEQ "c.forgotpasssend" AND attributes.fa NEQ "c.switchlang")>
	<cfif NOT structkeyexists(session,"login") OR NOT structkeyexists(session,"thelang") OR NOT structkeyexists(session,"hostid") OR NOT structkeyexists(request,"securityobj")>
		<!--- <cflocation url="#self#?c.logoff" addtoken="false"> --->
		<!--- <CFHEADER NAME="Refresh" VALUE="0; URL=#self#?c.logoff"> --->
		<script language="javascript" type="text/javascript">
			top.location.href = "<cfoutput>#self#</cfoutput>?c.logoff";
		</script>
		<cfabort> 
	</cfif>
</cfif>

