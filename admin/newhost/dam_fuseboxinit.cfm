<cfoutput>#('<cfset self = myFusebox.getSelf() />
<cfset myself = myFusebox.getMyself() />
<cfset theaction = application.fusebox.fuseactionVariable />

<!--- The WEBROOT --->
<cfset webroot = rereplacenocase(cgi.PATH_INFO, "[a-z_]+.cfm", "", "ALL")>

<!--- Dynamic path --->
<cfset dynpath = cgi.context_path>

<cfinvoke component="global.cfc.settings" method="readPackageJson" thenode="script_version" returnvariable="attributes.cachetag" />

<!--- PATH OF ONE DIR ABOVE THIS ONE --->
<cfset pathoneup = ExpandPath("../")>
<cfset pathoneup = replacenocase(pathoneup,"\","/","ALL")>

<cfset thisPath = ExpandPath(".")>

<!--- Application wide var for upload --->
<cfparam name="application.razuna.uploadcount" default="0">

<!--- Set global params --->
<cfparam name="fa" default="">
<cfparam name="session.offset" default="0">
<cfparam name="session.rowmaxpage" default="25">
<cfparam name="session.offset_log" default="0">
<cfparam name="session.rowmaxpage_log" default="25">
<cfparam name="session.offset_sched" default="0">
<cfparam name="session.rowmaxpage_sched" default="25">
<cfparam name="session.showsubfolders" default="F">
<cfparam name="nohost" default="F">
<cfparam name="cookie.loginname" default="">
<cfparam name="cookie.loginpass" default="">
<cfparam name="session.theuserid" default="0">
<cfparam name="session.view" default="">
<cfparam name="session.sortby" default="name">

<!--- Set the session for the language --->
<cfparam name="session.thelang" default="English">
<cfparam name="session.thelangid" default="1">
<cfparam name="session.locale" type="string" default="en">

<!--- Set the session for the login --->
<cfparam name="session.login" default="F">
<cfparam name="session.firstlastname" default="">
<cfparam name="session.is_system_admin" default="false">
<cfparam name="session.is_administrator" default="false">

<!--- Set this app --->
<cfparam name="session.thisapp" default="dam">

<cfif attributes.fa CONTAINS "share" OR structkeyexists(attributes,"fromshare")>
	<cfset session.fromshare = true>
<cfelse>
	<cfset session.fromshare = false>
</cfif>

<!--- Set HTTP or HTTPS --->
<cfif cgi.https EQ "on" OR cgi.http_x_https EQ "on" OR cgi.http_x_forwarded_proto EQ "https">
	<cfset session.thehttp = "https://">
<cfelse>
	<cfset session.thehttp = "http://">
</cfif>

<cfif application.razuna.isp>
<!--- Parse the subdomain name --->
<cfset thename = cgi.http_host>
<cfset thecount = findoneof(".",thename) - 1>
<cfif thecount LT 0>
	<cfoutput><h2>No host with this URL could be found!</h2></cfoutput>
	<cfflush>
	<cfabort>
</cfif>
<cfset thesubdomain = mid(cgi.HTTP_HOST,1,thecount)>
<cfquery datasource="##application.razuna.datasource##" name="thehost" cachedwithin="##CreateTimeSpan(0,1,0,0)##">
SELECT /* ##thename## */ host_id, host_name, host_type, host_shard_group
FROM hosts
WHERE host_name_custom = <cfqueryparam cfsqltype="cf_sql_varchar" value="##thename##">
</cfquery>
<cfif thehost.recordcount EQ 0>
<cfquery datasource="##application.razuna.datasource##" name="thehost" cachedwithin="##CreateTimeSpan(0,1,0,0)##">
SELECT /* ##thesubdomain## */ host_id, host_name, host_type, host_shard_group
FROM hosts
WHERE host_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="##thesubdomain##">
</cfquery>
</cfif>
<cfif thehost.recordcount EQ 0>
<cflocation url="http://razuna.razuna.com?nohost=t" addtoken="false" />
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
<cfparam name="session.thecart" default="##createuuid("")##">

<!--- Log User Out when Session.login has expired. Timeout of Sessions is set above --->
<cfif NOT IsDefined("Attributes.fa") OR (Attributes.fa NEQ "c.login" AND Attributes.fa NEQ "c.dologin" AND Attributes.fa NEQ "c.login_janrain" AND attributes.fa NEQ "c.forgotpass" AND attributes.fa DOES NOT CONTAIN "c.req_" AND attributes.fa NEQ "c.forgotpasssend" AND attributes.fa NEQ "c.switchlang" AND attributes.fa NEQ "c.sv" AND attributes.fa NEQ "c.si" AND attributes.fa NEQ "c.sa" AND attributes.fa NEQ "c.sf" AND attributes.fa NEQ "c.asset_upload" AND attributes.fa DOES NOT CONTAIN "c.view_" AND attributes.fa NEQ "c.logout" AND attributes.fa NEQ "c.apiupload" AND attributes.fa DOES NOT CONTAIN "share" AND attributes.fa NEQ "c.scheduler_doit" AND attributes.fa NEQ "c.w" AND attributes.fa DOES NOT CONTAIN "c.w_" AND attributes.fa DOES NOT CONTAIN "c.mini" AND attributes.fa DOES NOT CONTAIN "widget" AND attributes.fa DOES NOT CONTAIN "basket" AND attributes.fa NEQ "c.serve_file" AND attributes.fa NEQ "c.rfs" AND attributes.fa NEQ "c.search_simple_custom" AND attributes.fa DOES NOT CONTAIN "c.store_" AND attributes.fa DOES NOT CONTAIN "c.meta_" AND attributes.fa NEQ "c.asset_add_single" AND attributes.fa NEQ "c.asset_add_upload" AND attributes.fa NEQ "c.folder_subscribe_task")>
	<cfif NOT isdefined("session.login") OR session.login EQ "F" OR NOT isdefined("session.thelang") OR NOT isdefined("session.theuserid")>
		<script language="javascript" type="text/javascript">
			top.location.href = "<cfoutput>##myself##</cfoutput>c.logout";
		</script>
		<cfabort> 
	</cfif>
</cfif>

')#</cfoutput>