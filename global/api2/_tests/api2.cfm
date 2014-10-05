<!--- 

--- TEST API --- 
Please set your API keys below and run this template to test if all API calls check out successfully.
Some API calls can be modified.
Refer to https://docs.google.com/a/razuna.com/document/d/1hHLI4vNgE3cjxgPAnp0VC5AJgMs-gxgVTDf9VTwTg_Q/edit?usp=sharing for documentation
--->

<!--- SET API KEY --->
<cfset apikey_admin = "9AACE5A4C5C04D87A6E6CB42F54ED912"> <!--- Admin --->
<cfset apikey_sysadmin = "C18990BD569A4C448ACA3D5CA185E4B2"> <!--- SYS Admin --->
<cfset apikey_user_perm = "170C2A450D374703A225B26C469CF2CD"> <!--- User with permission --->
<cfset apikey_user_noperm = "D65706752CFD4D9E91B0926DE58C6616"> <!--- User without permission --->

<!--- SET URL OF API --->
<cfset apiurl = "http://razunabd.local:8080/razuna/global/api2/">

<!--- Group ID --->
<cfset grpid = "6F6B0D39-A95F-4904-A9D6E254A9BA4263">

<!--- ASSET ID --->
<cfset assetid = "BDA9E906503D4B88881254101E1E7938">
<cfset assettype = "img">

<!--- FOLDERID --->
<cfset destination_folderid  = "09BEC2A0DCAD43DC9385C3E717E7B736">
<cfset original_folderid = "E686529185494864B4EDBA3BCFF910D1">
<cfset foldername  = "Test_Folder">

<!--- COLLECTIONID --->
<cfset collection_folderid = "427BB557EBC14A02BE7009591AB5E440">
<cfset collectionid = "D0CAE5C5296340DFACBE946D8D98318E">
<!--- PDF document --->
<cfset fileid = "50AF6049EB7143EA89DB89D8CD8FD19D">

<!--- Label --->
<cfset labelid = "18CA6512B5D94F8094B0CABB9013EA0F">

<!--- SEARCH TEXT --->
<cfset searchfor = "sync*">
<!--- ----------------------------------------------------------------------------- --->
<!--- NOTHING ELSE FOR YOU TO DO HERE --->
<!--- ----------------------------------------------------------------------------- --->

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

<cfoutput>

<!--- ############################ ASSETS #################################### --->
<h1>ASSETS</h1>

<!--- ************* GET ASSET ************** --->

