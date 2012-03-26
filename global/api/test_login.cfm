<form action="<cfoutput>#cgi.SCRIPT_NAME#</cfoutput>" method="post">
<input type="hidden" name="passhashed" value="0">

<label>Installation</label>
<select name="thehost">
	<option value="local" selected="selected">Local</option>
	<option value="remote">Razuna.com</option>
	<option value="jedi">jedi</option>
</select>
<br>
<label>Hostname/HostID</label>
<input type="text" name="hostname">

<label>User</label>
<input type="text" name="user">

<label>Password</label>
<input type="password" name="pass">

<input type="submit" value="Send">

</form>

<cfif structkeyexists(form,"passhashed")>

	<cfif thehost EQ "local" OR thehost EQ "jedi">
		<cfif thehost EQ "local">
			<cfset thehttp = "http://razunabd.local:8080">
		<cfelse>
			<cfset thehttp = "http://jedi.razuna.org/razuna">
		</cfif>
		<cfhttp url="#thehttp#/global/api/authentication.cfc?callback=">
		    <cfhttpparam name="method" type="URL" value="login">
		    <cfhttpparam name="hostid" type="URL" value="#form.hostname#">
		    <cfhttpparam name="user" type="URL" value="#form.user#">
		    <cfhttpparam name="pass" type="URL" value="#form.pass#">
		    <cfhttpparam name="passhashed" type="URL" value="0">
		    <cfhttpparam name="__BDRETURNFORMAT" type="URL" value="jsonp">
		</cfhttp>
		<!---
<cfinvoke webservice="#thehttp#/global/api/authentication.cfc?wsdl" 
			method="login"
			hostid="#form.hostname#" 
			user="#form.user#" 
			pass="#form.pass#"  
			passhashed="0"
			returnVariable="xml">
--->
	<cfelseif thehost EQ "remote">
		<cfset thehttp = "http://api.razuna.com">
		<cfinvoke webservice="#thehttp#/global/api/authentication.cfc?wsdl" 
			method="loginhost"
			hostname="#form.hostname#"
			user="#form.user#" 
			pass="#form.pass#" 
			passhashed="0"
			returnVariable="xml">
	</cfif>

	<!---
<cfset thexml = xmlparse(xml)>
	<cfset thesearch = xmlsearch(thexml,"//sessiontoken")>
	<cfset thesessiontoken = thesearch[1].xmltext>
--->

<cfdump var="#cfhttp#">

<cfabort>

<!--- Update a user --->
<!---
<cfset u = arraynew(2)>
<cfset u[1][1] = "user_login_name">
<cfset u[1][2] = "updateduser">
<cfset u[2][1] = "user_first_name">
<cfset u[2][2] = "Update">
<cfset u[3][1] = "group_id">
<cfset u[3][2] = "FB78A863-27D7-4E06-A92CFF0696BB27A1">

<cfset thejson = SerializeJSON(u)>

<cfhttp url="#thehttp#/global/api/user.cfc">
    <cfhttpparam name="method" type="URL" value="update">
    <cfhttpparam name="sessiontoken" type="URL" value="#thesessiontoken#">
    <cfhttpparam name="userid" type="URL" value="">
    <cfhttpparam name="userloginname" type="URL" value="">
    <cfhttpparam name="useremail" type="URL" value="blog@razuna.com">
	<cfhttpparam name="userdata" type="URL" value="#thejson#">
</cfhttp>
<cfoutput>#cfhttp.filecontent#</cfoutput>
--->

<!--- Delete user --->
<cfhttp url="#thehttp#/global/api/user.cfc">
    <cfhttpparam name="method" type="URL" value="delete">
    <cfhttpparam name="sessiontoken" type="URL" value="#thesessiontoken#">
    <cfhttpparam name="userid" type="URL" value="">
    <cfhttpparam name="userloginname" type="URL" value="">
    <cfhttpparam name="useremail" type="URL" value="blog@razuna.com">
</cfhttp>
<cfoutput>#cfhttp.filecontent#</cfoutput>

<!---

<cfset myar = arraynew(2)>
<cfset myar[1][1] = "img_keywords">
<cfset myar[1][2] = "Razuna, Wordpress, Tomcat">
<cfset myar[2][1] = "img_description">
<cfset myar[2][2] = "Razuna Enterprise">
<cfset myar[3][1] = "lang_id_r">
<cfset myar[3][2] = "1">
<cfset myar[4][1] = "creator">
<cfset myar[4][2] = "Nitai Aventaggiato">
<cfset myar[5][1] = "title">
<cfset myar[5][2] = "CTO">
<cfset myar[6][1] = "authorsposition">
<cfset myar[6][2] = "out of this world">


<cfset thejson = SerializeJSON(myar)>

<cfdump var="#thejson#"><cfabort>

<cfhttp url="#thehttp#/global/api/asset.cfc">
    <cfhttpparam name="method" type="URL" value="addmetadata">
        <cfhttpparam name="sessiontoken" type="URL" value="#thesessiontoken#">
        <cfhttpparam name="assetid" type="URL" value="551ACD8BD8114BFA89EAA7B7B74357CB">
		<cfhttpparam name="assettype" type="URL" value="img">
		<cfhttpparam name="assetmetadata" type="URL" value="#thejson#">
	</cfhttp>
<cfoutput>#cfhttp.filecontent#</cfoutput>
--->


	<!---
<cfhttp url="http://razunabd.local:8080/global/api/folder.cfc">
		<cfhttpparam name="method" value="getassets" type="url">
		<cfhttpparam name="sessiontoken" value="#thesessiontoken#" type="url">
		<cfhttpparam name="folderid" value="1" type="url">
		<cfhttpparam name="showsubfolders" value="0" type="url">
		<cfhttpparam name="offset" value="0" type="url">
		<cfhttpparam name="maxrows" value="0" type="url">
		<cfhttpparam name="show" value="all" type="url">
	</cfhttp>
--->

<!---
Get one Folder
<cfhttp url="#thehttp#/global/api/folder.cfc">
    <cfhttpparam name="method" type="URL" value="getfolders">
    <cfhttpparam name="sessiontoken" type="URL" value="#thesessiontoken#">
    <cfhttpparam name="folderid" type="URL" value="0">
</cfhttp>
--->


<!---
<cfhttp url="#thehttp#/global/api/folder.cfc">
    <cfhttpparam name="method" type="URL" value="getfolderstree">
    <cfhttpparam name="sessiontoken" type="URL" value="#thesessiontoken#">
    <cfhttpparam name="e4x" type="URL" value="0">
</cfhttp>



<cfdump var="#cfhttp#"><cfabort>
--->
<!---
	
	<cfinvoke webservice="#thehttp#/global/api/folder.cfc?wsdl" 
	method="getassets" 
	sessiontoken="#thesessiontoken#"
	folderid="1" 
	showsubfolders="0" 
	offset="0" 
	maxrows="0"
	show="all"
	returnVariable="txml">
	
	<cfset thexml = xmlparse(txml)>
	
	<cfoutput>#thexml#</cfoutput>
--->
	
<!--- 	<cfdump var="#cfhttp.filecontent#"> --->

</cfif>