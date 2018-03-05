<cfset self = myFusebox.getSelf() />
<cfset myself = myFusebox.getMyself() />
<cfset theaction = application.fusebox.fuseactionVariable />

<!--- Check Config --->
<cfinvoke component="global.cfc.settings" method="getconfigdefaultadmin" pathoneup="#expandPath("../")#" />

<!--- The WEBROOT --->
<cfset webroot = #rereplacenocase("#cgi.PATH_INFO#", "[a-z_]+.cfm", "", "ALL")#>

<!--- Dynamic path --->
<cfset dynpath="#cgi.context_path#">

<!--- PATH OF ONE DIR ABOVE THIS ONE --->
<cfset pathoneup=ExpandPath("../")>

<cfset thisPath=ExpandPath(".")>

<!--- Set global params --->
<cfparam name="fa" default="">

<!--- Set global params --->
<cfparam name="attributes.to" default="">

<cfif structkeyexists(session,"hostid") AND session.hostid EQ "">
	<cfset session.hostid = 1>
</cfif>

<cfparam name="session.hostid" default="1">
<cfparam name="cookie.loginnameadmin" default="">
<cfparam name="cookie.loginpassadmin" default="">
<cfparam name="session.offset" default="0">
<cfparam name="session.rowmaxpage" default="25">

<!--- Set the session for the language --->
<cfparam name="session.locale" type="string" default="en">
<cfparam name="session.thelang" default="English">

<!--- Set the session for the login --->
<cfparam name="session.login" default="F">

<!--- Set the session for the domain prefix --->
<cfset session.hostdbprefix="raz1_">

<!--- Set this app --->
<cfparam name="session.thisapp" default="admin">

<!--- Set HTTP or HTTPS --->
<cfif cgi.https EQ "on" OR cgi.http_x_https EQ "on" OR cgi.http_x_forwarded_proto EQ "https">
	<cfset session.thehttp = "https://">
<cfelse>
	<cfset session.thehttp = "http://">
</cfif>

<!--- Call the default components which we need on every page. To do this the FB way is quite cubersome --->
<!--- <cfinvoke component="global.cfc.defaults" method="init" returnvariable="defaultsObj" /> --->

<!--- Log User Out when Session.login has expired. Timeout of Sessions is set above --->
<cfif not IsDefined("Attributes.fa") or (Attributes.fa neq "c.login" and Attributes.fa neq "c.dologin" AND attributes.fa NEQ "c.forgotpass" AND attributes.fa NEQ "c.forgotpasssend" AND attributes.fa NEQ "c.switchlang" AND attributes.fa DOES NOT CONTAIN "update" AND application.razuna.firsttime NEQ "true" AND attributes.fa NEQ "c.runschedbackup" AND attributes.fa NEQ "c.logoff" AND attributes.fa NEQ "c.folder_subscribe_task" AND attributes.fa DOES NOT CONTAIN "c.w_")>
	<cfif NOT structkeyexists(session,"login") OR session.login EQ "F" OR NOT structkeyexists(session,"thelang") OR NOT structkeyexists(session,"hostid")>
		<script language="javascript" type="text/javascript">
			top.location.href = "<cfoutput>#self#?c.logoff</cfoutput>";
		</script>
		<cfabort> 
	</cfif>
</cfif>
