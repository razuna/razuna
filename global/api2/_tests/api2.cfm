<!--- 

--- TEST API --- 
Please set your API keys below and run this template to test if all API calls check out successfully.
Some API calls can be modified.

--->

<!--- SET API KEY --->
<cfset apikey_admin = "EA65B1C041E348AFAB9672353A0243DD"> <!--- Admin --->
<cfset apikey_sysadmin = "6A6773CD3F35482585C31EB2B00F34BB"> <!--- SYS Admin --->
<cfset apikey_user = ""> <!--- User --->

<!--- SET URL OF API --->
<cfset apiurl = "http://razunabd.local:8080/global/api2/">

<!--- Group ID --->
<cfset grpid = "13E33EB4-4A82-4CF7-B1DAA549DA80E86B">

<!--- FILE ID --->
<cfset assetid = "ABD7016F474F48BAA6094C9B499622F5">
<cfset assettype = "img">

<!--- ----------------------------------------------------------------------------- --->
<!--- NOTHING ELSE FOR YOU TO DO HERE --->
<!--- ----------------------------------------------------------------------------- --->

<cfflush>

<!--- HOSTS --->

<cfoutput><h1>Hosts</h1></cfoutput>

<!--- Get Hosts --->
<cfhttp url="#apiurl#hosts.cfc?method=gethosts&api_key=#apikey_sysadmin#"></cfhttp>
<cfoutput>
	<strong>getHosts (as System Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Get Size of Hosts --->
<cfhttp url="#apiurl#hosts.cfc?method=gethostsize&api_key=#apikey_sysadmin#"></cfhttp>
<cfoutput>
	<strong>getHostSize (as System Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- GROUPS --->

<cfoutput><h1>Groups</h1></cfoutput>

<!--- Get one --->
<cfhttp url="#apiurl#group.cfc?method=getone&api_key=#apikey_sysadmin#&grp_id=#grpid#"></cfhttp>
<cfoutput>
	<strong>getOne (as System Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>
<!--- Get one --->
<cfhttp url="#apiurl#group.cfc?method=getone&api_key=#apikey_admin#&grp_id=#grpid#"></cfhttp>
<cfoutput>
	<strong>getOne (as Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Get all --->
<cfhttp url="#apiurl#group.cfc?method=getall&api_key=#apikey_sysadmin#"></cfhttp>
<cfoutput>
	<strong>getAll (as System Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>
<!--- Get all --->
<cfhttp url="#apiurl#group.cfc?method=getall&api_key=#apikey_admin#"></cfhttp>
<cfoutput>
	<strong>getAll (as Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- getusersofgroups --->
<cfhttp url="#apiurl#group.cfc?method=getusersofgroups&api_key=#apikey_sysadmin#&grp_id=#grpid#"></cfhttp>
<cfoutput>
	<strong>getusersofgroups (as System Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>
<!--- getusersofgroups --->
<cfhttp url="#apiurl#group.cfc?method=getusersofgroups&api_key=#apikey_admin#&grp_id=#grpid#"></cfhttp>
<cfoutput>
	<strong>getusersofgroups (as Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Add Group --->
<cfhttp url="#apiurl#group.cfc?method=add&api_key=#apikey_admin#&grp_name=TESTGROUP"></cfhttp>
<!--- Deserialize JSON --->
<cfset jsonstructaddgroup = deserializeJSON(cfhttp.filecontent)>
<cfoutput>
	<strong>Add Group "TESTGROUP" (as Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
	<cfif jsonstructaddgroup.responsecode NEQ "1">
		Added group with ID: #jsonstructaddgroup.grp_id#
	</cfif>
</cfoutput>
<cfdump var="#jsonstructaddgroup#">
<br>
<cfflush>

<!--- Only execute below if we could add a group successfully --->
<cfif jsonstructaddgroup.responsecode NEQ "1">
	<!--- The groupid  --->
	<cfset groupidtemp = jsonstructaddgroup.grp_id>
	<!--- update group --->
	<cfhttp url="#apiurl#group.cfc?method=update&api_key=#apikey_admin#&grp_id=#groupidtemp#&grp_name=TESTGROUP-CHANGED"></cfhttp>
	<cfoutput>
		<strong>Updated Group "TESTGROUP" (as Admin)</strong>
		<br>
		#cfhttp.filecontent#
		<br>
	</cfoutput>
	<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
	<cfdump var="#jsonstruct#">
	<br>
	<cfflush>
	<!--- Delete group --->
	<cfhttp url="#apiurl#group.cfc?method=delete&api_key=#apikey_admin#&grp_id=#groupidtemp#"></cfhttp>
	<cfoutput>
		<strong>Delete Group "TESTGROUP" (as Admin)</strong>
		<br>
		#cfhttp.filecontent#
		<br>
	</cfoutput>
	<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
	<cfdump var="#jsonstruct#">
	<br>
	<cfflush>
</cfif>

<!--- USERS --->

<cfoutput><h1>Users</h1></cfoutput>

<!--- get user --->
<cfhttp url="#apiurl#user.cfc?method=getuser&api_key=#apikey_admin#"></cfhttp>
<cfoutput>
	<strong>Get User - yourself (as Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Add user --->
<cfhttp url="#apiurl#user.cfc?method=add&api_key=#apikey_admin#&user_first_name=test&user_last_name=user&user_email=test@email.com&user_name=testuserapi&user_pass=apitest&user_active=f&groupid=2"></cfhttp>
<!--- Deserialize JSON --->
<cfset jsonstructadduser = deserializeJSON(cfhttp.filecontent)>
<cfoutput>
	<strong>add user (as Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Only execute below if we could add user successfully --->
<cfif jsonstructadduser.responsecode NEQ "1">
	<!--- The userid  --->
	<cfset useridtemp = jsonstructadduser.userid>
	<cfset j = arrayNew(2)>
	<cfset j[1][1] = "user_first_name">
	<cfset j[1][2] = "Joe">
	<cfset j[2][1] = "user_last_name">
	<cfset j[2][2] = "Banana">
	<cfset j = SerializeJSON(j)>
	<!--- Update user --->
	<cfhttp url="#apiurl#user.cfc?method=update">
		<cfhttpparam name="api_key" value="#apikey_admin#" type="url" />
		<cfhttpparam name="userid" value="#useridtemp#" type="url" />
		<cfhttpparam name="userdata" value="#j#" type="url" />
	</cfhttp>
	<!--- <cfhttp charset="utf-8" method="post" url="#apiurl#user.cfc?method=update&api_key=#apikey_admin#&userid=#useridtemp#&userdata=#j#"></cfhttp> --->
	<cfoutput>
		<strong>Update user (as Admin)</strong>
		<br>
		#cfhttp.filecontent#
		<br>
	</cfoutput>
	<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
	<cfdump var="#jsonstruct#">
	<br>
	<cfflush>
	<!--- Delete User --->
	<cfhttp url="#apiurl#user.cfc?method=delete&api_key=#apikey_admin#&userid=#useridtemp#"></cfhttp>
	<cfoutput>
		<strong>Delete user (as Admin)</strong>
		<br>
		#cfhttp.filecontent#
		<br>
	</cfoutput>
	<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
	<cfdump var="#jsonstruct#">
	<br>
	<cfflush>
</cfif>

<!--- CUSTOM FIELDS --->

<cfoutput><h1>Custom Fields</h1></cfoutput>

<!--- Get All --->
<cfhttp url="#apiurl#customfield.cfc?method=getall&api_key=#apikey_admin#"></cfhttp>
<cfoutput>
	<strong>Get all fields (as Admin)</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Set --->
<cfhttp url="#apiurl#customfield.cfc?method=setfield&api_key=#apikey_admin#&field_text=fromapi&field_type=text"></cfhttp>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfset customfieldid = jsonstruct.field_id>
<cfoutput>
	<strong>Add new custom field (as Admin)</strong>
	<br>
	Added new custom field (#customfieldid#)
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Set Metadata --->
<cfset j = arrayNew(2)>
<cfset j[1][1] = customfieldid>
<cfset j[1][2] = "value from API">
<cfset j = SerializeJSON(j)>
<cfhttp url="#apiurl#customfield.cfc?method=setfieldvalue">
	<cfhttpparam name="api_key" value="#apikey_admin#" type="url" />
	<cfhttpparam name="assetid" value="#assetid#" type="url" />
	<cfhttpparam name="field_values" value="#j#" type="url" />
</cfhttp>
<cfoutput>
	<strong>Set fields of asset</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Get fields of asset --->
<cfhttp url="#apiurl#customfield.cfc?method=getfieldsofasset&api_key=#apikey_admin#&asset_id=#assetid#"></cfhttp>
<cfoutput>
	<strong>Get fields of asset</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- COMMENTS --->

<!--- Getall --->
<cfhttp url="#apiurl#comment.cfc?method=getall&api_key=#apikey_admin#&id=#assetid#&type=#assettype#"></cfhttp>
<cfoutput>
	<strong>Get comments</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Get One --->
<cfhttp url="#apiurl#comment.cfc?method=get&api_key=#apikey_admin#&id=#assetid#"></cfhttp>
<cfoutput>
	<strong>Get one comment</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Set --->
<cfhttp url="#apiurl#comment.cfc?method=set&api_key=#apikey_admin#&id_related=#assetid#&type=#assettype#">
	<cfhttpparam name="comment" value="A new comment from the API" type="url" />
</cfhttp>
<cfoutput>
	<strong>Add comment</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfset commentid = jsonstruct.id>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- Remove --->
<cfhttp url="#apiurl#comment.cfc?method=remove&api_key=#apikey_admin#&id=#commentid#"></cfhttp>
<cfoutput>
	<strong>Remove comment</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<br>
<cfflush>

<!--- LABELS --->

<!--- getlabelofasset --->
<!--- <cfhttp url="#apiurl#label.cfc?method=getlabelofasset&api_key=#apikey#&asset_id=BB59AB4D207F41C79408E5DC04B8651A&asset_type=img"></cfhttp> --->

<!--- getassetsoflabel --->
<!--- <cfhttp url="#apiurl#label.cfc?method=getassetoflabel&api_key=#apikey#&label_id=2CCD111DD3B14E58AE4FB0062809866C"></cfhttp> --->

<!--- setassetlabel --->
<!--- <cfhttp url="#apiurl#label.cfc?method=setassetlabel&api_key=#apikey#&label_id=2CCD111DD3B14E58AE4FB0062809866C&asset_id=6E7D588C81B742AB89C181BF9969784A&asset_type=img"></cfhttp> --->











<!--- Set Metadata Bulk
<cfset j = arrayNew(2)>
<cfset a = arrayNew(2)>
<!--- The ID --->
<cfset j[1][1] = "1ABB08AA3B47402CB4BF1B398F4CD6F8">
<!--- The Custom values --->
<cfset a[1][1] = "FB3489CC-059E-424F-B448371E18DDE6A6">
<cfset a[1][2] = "api val 110">
<cfset a[2][1] = "F72A20FE-D5EC-4CF0-98C689F6FE87CCB9">
<cfset a[2][2] = "api val 222">
<!--- Add value into second array --->
<cfset j[1][2] = a>
<!--- The ID --->
<cfset j[2][1] = "BB59AB4D207F41C79408E5DC04B8651A">
<!--- The Custom values --->
<cfset a[1][1] = "FB3489CC-059E-424F-B448371E18DDE6A6">
<cfset a[1][2] = "api val 333">
<cfset a[2][1] = "F72A20FE-D5EC-4CF0-98C689F6FE87CCB9">
<cfset a[2][2] = "api val 444">
<!--- Add value into second array --->
<cfset j[2][2] = a>

<cfset x = serializeJSON(j)>

<cfloop from="1" to="10" index="i">
	


<cfhttp url="#apiurl#customfield.cfc?method=setfieldvaluebulk">
	<cfhttpparam name="api_key" value="#apikey#" type="url" />
	<cfhttpparam name="field_values" value="#x#" type="url" />
</cfhttp>

<cfdump var="#cfhttp.filecontent#"><br />

<cfhttp url="#apiurl#customfield.cfc?method=setfieldvaluebulk">
	<cfhttpparam name="api_key" value="#apikey#" type="url" />
	<cfhttpparam name="field_values" value="#x#" type="url" />
</cfhttp>



<!--- SEARCH --->

<!--- <cfhttp url="#apiurl#search.cfc?method=searchassets&api_key=#apikey#&searchfor=*"></cfhttp> --->

<!--- <cfhttp url="#apiurl#search.cfc?method=searchassets&api_key=#apikey#&searchfor=audrey&folderid=587E9410C38A4698BDFF1E90F42C272C&show=img&__BDRETURNFORMAT=jsonp&callback=jQuerytest"></cfhttp> --->

<!--- Testing the internal query to lucene --->
<!--- <cfhttp url="http://razunabd.local:8080/global/cfc/lucene.cfc">
	<cfhttpparam name="method" value="search" type="url" />
	<cfhttpparam name="criteria" value="customfieldvalue:(+FB3489CC-059E-424F-B448371E18DDE6A6 +val*)" type="url" />
	<cfhttpparam name="category" value="img" type="url" />
	<cfhttpparam name="hostid" value="1" type="url" />
</cfhttp>

<cfwddx action="wddx2cfml" input="#cfhttp.filecontent#" output="qrylucene" /> --->

<!--- Custom field search --->
<!--- <cfhttp url="#apiurl#search.cfc">
	<cfhttpparam name="method" value="searchassets" type="url" />
	<cfhttpparam name="api_key" value="#apikey#" type="url" />
	<cfhttpparam name="searchfor" value="customfieldvalue:(+FB3489CC-059E-424F-B448371E18DDE6A6 +val*)" type="url" />
</cfhttp> --->

<!--- <cfhttp url="http://10.2.4.14/razuna/global/api2/search.cfc">
	<cfhttpparam name="method" value="searchassets" type="url" />
	<cfhttpparam name="api_key" value="5EDDE693362A446D84FCE8110879A594" type="url" />
	<cfhttpparam name="searchfor" value="customfieldvalue:(+45A1CE66-2713-433A-94F791100CFB222C +2107229)" type="url" />
</cfhttp> --->

<!--- UI SEARCH --->
<!--- <cflocation url="http://razunabd.local:8080/raz1/dam/index.cfm?fa=c.view_custom&showpart=search&api_key=#apikey#&searchfor=h*&show=all&access=r&folderid=D897F2B3BBC6492383CBA6DB46DA5927" /> --->

<!--- <cflocation url="http://razunabd.local:8080/raz1/dam/index.cfm?fa=c.view_custom&showpart=folder&access=w&api_key=EA65B1C041E348AFAB9672353A0243DD&folderid=6A76A6FC256048199DEF3C6536E0BD45&showsubfolders=F" /> --->

<!--- <cfhttp url="#apiurl#search.cfc">
	<cfhttpparam name="method" value="searchassets" type="url" />
	<cfhttpparam name="api_key" value="#apikey#" type="url" />
	<cfhttpparam name="searchfor" value="343*" type="url" />
	<cfhttpparam name="folderid" value="D897F2B3BBC6492383CBA6DB46DA5927" type="url" />
	<cfhttpparam name="dbdirect" value="true" type="url" />
</cfhttp> --->





<!--- ASSETS --->

<!--- Get Asset --->
<!--- <cfhttp url="#apiurl#asset.cfc?method=getasset&api_key=#apikey#&assetid=36ECD57F52B04E8CAA2AD18CB462802F&assettype=img"></cfhttp> --->

<!--- Set Metadata --->
<!--- <cfset j = arrayNew(2)>
<cfset j[1][1] = "file_name">
<cfset j[1][2] = "Denise">
<!--- <cfset j[2][1] = "lang_id_r">
<cfset j[2][2] = "1"> --->

<cfset j = SerializeJSON(j)>

<cfhttp url="#apiurl#asset.cfc?method=setmetadata">
	<cfhttpparam name="api_key" value="#apikey#" type="url" />
	<cfhttpparam name="assetid" value="6203F996347A452D9C3F295CFF4AC493" type="url" />
	<cfhttpparam name="assettype" value="img" type="url" />
	<cfhttpparam name="assetmetadata" value="#j#" type="url" />
</cfhttp> --->

<!--- getrenditions --->
<!--- <cfhttp url="#apiurl#asset.cfc?method=getrenditions&api_key=#apikey#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<cfoutput>
	<strong>getRenditions</strong>
	<br>
	#cfhttp.filecontent#
	<br>
</cfoutput>
<br>
<cfflush> --->

<!--- move --->
<!--- <cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey#&assetid=#assetid#&destination_folder=7405A6474800468583EC933B0C703545"></cfhttp> --->

<!--- COLLECTIONS --->

<!--- Search --->
<!--- <cfhttp url="#apiurl#collection.cfc?method=search&api_key=#apikey#&released=true"></cfhttp> --->

<!--- Get collections --->
<!--- <cfhttp url="#apiurl#collection.cfc?method=getcollections&api_key=#apikey#&folderid=D62A445A09E348D782C4DA80B66D0F58"></cfhttp>  --->

<!--- Get assets --->
<!--- <cfhttp url="#apiurl#collection.cfc?method=getassets&api_key=#apikey#&collectionid=07B7E56559B54E429E70F37BB68CB6E9"></cfhttp> --->

<!--- FOLDERS --->

<!--- Getfolders --->
<!--- <cfhttp url="#apiurl#folder.cfc?method=getfolders&api_key=#apikey#"></cfhttp> --->

<!--- Get single folder --->
<!--- <cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey#&folderid=8CAD593EF3C343DBAED80E149075C0C1"></cfhttp> --->

<!--- Get assets in folder --->
<!--- <cfhttp url="#apiurl#folder.cfc?method=getassets&api_key=#apikey#&folderid=35B513F47B6847B883DA5D81DBE56440&showsubfolders=false"></cfhttp> --->

<!--- <cfset j = arrayNew(2)>
<cfset j[1][1] = "EA4191FB6E0F40D2AFE3ABB85E41118A">
<cfset j[1][2] = "13E33EB4-4A82-4CF7-B1DAA549DA80E86B">
<cfset j[1][3] = "X">
<cfset j[2][1] = "EA4191FB6E0F40D2AFE3ABB85E41118A">
<cfset j[2][2] = "8931CF69-7FB1-476D-9D2B00F63D9D439A">
<cfset j[2][3] = "W">
<cfset j[3][1] = "EA4191FB6E0F40D2AFE3ABB85E41118A">
<cfset j[3][2] = "0">
<cfset j[3][3] = "W">

<cfset j = SerializeJSON(j)>

<!--- Set folder permission --->
<cfhttp url="#apiurl#folder.cfc?method=setFolderPermissions">
	<cfhttpparam name="api_key" value="#apikey#" type="url" />
	<cfhttpparam name="permissions" value="#j#" type="url" />
</cfhttp> --->

<!--- Search --->
<!--- <cfhttp url="#apiurl#search.cfc?method=searchindex&api_key=#apikey#"></cfhttp> --->



<cfabort>

