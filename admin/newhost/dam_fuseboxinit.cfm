<cfoutput>#('<cfset self = myFusebox.getSelf() />
<cfset myself = myFusebox.getMyself() />
<cfset theaction = application.fusebox.fuseactionVariable />

<!--- Set the name of the default datasource --->
<cfobject component="global.cfc.settings" name="settingsobj">

<!--- Check Config --->
<cfset settingsObj.getconfigdefault()>

<!--- The WEBROOT --->
<cfset webroot = rereplacenocase(cgi.PATH_INFO, "[a-z_]+.cfm", "", "ALL")>

<!--- Dynamic path --->
<cfset dynpath="##cgi.context_path##">

<!--- PATH OF ONE DIR ABOVE THIS ONE --->
<cfset pathoneup=ExpandPath("../")>
<cfset pathoneup=replacenocase(pathoneup,"\","/","ALL")>

<cfset thisPath=ExpandPath(".")>

<!--- Set global params --->
<cfparam name="fa" default="">
<cfparam name="attributes.offset" default="0">
<cfparam name="attributes.rowmaxpage" default="25">
<cfparam name="session.showsubfolders" default="F">
<cfparam name="session.theuserid" default="0">
<cfparam name="nohost" default="F">
<cfparam name="cookie.loginname" default="">
<cfparam name="cookie.loginpass" default="">

<!--- Set global params --->
<cfparam name="attributes.to" default="">

<!--- Set the session for the language --->
<cfparam name="session.thelang" default="english">
<cfparam name="session.thelangid" default="1">

<!--- Set the session for the login --->
<cfparam name="session.login" default="F">

<!--- Set this app --->
<cfparam name="session.thisapp" default="dam">

<cfif attributes.fa CONTAINS "share">
	<cfset session.fromshare = "T">
<cfelse>
	<cfset session.fromshare = "F">
</cfif>

<!--- Set HTTP or HTTPS --->
<cfif cgi.HTTPS EQ "on" OR cgi.http_x_https EQ "on">
	<cfset variables.thehttp = "https://">
<cfelse>
	<cfset variables.thehttp = "http://">
</cfif>

<cfif application.razuna.isp>
<!--- Parse the subdomain name --->
<cfset thename = cgi.http_host>
<cfset thecount = findoneof(".",thename) - 1>
<cfset thesubdomain = mid(cgi.HTTP_HOST,1,thecount)>
<cfquery datasource="##application.razuna.datasource##" name="thehost" cachename="##thesubdomain##" cachedomain="hosts">
SELECT host_id, host_name, host_type, host_shard_group, host_name_custom
FROM hosts
WHERE (
lower(host_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="##lcase(thesubdomain)##">
OR lower(host_name_custom) = <cfqueryparam cfsqltype="cf_sql_varchar" value="##lcase(thename)##">
)
</cfquery>
<cfif thehost.recordcount EQ 0>
<cfset nohost = "T">
</cfif>
<!--- Set sessions --->
<cfset session.isbrowser = "T">
<cfset session.hostdbprefix = thehost.host_shard_group>
<cfset session.hostname = thehost.host_name>
<cfset session.hostid = thehost.host_id>
<cfset session.hosttype = thehost.host_type>
<cfset session.vidtable="##thehost.host_shard_group##videos">
<cfset session.audtable="##thehost.host_shard_group##audios">
<cfset session.imgtable="##thehost.host_shard_group##images">
<cfelse>
<!--- Set sessions --->
<cfset session.isbrowser = "F">
<cfset session.hostdbprefix = "#arguments.host_db_prefix_replace#">
<cfset session.hostid = #arguments.thisid#>
<cfset session.hosttype = "">
<cfset session.vidtable="#arguments.host_db_prefix_replace#videos">
<cfset session.audtable="#arguments.host_db_prefix_replace#audios">
<cfset session.imgtable="#arguments.host_db_prefix_replace#images">
</cfif>
<!--- Cart Session --->
<cfparam name="session.thecart" default="##createuuid()##">

<!--- Call the default components which we need on every page. To do this the FB way is quite cubersome --->
<cfinvoke component="global.cfc.defaults" method="init" returnvariable="defaultsObj">
	<cfinvokeargument name="dsn" value="##application.razuna.datasource##">
</cfinvoke>

<cfif StructKeyExists(session, "theuserid") AND session.theuserid NEQ "" AND StructKeyExists(Session, "hostid") AND isnumeric(session.hostid)>
	<!--- Component : SECURITY : stored in request scope for better performance--->
	<cfinvoke component="global.cfc.security" method="init" returnvariable="Request.securityobj" dsn="##application.razuna.datasource##" />
	<cfinvoke component="##Request.securityobj##" method="initUser" host_id="##Session.hostid##" user_id="##session.theuserid##" mod_short="ecp">
</cfif>

<!--- Log User Out when Session.login has expired. Timeout of Sessions is set above --->
<cfif NOT IsDefined("Attributes.fa") OR (Attributes.fa NEQ "c.login" AND Attributes.fa NEQ "c.dologin" AND attributes.fa NEQ "c.forgotpass" AND attributes.fa DOES NOT CONTAIN "c.req_" AND attributes.fa NEQ "c.forgotpasssend" AND attributes.fa NEQ "c.switchlang" AND attributes.fa NEQ "c.sv" AND attributes.fa NEQ "c.si" AND attributes.fa NEQ "c.sf" AND attributes.fa NEQ "c.asset_upload" AND attributes.fa DOES NOT CONTAIN "c.view_" AND attributes.fa NEQ "c.logout" AND attributes.fa NEQ "c.apiupload" AND attributes.fa DOES NOT CONTAIN "share" AND attributes.fa NEQ "c.scheduler_doit" AND attributes.fa NEQ "c.w" AND attributes.fa DOES NOT CONTAIN "c.w_" AND attributes.fa DOES NOT CONTAIN "c.mini" AND attributes.fa DOES NOT CONTAIN "widget" AND attributes.fa NEQ "c.serve_file" AND attributes.fa NEQ "c.rfs")>
	<cfif (NOT isdefined("session.login") OR NOT isdefined("session.thelang") OR NOT structkeyexists(request,"securityobj") OR NOT isdefined("session.theuserid"))>
		<script language="javascript" type="text/javascript">
			top.location.href = "<cfoutput>##myself##</cfoutput>c.logout";
		</script>
		<cfabort> 
	</cfif>
</cfif>

')#</cfoutput>