<strong>getAsset(as System Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getasset&api_key=#apikey_sysadmin#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAsset(as Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getasset&api_key=#apikey_admin#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAsset(as User with Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getasset&api_key=#apikey_user_perm#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAsset(as User without Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getasset&api_key=#apikey_user_noperm#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush> 

<!--- ************* GET METADATA************** --->
<strong>getMetadata(as System Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getmetadata&api_key=#apikey_sysadmin#&assetid=#assetid#&assettype=#assettype#&assetmetadata=creator"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getMetadata(as Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getmetadata&api_key=#apikey_admin#&assetid=#assetid#&assettype=#assettype#&assetmetadata=creator"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getMetadata(as User with Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getmetadata&api_key=#apikey_user_perm#&assetid=#assetid#&assettype=#assettype#&assetmetadata=creator"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getMetadata(as User without Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getmetadata&api_key=#apikey_user_noperm#&assetid=#assetid#&assettype=#assettype#&assetmetadata=creator"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>


<!--- ************* GET RENDITIONS ************** --->
<strong>getRenditions(as System Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getrenditions&api_key=#apikey_sysadmin#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getRenditions(as Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getrenditions&api_key=#apikey_admin#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getRenditions(as User with Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getrenditions&api_key=#apikey_user_perm#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getRenditions(as User without Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getrenditions&api_key=#apikey_user_noperm#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>



<!--- ************* SET METADATA************** --->

<strong>setMetadata( as System Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=setmetadata&api_key=#apikey_sysadmin#&assetid=#assetid#&assettype=#assettype#&assetmetadata=[[%22img_keywords%22,%22Razuna_Rocks,temp%22]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setMetadata(as Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=setmetadata&api_key=#apikey_admin#&assetid=#assetid#&assettype=#assettype#&assetmetadata=[[%22img_keywords%22,%22Razuna_Rocks,temp%22]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setMetadata(as User with Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=setmetadata&api_key=#apikey_user_perm#&assetid=#assetid#&assettype=#assettype#&assetmetadata=[[%22img_keywords%22,%22Razuna_Rocks,temp%22]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setMetadata(as User without Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=setmetadata&api_key=#apikey_user_noperm#&assetid=#assetid#&assettype=#assettype#&assetmetadata=[[%22img_keywords%22,%22Razuna_Rocks,temp%22]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush> 

<!--- ************* MOVE************** --->
 <strong>Move(as System Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey_sysadmin#&assetid=#assetid#&destination_folder=#destination_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush> 
<!--- Put file back in original folder --->
<cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey_sysadmin#&assetid=#assetid#&destination_folder=#original_folderid#"></cfhttp>

<strong>Move(as Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey_admin#&assetid=#assetid#&destination_folder=#destination_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>
<!--- Put file back in original folder --->
<cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey_admin#&assetid=#assetid#&destination_folder=#original_folderid#"></cfhttp>


<strong>Move(as User with Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey_user_perm#&assetid=#assetid#&assettype=#assettype#&destination_folder=#destination_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>
<!--- Put file back in original folder --->
<cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey_user_perm#&assetid=#assetid#&destination_folder=#original_folderid#"></cfhttp>


<strong>Move(as User without Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey_user_noperm#&assetid=#assetid#&destination_folder=#destination_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush> 

<!--- Put file back in original folder --->
<cfhttp url="#apiurl#asset.cfc?method=move&api_key=#apikey_user_noperm#&assetid=#assetid#&destination_folder=#original_folderid#"></cfhttp>


<!--- ************* CREATE RENDITIONS ************** --->
<strong>createRenditions(as System Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=createrenditions&api_key=#apikey_sysadmin#&assetid=#assetid#&assettype=#assettype#&convertdata=[[[%22convert_to%22,%22jpg%22],[%22convert_width_jpg%22,%22500%22],[%22convert_height_jpg%22,%22374%22],[%22convert_dpi_jpg%22,%22%22],[%22convert_wm_jpg%22,%22%22]]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>createRenditions(as Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=createrenditions&api_key=#apikey_admin#&assetid=#assetid#&assettype=#assettype#&convertdata=[[[%22convert_to%22,%22jpg%22],[%22convert_width_jpg%22,%22500%22],[%22convert_height_jpg%22,%22374%22],[%22convert_dpi_jpg%22,%22%22],[%22convert_wm_jpg%22,%22%22]]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>createRenditions(as User with Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=createrenditions&api_key=#apikey_user_perm#&assetid=#assetid#&assettype=#assettype#&convertdata=[[[%22convert_to%22,%22jpg%22],[%22convert_width_jpg%22,%22500%22],[%22convert_height_jpg%22,%22374%22],[%22convert_dpi_jpg%22,%22%22],[%22convert_wm_jpg%22,%22%22]]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>createRenditions(as User without Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=createrenditions&api_key=#apikey_user_noperm#&assetid=#assetid#&assettype=#assettype#&convertdata=[[[%22convert_to%22,%22jpg%22],[%22convert_width_jpg%22,%22500%22],[%22convert_height_jpg%22,%22374%22],[%22convert_dpi_jpg%22,%22%22],[%22convert_wm_jpg%22,%22%22]]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>



<!--- ************* REGENERATE METADATA ************** --->
<strong>regenerateMetadata(as System Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=regeneratemetadata&api_key=#apikey_sysadmin#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>regenerateMetadata(as Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=regeneratemetadata&api_key=#apikey_admin#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>regenerateMetadata(as User with Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=regeneratemetadata&api_key=#apikey_user_perm#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>regenerateMetadata(as User without Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=regeneratemetadata&api_key=#apikey_user_noperm#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>


<!--- ************* GET PDF IMAGES ************** --->
<strong>getPDFImages(as System Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getpdfimages&api_key=#apikey_sysadmin#&assetid=#fileid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getPDFImages(as Admin)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getpdfimages&api_key=#apikey_admin#&assetid=#fileid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getPDFImages(as User with Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getpdfimages&api_key=#apikey_user_perm#&assetid=#fileid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getPDFImages(as User without Permission)</strong>
<cfhttp url="#apiurl#asset.cfc?method=getpdfimages&api_key=#apikey_user_noperm#&assetid=#fileid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>


<!--- ************* REMOVE************** --->
<!--- Uncoment and run cases one by one. Assetids will need ot be changed manually here.--->
<!--- <strong>getAsset(as System Admin)</strong>
 <cfhttp url="#apiurl#asset.cfc?method=remove&api_key=#apikey_sysadmin#&assetid=#assetid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAsset(as Admin)</strong>
<!--- Get Asset --->
<cfhttp url="#apiurl#asset.cfc?method=remove&api_key=#apikey_admin#&assetid=#assetid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAsset(as User with Permission)</strong>
<!--- Get Asset --->
<cfhttp url="#apiurl#asset.cfc?method=remove&api_key=#apikey_user_perm#&assetid=#assetid#&assettype=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAsset(as User without Permission)</strong>
<!--- Get Asset --->
<cfhttp url="#apiurl#asset.cfc?method=remove&api_key=#apikey_user_noperm#&assetid=#assetid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>  
--->
<!--- ############################ FOLDER #################################### --->
<h1>FOLDER</h1>
<!--- ************* GET ASSETS ************** --->
<strong>getAssets(as System Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getassets&api_key=#apikey_sysadmin#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssets(as Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getassets&api_key=#apikey_admin#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssets(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getassets&api_key=#apikey_user_perm#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<!--- In this case only subfolders that user has access too will return its assets --->
<strong>getAssets for Subfolders also(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getassets&api_key=#apikey_user_perm#&folderid=#original_folderid#&showsubfolders=true"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssets(as User without Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getassets&api_key=#apikey_user_noperm#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<!--- ************* GET FOLDERS ************** --->
<strong>getFolders(as System Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolders&api_key=#apikey_sysadmin#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolders(as Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolders&api_key=#apikey_admin#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolders(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolders&api_key=#apikey_user_perm#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolders(as User without Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolders&api_key=#apikey_user_noperm#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolders on root(as System Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolders&api_key=#apikey_sysadmin#&folderid=0"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolders on root (as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolders&api_key=#apikey_user_perm#&folderid=0"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<!--- ************* GET FOLDER ************** --->
<!--- WITH FOLDERID PARAMETER --->
<strong>getFolder(as System Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey_sysadmin#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolder(as Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey_admin#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolder(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey_user_perm#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolder(as User without Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey_user_noperm#&folderid=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<!--- WITH FOLDERNAME PARAMETER --->
<strong>getFolder(as System Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey_sysadmin#&foldername=#foldername#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolder(as Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey_admin#&foldername=#foldername#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolder(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey_user_perm#&foldername=#foldername#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getFolder(as User without Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=getfolder&api_key=#apikey_user_noperm#&foldername=#foldername#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>


<!--- ************* SET AND REMOVE FOLDER ************** --->
<strong>setFolder(as System Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolder&api_key=#apikey_sysadmin#&folder_name=#foldername#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>removeFolder(as System Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=removefolder&api_key=#apikey_sysadmin#&folder_id=#jsonstruct.folder_id#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setFolder(as Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolder&api_key=#apikey_admin#&folder_name=#foldername#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>removeFolder(as Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=removefolder&api_key=#apikey_admin#&folder_id=#jsonstruct.folder_id#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<!--- Only admin users can create folders on root so even users with permission should not be allowed that so these cases should fail. --->
<strong>setFolder(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolder&api_key=#apikey_user_perm#&folder_name=#foldername#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setFolder(as User without Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolder&api_key=#apikey_user_noperm#&folder_name=#foldername#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<!---Users with permissions can create sub folders so this case should pass. --->
<strong>setFolder(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolder&api_key=#apikey_user_perm#&folder_name=#foldername#&folder_related=#original_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>removeFolder(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=removefolder&api_key=#apikey_admin#&folder_id=#jsonstruct.folder_id#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>



<!--- ************* SET FOLDER PERMISSION ************** --->
<strong>setFolderPermissions(as System Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolderpermissions&api_key=#apikey_sysadmin#&permissions=[[%22#destination_folderid#%22,%220%22,%22X%22]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setFolderPermissions(as Admin)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolderpermissions&api_key=#apikey_admin#&permissions=[[%22#destination_folderid#%22,%220%22,%22X%22]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setFolderPermissions(as User with Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolderpermissions&api_key=#apikey_user_perm#&permissions=[[%22#destination_folderid#%22,%220%22,%22X%22]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setFolderPermissions(as User without Permission)</strong>
<cfhttp url="#apiurl#folder.cfc?method=setfolderpermissions&api_key=#apikey_user_noperm#&permissions=[[%22#destination_folderid#%22,%220%22,%22X%22]]"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

 
<!--- ############################ LABELS #################################### --->
<h1>LABELS</h1>
<!--- ************* GET ALL ************** --->
<strong>getAll(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=getall&api_key=#apikey_sysadmin#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAll(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=getall&api_key=#apikey_admin#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAll(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=getall&api_key=#apikey_user_perm#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAll(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=getall&api_key=#apikey_user_noperm#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

 

<!--- ************* GET LABEL ************** --->
<strong>getLabel(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=getlabel&api_key=#apikey_sysadmin#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getLabel(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=getlabel&api_key=#apikey_admin#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getLabel(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=getlabel&api_key=#apikey_user_perm#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getLabel(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=getlabel&api_key=#apikey_user_noperm#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>



<!--- ************* SET LABEL ************** --->
<strong>setLabel(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=setlabel&api_key=#apikey_sysadmin#&label_id=#labelid#&label_text=test_label"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setLabel(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=setlabel&api_key=#apikey_admin#&label_text=test_label"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setLabel(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=setlabel&api_key=#apikey_user_perm#&label_id=#labelid#&label_text=test_label"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setLabel(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=setlabel&api_key=#apikey_user_noperm#&label_id=#labelid#&label_text=test_label"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>



<!--- ************* SET ASSET LABEL ************** --->
<strong>setAssetLabel(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=setassetlabel&api_key=#apikey_sysadmin#&label_id=#labelid#&asset_id=#assetid#&asset_type=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setAssetLabel(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=setassetlabel&api_key=#apikey_admin#&label_id=#labelid#&asset_id=#assetid#&asset_type=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setAssetLabel(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=setassetlabel&api_key=#apikey_user_perm#&label_id=#labelid#&asset_id=#assetid#&asset_type=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>setAssetLabel(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=setassetlabel&api_key=#apikey_user_noperm#&label_id=#labelid#&asset_id=#assetid#&asset_type=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<!--- ************* GET LABEL OF ASSET ************** --->
<strong>getLabelOfAsset(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=getlabelofasset&api_key=#apikey_sysadmin#&asset_id=#assetid#&asset_type=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getLabelOfAsset(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=getlabelofasset&api_key=#apikey_admin#&asset_id=#assetid#&asset_type=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getLabelOfAsset(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=getlabelofasset&api_key=#apikey_user_perm#&asset_id=#assetid#&asset_type=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getLabelOfAsset(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=getlabelofasset&api_key=#apikey_user_noperm#&asset_id=#assetid#&asset_type=#assettype#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>


<!--- ************* GET ASSET OF LABEL ************** --->
<strong>getAssetOfLabel(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=getassetoflabel&api_key=#apikey_sysadmin#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssetOfLabel(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=getassetoflabel&api_key=#apikey_admin#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssetOfLabel(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=getassetoflabel&api_key=#apikey_user_perm#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssetOfLabel(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=getassetoflabel&api_key=#apikey_user_noperm#&label_id=#labelid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>



<!--- ************* SEARCH LABEL ************** --->
<strong>searchLabel(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=searchlabel&api_key=#apikey_sysadmin#&searchfor=UPC"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchLabel(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=searchlabel&api_key=#apikey_admin#&searchfor=UPC"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchLabel(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=searchlabel&api_key=#apikey_user_perm#&searchfor=UPC"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchLabel(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=searchlabel&api_key=#apikey_user_noperm#&searchfor=UPC"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>



<!--- ************* REMOVE ASSET LABEL ************** --->
<strong>removeAssetLabel(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=removeassetlabel&api_key=#apikey_sysadmin#&label_id=#labelid#&asset_id=#assetid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>removeAssetLabel(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=removeassetlabel&api_key=#apikey_admin#&label_id=#labelid#&asset_id=#assetid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>removeAssetLabel(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=removeassetlabel&api_key=#apikey_user_perm#&label_id=#labelid#&asset_id=#assetid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>removeAssetLabel(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=removeassetlabel&api_key=#apikey_user_noperm#&label_id=#labelid#&asset_id=#assetid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>
--->

<!--- ************* REMOVE LABEL ************** --->
<!--- Run one by one. Labelid will need to be set manually --->
<!--- <strong>remove(as System Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=remove&api_key=#apikey_sysadmin#&label_id=A0D2BA3A470741BFAEDE0B1665D1B183"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>remove(as Admin)</strong>
<cfhttp url="#apiurl#label.cfc?method=remove&api_key=#apikey_admin#&label_id=FAF1E775B98F4D4AB74151EE1F5562EB"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>remove(as User with Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=remove&api_key=#apikey_user_perm#&label_id=A0D2BA3A470741BFAEDE0B1665D1B183"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>remove(as User without Permission)</strong>
<cfhttp url="#apiurl#label.cfc?method=remove&api_key=#apikey_user_noperm#&label_id=A0D2BA3A470741BFAEDE0B1665D1B183"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>
--->

<!--- ############################ COLLECTION #################################### --->
<h1>COLLECTION</h1>
<!--- ************* GET COLLECTIONS ************** --->
<strong>getCollections(as System Admin)</strong>
<cfhttp url="#apiurl#collection.cfc?method=getcollections&api_key=#apikey_sysadmin#&folderid=#collection_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getCollections(as Admin)</strong>
<cfhttp url="#apiurl#collection.cfc?method=getcollections&api_key=#apikey_admin#&folderid=#collection_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getCollections(as User with Permission)</strong>
<cfhttp url="#apiurl#collection.cfc?method=getcollections&api_key=#apikey_user_perm#&folderid=#collection_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getCollections(as User without Permission)</strong>
<cfhttp url="#apiurl#collection.cfc?method=getcollections&api_key=#apikey_user_noperm#&folderid=#collection_folderid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>


<!--- ************* GET ASSETS FOR COLLECTION ************** --->
<strong>getAssets(as System Admin)</strong>
<cfhttp url="#apiurl#collection.cfc?method=getassets&api_key=#apikey_sysadmin#&collectionid=#collectionid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssets(as Admin)</strong>
<cfhttp url="#apiurl#collection.cfc?method=getassets&api_key=#apikey_admin#&collectionid=#collectionid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssets(as User with Permission)</strong>
<cfhttp url="#apiurl#collection.cfc?method=getassets&api_key=#apikey_user_perm#&collectionid=#collectionid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>getAssets(as User without Permission)</strong>
<cfhttp url="#apiurl#collection.cfc?method=getassets&api_key=#apikey_user_noperm#&collectionid=#collectionid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>


<!--- ************* SEARCH COLLECTION ************** --->
<strong>search(as System Admin)</strong>
<cfhttp url="#apiurl#collection.cfc?method=search&api_key=#apikey_sysadmin#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>search(as Admin)</strong>
<cfhttp url="#apiurl#collection.cfc?method=search&api_key=#apikey_admin#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>search(as User with Permission)</strong>
<cfhttp url="#apiurl#collection.cfc?method=search&api_key=#apikey_user_perm#&id=#collectionid#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>search(as User without Permission)</strong>
<cfhttp url="#apiurl#collection.cfc?method=search&api_key=#apikey_user_noperm#&id=#collectionid#&name=testcol"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>


<!--- ############################ SEARCH #################################### --->
<h1>SEARCH</h1>
<!--- ************* SEARCH ASSETS ************** --->
<strong>searchAssets(as System Admin)</strong>
<cfhttp url="#apiurl#search.cfc?method=searchassets&api_key=#apikey_sysadmin#&searchfor=#searchfor#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchAssets(as Admin)</strong>
<cfhttp url="#apiurl#search.cfc?method=searchassets&api_key=#apikey_admin#&searchfor=#searchfor#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchAssets(as User with Permission)</strong>
<cfhttp url="#apiurl#search.cfc?method=searchassets&api_key=#apikey_user_perm#&searchfor=#searchfor#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchAssets(as User without Permission)</strong>
<cfhttp url="#apiurl#search.cfc?method=searchassets&api_key=#apikey_user_noperm#&searchfor=#searchfor#"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<!--- ************* SEARCH INDEX ************** --->
<strong>searchIndex(as System Admin)</strong>
<cfhttp url="#apiurl#search.cfc?method=searchindex&api_key=#apikey_sysadmin#&assetid=all"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchIndex(as Admin)</strong>
<cfhttp url="#apiurl#search.cfc?method=searchindex&api_key=#apikey_admin#&assetid=all"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchIndex(as User with Permission)</strong>
<cfhttp url="#apiurl#search.cfc?method=searchindex&api_key=#apikey_user_perm#&assetid=all"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

<strong>searchIndex(as User without Permission)</strong>
<cfhttp url="#apiurl#search.cfc?method=searchindex&api_key=#apikey_user_noperm#&assetid=all"></cfhttp>
<br>#cfhttp.filecontent#<br>
<cfset jsonstruct = deserializeJSON(cfhttp.filecontent)>
<cfdump var="#jsonstruct#">
<cfflush>

</cfoutput>
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

