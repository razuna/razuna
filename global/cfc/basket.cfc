<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent output="false" extends="extQueryCaching">

<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("general")>

<!--- PUT INTO BASKET --->
<cffunction name="tobasket" output="false" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam name="arguments.thestruct.thetype" default="">
	<cfparam name="arguments.thestruct.fromshare" default="F">
	<cfloop index="thenr" delimiters="," list="#arguments.thestruct.file_id#">
		<!--- If we come from a overview we have numbers with the type --->
		<cfset thetype = listlast(thenr,"-")>
		<cfset thenr = listfirst(thenr,"-")>
		<!--- First check if the product is not already in this basket --->
		<cfquery datasource="#variables.dsn#" name="here">
		SELECT user_id
		FROM #session.hostdbprefix#cart
		WHERE cart_id = <cfqueryparam value="#session.thecart#" cfsqltype="cf_sql_varchar">
		<cfif arguments.thestruct.fromshare EQ "F">
			AND user_id = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		AND cart_product_id = <cfqueryparam value="#thenr#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND cart_file_type = <cfqueryparam value="#thetype#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- If no record has been found continue --->
		<cfif here.recordcount EQ 0>
			<!--- Is this file a doc or a img --->
			<!---
<cfloop delimiters="," index="i" list="#arguments.thestruct.thetype#">
				<cfif (i EQ "#thenr#-img") OR (i EQ "#thenr#-doc") OR (i EQ "#thenr#-vid") OR (i EQ "#thenr#-aud")>
--->
					<!--- <cfset newtype = replace(i, "#thenr#-", "", "ALL")> --->
					<!--- insert the prodcut to the cart --->
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#cart
					(cart_id, user_id, cart_product_id, cart_create_date, cart_create_time, cart_change_date, cart_change_time, cart_file_type, host_id)
					VALUES(
					<cfqueryparam value="#session.thecart#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#thenr#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#thetype#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
				<!---
</cfif>
			</cfloop>
--->
		</cfif>
	</cfloop>
	<!--- Remove expired assets from cart --->
	<cfquery datasource="#variables.dsn#" name="removeexpired">
		DELETE c FROM #session.hostdbprefix#cart c 
		LEFT JOIN #session.hostdbprefix#images i ON c.cart_product_id = i.img_id AND cart_file_type = 'img'
		LEFT JOIN #session.hostdbprefix#audios a ON c.cart_product_id = a.aud_id AND cart_file_type = 'aud'
		LEFT JOIN #session.hostdbprefix#videos v ON c.cart_product_id = v.vid_id AND cart_file_type = 'vid'
		LEFT JOIN #session.hostdbprefix#files f ON c.cart_product_id = f.file_id AND cart_file_type = 'doc'
		WHERE 
		i.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
		OR a.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
		OR v.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
		OR f.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- READ BASKET --->
<cffunction name="readbasket" output="false" returnType="query">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#readbasket */ c.cart_product_id, c.cart_file_type, c.cart_order_done, c.cart_order_email, c.cart_order_message, c.cart_create_date, c.cart_change_date, 
			CASE 
				WHEN c.cart_file_type = 'doc' 
					THEN (
						SELECT file_name 
						FROM #session.hostdbprefix#files 
						WHERE file_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'img'
					THEN (
						SELECT img_filename 
						FROM #session.hostdbprefix#images 
						WHERE img_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'vid'
					THEN (
						SELECT vid_filename 
						FROM #session.hostdbprefix#videos 
						WHERE vid_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'aud'
					THEN (
						SELECT aud_name
						FROM #session.hostdbprefix#audios 
						WHERE aud_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
			END as filename,
			CASE 
				WHEN c.cart_file_type = 'doc' 
					THEN (
						SELECT file_extension
						FROM #session.hostdbprefix#files 
						WHERE file_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'aud' 
					THEN (
						SELECT aud_extension
						FROM #session.hostdbprefix#audios 
						WHERE aud_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
			END as theextension,
			CASE 
				WHEN c.cart_file_type = 'img' 
					THEN (
						SELECT img_width
						FROM #session.hostdbprefix#images 
						WHERE img_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'vid' 
					THEN (
						SELECT vid_width
						FROM #session.hostdbprefix#videos 
						WHERE vid_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
			END as cart_width,
			CASE 
				WHEN c.cart_file_type = 'img' 
					THEN (
						SELECT img_height
						FROM #session.hostdbprefix#images 
						WHERE img_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'vid' 
					THEN (
						SELECT vid_height
						FROM #session.hostdbprefix#videos 
						WHERE vid_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
			END as cart_height,
			CASE 
				WHEN c.cart_file_type = 'doc' 
					THEN (
						SELECT file_size
						FROM #session.hostdbprefix#files 
						WHERE file_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'img'
					THEN (
						SELECT img_size
						FROM #session.hostdbprefix#images 
						WHERE img_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'vid'
					THEN (
						SELECT vid_size
						FROM #session.hostdbprefix#videos 
						WHERE vid_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'aud'
					THEN (
						SELECT aud_size
						FROM #session.hostdbprefix#audios 
						WHERE aud_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
			END as cart_size,
			CASE 
				WHEN c.cart_file_type = 'doc' 
					THEN (
						SELECT file_upc_number
						FROM #session.hostdbprefix#files 
						WHERE file_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'img'
					THEN (
						SELECT img_upc_number
						FROM #session.hostdbprefix#images 
						WHERE img_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'vid'
					THEN (
						SELECT vid_upc_number
						FROM #session.hostdbprefix#videos 
						WHERE vid_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
				WHEN c.cart_file_type = 'aud'
					THEN (
						SELECT aud_upc_number
						FROM #session.hostdbprefix#audios 
						WHERE aud_id = c.cart_product_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
			END as upc_number
		FROM #session.hostdbprefix#cart c
		WHERE c.cart_id = <cfqueryparam value="#session.thecart#" cfsqltype="cf_sql_varchar">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<!---
		AND c.user_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.theuserid#">
		--->
		ORDER BY c.cart_file_type
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Assets Additional Versions --->
<cffunction name="additional_versions" output="false">
	<cfset getbasket = readbasket()>
	<!--- param ---> 
	<cfset var qry = structnew()>
	<!--- check recordcount --->
	<cfif getbasket.recordcount NEQ 0>
		<!--- Query links --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.assets" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#get_versions_link2 */ av_id,asset_id_r, av_link_title, av_link_url, thesize, thewidth, theheight, av_type, hashtag
			FROM #session.hostdbprefix#additional_versions
			WHERE asset_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#valueList(getBasket.cart_product_id)#" list="true">)
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND av_link = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		</cfquery>
	</cfif>
	<cfreturn qry />
</cffunction>

<!--- REMOVE THE ITEM FROM THE BASKET --->
<cffunction name="removeitem" output="false">
	<cfargument name="thefileid" default="" required="yes" type="string">
	<!--- Remove --->
	<cfquery datasource="#variables.dsn#">
	DELETE FROM #session.hostdbprefix#cart
	WHERE cart_product_id = <cfqueryparam value="#arguments.thefileid#" cfsqltype="CF_SQL_VARCHAR">
	AND cart_id = <cfqueryparam value="#session.thecart#" cfsqltype="cf_sql_varchar">
	<!--- AND user_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.theuserid#"> --->
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- REMOVE BASKET --->
<cffunction name="removebasket" output="false">
	<!--- Remove --->
	<cfquery datasource="#variables.dsn#">
	DELETE FROM #session.hostdbprefix#cart
	WHERE cart_id = <cfqueryparam value="#session.thecart#" cfsqltype="cf_sql_varchar">
	<!--- AND user_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.theuserid#"> --->
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- WRITE FILES IN BASKET TO SYSTEM --->
<cffunction name="writebasket" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam default="" name="arguments.thestruct.artofimage">
	<cfparam default="" name="arguments.thestruct.artofvideo">
	<cfparam default="" name="arguments.thestruct.artoffile">
	<cfparam default="" name="arguments.thestruct.artofaudio">
	<cfparam default="false" name="arguments.thestruct.noemail">
	<!--- Feedback --->
	<cfif !arguments.thestruct.noemail>
		<cfoutput><strong>We are getting your files for your basket ready...</strong><br><br></cfoutput>
		<cfflush>
	</cfif>
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<cftry>
		<!--- Set time for remove --->
		<cfset var removetime = DateAdd("h", -72, "#now()#")>
		<!--- Remove old directories --->
		<cfdirectory action="list" directory="#arguments.thestruct.thepath#/outgoing" name="thedirs">
		<!--- Loop over dirs --->
		<cfloop query="thedirs">
			<!--- If a directory --->
			<cfif type EQ "dir" AND thedirs.attributes NEQ "H" AND datelastmodified LT removetime>
				<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/outgoing/#name#" recurse="true" mode="775">
			<cfelseif type EQ "file" AND thedirs.attributes NEQ "H" AND datelastmodified LT removetime>
				<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#name#">
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while removing outgoing folders in function basket.writebasket">
			<cfset errObj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Feedback --->
	<cfif !arguments.thestruct.noemail>
		<cfoutput><strong>So far, so good. Fetching files...</strong><br><br></cfoutput>
		<cfflush>
	</cfif>
	<!--- Create directory --->
	<cfset basketname = createuuid("")>
	<cfset arguments.thestruct.newpath = arguments.thestruct.thepath & "/outgoing/#basketname#">
	<cfdirectory action="create" directory="#arguments.thestruct.newpath#" mode="775">
	<!--- Read Basket --->
	<cfinvoke method="readbasket" returnvariable="thebasket">
	<!--- Loop trough the basket --->
	<cfloop query="thebasket">
		<!--- Set the asset id into a var --->
		<cfset arguments.thestruct.theid = cart_product_id>
		<!--- Get the files according to the extension --->
		<cfswitch expression="#cart_file_type#">
			<!--- Images --->
			<cfcase value="img">
				<!--- Feedback --->
				<cfif !arguments.thestruct.noemail>
					<cfoutput><strong>Getting images...</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Write Image --->
				<cfinvoke method="writeimages" thestruct="#arguments.thestruct#">
			</cfcase>
			<!--- Videos --->
			<cfcase value="vid">
				<!--- Feedback --->
				<cfif !arguments.thestruct.noemail>
					<cfoutput><strong>Getting videos...</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Write Video --->
				<cfinvoke method="writevideos" thestruct="#arguments.thestruct#">
			</cfcase>
			<!--- Audios --->
			<cfcase value="aud">
				<!--- Feedback --->
				<cfif !arguments.thestruct.noemail>
					<cfoutput><strong>Getting audios...</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Write Video --->
				<cfinvoke method="writeaudios" thestruct="#arguments.thestruct#">
			</cfcase>
			<!--- All other files --->
			<cfdefaultcase>
				<!--- Feedback --->
				<cfif !arguments.thestruct.noemail>
					<cfoutput><strong>Getting documents...</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Write file --->
				<cfinvoke method="writefiles" thestruct="#arguments.thestruct#">
			</cfdefaultcase>
		</cfswitch>
	</cfloop>
	<!--- Feedback --->
	<cfif !arguments.thestruct.noemail>
		<cfoutput><strong>Putting it into a nice ZIP archive...</strong><br><br></cfoutput>
		<cfflush>
	</cfif>
	<!--- All done. Now zip up the folder --->
	<cfif NOT structkeyexists(arguments.thestruct,"zipname")>
		<cfset arguments.thestruct.zipname = "basket-" & createuuid("") & ".zip">
	<cfelse>
		<cfset arguments.thestruct.zipname = replacenocase(arguments.thestruct.zipname, " ", "_", "ALL")>
		<cfset arguments.thestruct.zipname = arguments.thestruct.zipname & ".zip">
	</cfif>
	<!--- RAZ-2831 : Move metadata export into folder --->
	<cfif structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount NEQ 0>
		<cffile action="move" destination="#arguments.thestruct.newpath#" source="#arguments.thestruct.thepath#/outgoing/metadata-export-#session.hostid#-#session.theuserid#.csv">
	</cfif>
	<!--- Zip the folder --->
	<cfthread name="#basketname#" intstruct="#arguments.thestruct#">
		<cfzip action="create" ZIPFILE="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.zipname#" source="#attributes.intstruct.newpath#" recurse="true" timeout="300" />
	</cfthread>
	<cfthread action="join" name="#basketname#" />
	<!--- Remove the temp folder --->
	<cfdirectory action="delete" directory="#arguments.thestruct.newpath#" recurse="yes">
	<!--- We are comping from the basket zip action thus move the file to the incoming folder since we need to upload the zip to the server --->
	<cfif structkeyexists(arguments.thestruct,"fromzip")>
		<cffile action="move" source="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.zipname#" destination="#arguments.thestruct.thepath#/incoming/#arguments.thestruct.zipname#">
	</cfif>
	<!--- Get correct path for eMail --->
	<cfset var sn = replacenocase(cgi.script_name,"/index.cfm","","one")>
	<cfset var thehost = listlast(arguments.thestruct.pathoneup,"/\")>
	<!--- Send the user an email that his basket is ready --->
	<cfif NOT structkeyexists(arguments.thestruct,"fromzip") AND !arguments.thestruct.noemail>
		<!--- RAZ-2810 Customise email message --->
		<cfinvoke component="defaults" method="trans" transid="basket_download_available_subject" returnvariable="basket_download_available_sub" />
		<cfinvoke component="defaults" method="trans" transid="basket_download_available_message" returnvariable="basket_download_available_msg" />
		<cfinvoke component="email" method="send_email" subject="#basket_download_available_sub#" themessage="#basket_download_available_msg# <a href='#session.thehttp##cgi.HTTP_HOST##sn#/outgoing/#arguments.thestruct.zipname#'>#session.thehttp##cgi.HTTP_HOST##sn#/outgoing/#arguments.thestruct.zipname#</a>">
	</cfif>
	<!--- Feedback --->
	<cfif !arguments.thestruct.noemail>
		<cfoutput><strong style="color:green;">All done. <a href="#session.thehttp##cgi.HTTP_HOST##sn#/outgoing/#arguments.thestruct.zipname#" style="color:green;">Here is your basket.</a></strong><br><br></cfoutput>
		<cfflush>
	</cfif>
	<!--- The output link so we retrieve in in JS --->
	<!--- <cfoutput>outgoing/#arguments.thestruct.zipname#</cfoutput> --->
	<cfreturn arguments.thestruct.zipname>
</cffunction>

<cffunction name = "savedesckey" hint="Save description and keywords for file">
	<cfargument name="thestruct" type="struct">
	<!--- Get id of file created --->
	<cfquery datasource="#application.razuna.datasource#" name="getfileid" >
		SELECT file_id FROM #session.hostdbprefix#files WHERE file_name = '#arguments.thestruct.thefile#'
	</cfquery>
	<!--- Add the description and keywords to file database--->
	<cfif structkeyexists(arguments.thestruct,"langs")>
		<cfloop list="#arguments.thestruct.langs#" index="langindex">
			<cfset var thedesc = evaluate("arguments.thestruct.file_desc_#langindex#")>
			<cfset var thekey = evaluate("arguments.thestruct.file_keywords_#langindex#")>
			<cfset console("langindex")>
			<cfset console(langindex)>
			<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#files_desc
				(id_inc, file_id_r, lang_id_r, file_desc, file_keywords, host_id)
				VALUES(
				<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#getfileid.file_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#thedesc#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#thekey#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				)
			</cfquery>
		</cfloop>
	</cfif>
	<cfreturn>
</cffunction>

<!--- WRITE FILES TO SYSTEM --->
<cffunction name="writefiles" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset var qry = "">
	<!--- RAZ-2906 : Get the dam settings --->
	<!--- <cfinvoke component="global.cfc.settings"  method="getsettingsfromdam" returnvariable="arguments.thestruct.getsettings" /> --->
	<!--- Start the loop to get the file --->
	<cfloop delimiters="," list="#arguments.thestruct.artoffile#" index="art">
		<!--- Put id and art into variables --->
		<cfset thefileid = listfirst(art, "-")>
		<cfset theart = listlast(art, "-")>
		<cfif arguments.thestruct.theid EQ thefileid>
			<!--- Create thread  --->
			<cfset ttd = createuuid()>
			<!--- Query --->
			<cfif theart EQ "versions" >
				<!--- set addtional version id --->
				<cfset theavid = listGetAt(art,2,'-')>
				<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry" cachedwithin="1" region="razcache">
					SELECT av_id,asset_id_r,folder_id_r,av_type,av_link_title,av_link_url AS path_to_asset,'' AS link_kind, folder_id_r
					FROM #session.hostdbprefix#additional_versions
					WHERE av_id = <cfqueryparam value="#theavid#" cfsqltype="CF_SQL_VARCHAR">
					AND av_type = <cfqueryparam value="doc" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="cf_sql_numeric">
				</cfquery>
			<cfelse>
				<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry" cachedwithin="1" region="razcache">
					SELECT /* #variables.cachetoken#writefiles */ file_extension, file_name, folder_id_r, file_name_org, link_kind, link_path_url, path_to_asset, cloud_url_org
					FROM #session.hostdbprefix#files
					WHERE file_id = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
			<cfif theart EQ "versions">
				<cfset theext = listlast(arguments.thestruct.qry.path_to_asset,".")>
				<!--- Check that the filename has an extension --->
				<cfset rep = replacenocase(arguments.thestruct.qry.av_link_title,".#theext#","","one")>
				<cfset thename = replace(rep,".","-","all")>
				<!--- If thenewname variable contains /\ --->
				<cfset thename = replace(thename,"/","-","all")>
				<cfset thename = replace(thename,"\","-","all")>
				<cfset arguments.thestruct.thename =  "add_rend_" & thename & "_" & arguments.thestruct.qry.av_id & ".#theext#">
			<cfelse>
				<!--- Check that the filename has an extension --->
				<cfset rep = replacenocase(arguments.thestruct.qry.file_name,".#arguments.thestruct.qry.file_extension#","","one")>
				<cfset thename = replace(rep,".","-","all")>
				<!--- If thenewname variable contains /\ --->
				<cfset thename = replace(thename,"/","-","all")>
				<cfset thename = replace(thename,"\","-","all")>
				<cfset arguments.thestruct.thename = thename & ".#arguments.thestruct.qry.file_extension#">
			</cfif>
			<!--- RAZ-2906: Check the settings for download assets with ext or not  --->
			<!--- <cfif theart EQ "versions">
				<cfset var name = arguments.thestruct.qry.av_link_title>
				<cfset var orgname = listfirst(arguments.thestruct.qry.av_link_title,".")>
			<cfelse>
				<cfset var name = arguments.thestruct.qry.file_name>
				<cfset var orgname = listfirst(arguments.thestruct.qry.file_name_org,".")>
			</cfif>
			<cfif structKeyExists(arguments.thestruct.getsettings,"set2_custom_file_ext") AND arguments.thestruct.getsettings.set2_custom_file_ext EQ "false">
				<cfif name EQ orgname>
					<cfset arguments.thestruct.thename = arguments.thestruct.qry.file_name >
				<cfelse>
					<cfset arguments.thestruct.thename = arguments.thestruct.qry.file_name >
				</cfif>
			</cfif> --->

			<!--- Get Parent folder names --->
			<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#arguments.thestruct.qry.folder_id_r#" returnvariable="crumbs" />
			<cfset parentfoldersname = ''>
			<cfloop list="#crumbs#" index="idx" delimiters=";">
				<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
			</cfloop>
			<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#">
			<!--- Create subfolder for the kind of image --->
			<cfif NOT directoryexists("#arguments.thestruct.thedir#")>
				<cfdirectory action="create" directory="#arguments.thestruct.thedir#" mode="775">
			</cfif>

			<!--- RAZ-2918:: If the file have same name in basket then rename the file --->
			<cfset var thenameorg = arguments.thestruct.thename>
			<cfset fileNameOK = true>
			<cfset uniqueCount = 1>
			<cfloop condition="#fileNameOK#">
				<cfif fileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thename#")>
					<cfset arguments.thestruct.thename = replacenocase(thenameorg,'.'&listlast(thenameorg,'.'),'') & '_' & uniqueCount & '.' & listLast(arguments.thestruct.thename,'.')> 
					<cfset uniqueCount = uniqueCount + 1>
				<cfelse>
					<cfset fileNameOK = false>	
				</cfif>	
			</cfloop>

			<!--- Local --->
			<cfif application.razuna.storage EQ "local" AND arguments.thestruct.qry.link_kind EQ "">
				<!--- Copy file to the outgoing folder --->
				<cfif theart EQ "versions">
					<cfthread name="#ttd#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid##attributes.intstruct.qry.path_to_asset#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thename#" mode="775">
					</cfthread>
				<cfelse>
					<cfthread name="#ttd#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.qry.file_name_org#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thename#" mode="775">
					</cfthread>
				</cfif>
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon" AND arguments.thestruct.qry.link_kind EQ "">
				<!--- set asset path --->
				<cfif theart EQ "versions">
					<cfset arguments.thestruct.asset_path = "/#arguments.thestruct.qry.folder_id_r#/doc/#arguments.thestruct.qry.av_id#/#arguments.thestruct.qry.av_link_title#">
				<cfelse>
					<cfset arguments.thestruct.asset_path = "/#arguments.thestruct.qry.path_to_asset#/#arguments.thestruct.qry.file_name_org#">
				</cfif>
				<cfthread name="#ttd#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Download">
						<cfinvokeargument name="key" value="#attributes.intstruct.asset_path#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.thedir#/#attributes.intstruct.thename#">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
			<!--- Akamai --->
			<cfelseif application.razuna.storage EQ "akamai" AND arguments.thestruct.qry.link_kind EQ "">
				<cfif theart EQ "versions">
					<cfthread name="#ttd#" intstruct="#arguments.thestruct#">
						<cfhttp url="#attributes.intstruct.qry.path_to_asset#" file="#attributes.intstruct.thename#" path="#attributes.intstruct.newpath#"></cfhttp>
					</cfthread>
				<cfelse>
					<cfthread name="#ttd#" intstruct="#arguments.thestruct#">
						<cfhttp url="#attributes.intstruct.akaurl##attributes.intstruct.akadoc#/#attributes.intstruct.thename#" file="#attributes.intstruct.thename#" path="#attributes.intstruct.newpath#"></cfhttp>
					</cfthread>
				</cfif>
			<!--- If this is a URL we write a file in the directory with the PATH --->
			<cfelseif arguments.thestruct.qry.link_kind EQ "url">
				<cfthread name="#ttd#" intstruct="#arguments.thestruct#">
					<cffile action="write" file="#attributes.intstruct.thedir#/#attributes.intstruct.thename#.txt" output="This asset is located on a external source. Here is the direct link to the asset:
									
		#attributes.intstruct.qry.link_path_url#" mode="775">
				</cfthread>
			<!--- If this is a linked asset --->
			<cfelseif arguments.thestruct.qry.link_kind EQ "lan">
				<cfthread name="#ttd#" intstruct="#arguments.thestruct#">
					<cffile action="copy" source="#attributes.intstruct.qry.link_path_url#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thename#" mode="775">
				</cfthread>
			</cfif>
			<!--- Wait for the thread above until the file is downloaded fully --->
			<cfthread action="join" name="#ttd#" />
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- WRITE IMAGE TO SYSTEM --->
<cffunction name="writeimages" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset var qry = "">
	<!--- RAZ-2906 : Get the dam settings --->
	<!--- <cfinvoke component="global.cfc.settings"  method="getsettingsfromdam" returnvariable="arguments.thestruct.getsettings" /> --->
	<!--- Start the loop to get the different kinds of images --->
	<cfloop delimiters="," list="#arguments.thestruct.artofimage#" index="art">
		<!--- Create uuid for thread --->
		<cfset thethreadid = createuuid("")>
		<!--- Put image id and art into variables --->
		<cfset theimgid = listfirst(art, "-")>
		<cfset theart = listlast(art, "-")>
		<cfif arguments.thestruct.theid EQ theimgid>
			<!--- set the correct img_id for related assets --->
			<cfif theart NEQ "original" AND theart NEQ "thumb" AND theart NEQ "versions">
				<cfset theimgid = theart>
			</cfif>
			<!--- Query the db --->
			<cfif theart EQ "versions">
				<!--- set addtional version id --->
				<cfset theavid = listGetAt(art,2,'-')>
				<cfquery name="qry" datasource="#variables.dsn#">
					SELECT av.av_id,av.asset_id_r,av.folder_id_r,av.av_type,av.av_link_title,av.av_link_url AS path_to_asset,'' AS img_group,'' AS link_kind, av.folder_id_r, i.img_upc_number upcnum, av.av_link_title thefilename
					FROM #session.hostdbprefix#additional_versions av LEFT JOIN #session.hostdbprefix#images i ON av.asset_id_r = i.img_id
					WHERE av.av_id = <cfqueryparam value="#theavid#" cfsqltype="CF_SQL_VARCHAR">
					AND av.av_type = <cfqueryparam value="img" cfsqltype="CF_SQL_VARCHAR">
					AND av.host_id = <cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="cf_sql_numeric">
				</cfquery>
			<cfelse>
				<cfquery name="qry" datasource="#variables.dsn#">
					SELECT i.img_filename, i.img_extension, i.thumb_extension, i.folder_id_r, i.img_filename_org, i.img_group,
					i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org,  i.img_upc_number upcnum, i.img_filename thefilename
					FROM #session.hostdbprefix#images i, #session.hostdbprefix#settings_2 s
					WHERE i.img_id = <cfqueryparam value="#theimgid#" cfsqltype="CF_SQL_VARCHAR">
					AND s.set2_id = <cfqueryparam value="#variables.setid#" cfsqltype="cf_sql_numeric">
					AND i.host_id = s.host_id
				</cfquery>
			</cfif>
			<!--- Set upc number --->
			<cfset var upcnum = qry.upcnum>
			<cfset var thefilename = qry.thefilename>

			<!--- If we have to serve thumbnail the name is different --->
			<cfif theart EQ "thumb">
				<cfset theimgname = "thumb_#theimgid#.#qry.thumb_extension#">
				<cfset thefinalname = theimgname>
				<cfset theext = qry.thumb_extension>
			<cfelseif theart EQ "versions">
				<cfset theimgname = qry.av_link_title>
				<cfset theext = listlast(qry.path_to_asset,".")>
				<cfset thefinalname = "add_rend_" & replacenocase(qry.av_link_title,".#theext#","") & "_" & qry.av_id & ".#theext#">
			<cfelse>
				<cfset theimgname = qry.img_filename_org>
				<cfset thefinalname = qry.img_filename>
				<cfset theext = qry.img_extension>
				<cfset theart = theext>
			</cfif>
			<!--- Get UPC number from the parent record if rendition --->
			<cfif qry.img_group NEQ "">
				<cfquery name="qrysub" datasource="#variables.dsn#">
				SELECT img_filename, img_extension,  img_upc_number upcnum, img_filename thefilename
				FROM #session.hostdbprefix#images
				WHERE img_id = <cfqueryparam value="#qry.img_group#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- The filename for the folder --->
				<cfset rep = replacenocase(qrysub.img_filename,".#qrysub.img_extension#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = rep & "." & theext>
				<cfset thefinalname = "rend_" & replacenocase(thefinalname,".#theext#","","one") & "." & theext>
				<cfset theart = theext & "_" & theimgid>
				<cfset upcnum = qrysub.upcnum>
			<cfelseif theart EQ "versions">
				<cfset rep = replacenocase(qry.av_link_title,".#theext#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = qry.av_link_title>
			<cfelse>
				<!--- The filename for the folder --->
				<cfset rep = replacenocase(qry.img_filename,".#qry.img_extension#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = rep & "." & theext>
			</cfif>
			<!--- If thenewname variable contains /\ --->
			<cfset thenewname = replace(thenewname,"/","-","all")>
			<cfset thenewname = replace(thenewname,"\","-","all")>
			<!--- convert the foldername without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="thefnamewithext" thename="#thefname#">
			<cfset thefname = listfirst(thefnamewithext, ".")>

			<!--- Put variables into struct for threads --->
			<cfset arguments.thestruct.qry = qry>
			<cfset arguments.thestruct.theimgid = theimgid>
			<cfset arguments.thestruct.theimgname = theimgname>
			<cfset arguments.thestruct.thefname = thefname>
			<cfset arguments.thestruct.thefinalname = thefinalname>
			<cfset arguments.thestruct.theart = theart>

			<!--- ************** UPC SPECIFIC CODE BEGINS **************** --->

			 <!--- Check if UPC criterion is satisfied and needs to be enabled--->
			<cfinvoke component="global" method="isUPC" returnvariable="upcstruct">
				<cfinvokeargument name="folder_id" value="#qry.folder_id_r#"/>
			</cfinvoke>
			<!--- If UPC is enabled then rename rendition according to UPC naming convention --->
			 <cfif upcstruct.upcenabled>
				<cfinvoke component="global" method="ExtractUPCInfo" returnvariable="upcinfo">
					<cfinvokeargument name="upcnumber" value="#upcnum#"/>
					<cfinvokeargument name="upcgrpsize" value="#upcstruct.upcgrpsize#"/>
				</cfinvoke>
				<cfif theart NEQ "thumb">
					<cfset var rendition_version ="">
					<cfif find('.', thefilename)>
							<cfset rendition_version = listlast(thefilename,'.')>
							<cfif not isnumeric(rendition_version)>
								<cfset rendition_version ="">
							<cfelse>
								<cfset rendition_version ="." & rendition_version>
							</cfif>
					</cfif>

					<cfset arguments.thestruct.thefinalname = "#upcinfo.upcprodstr##rendition_version#">
					<!--- Remove extension from filenames for UPC --->
					<cfset thefinalname = replacenocase(replacenocase(thefinalname,".#theext#","","ALL"),".jpg","ALL")>
				</cfif>
			</cfif>
			
			<!--- ************** UPC SPECIFIC CODE ENDS **************** --->

			<!--- Get Parent folder names --->
			<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry.folder_id_r#" returnvariable="crumbs" />
			<cfset parentfoldersname = ''>
			<cfloop list="#crumbs#" index="idx" delimiters=";">
				<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
			</cfloop>
			<cfif upcstruct.upcenabled AND upcstruct.createupcfolder>
				<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#/#upcinfo.upcmanufstr#">
			<cfelse>
				<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#">
			</cfif>
			
			<!--- Create subfolder for the kind of image --->
			<cfif NOT directoryexists("#arguments.thestruct.thedir#")>
				<cfdirectory action="create" directory="#arguments.thestruct.thedir#" mode="775">
			</cfif>
			<!--- If extension is missing then put it in  --->
			<cfif listlast(thefinalname,'.') NEQ theext>
				<cfset thefinalname = thefinalname & ".#theext#">
			</cfif>

			<!--- RAZ-2918:: If the file have same name in basket then rename the file --->
			<cfset var fileNameOK = true>
			<cfset var uniqueCount = 1>
			<cfset var thenameorg = arguments.thestruct.thefinalname>
			<cfloop condition="#fileNameOK#">
				<cfif fileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thefinalname#")>
					<cfif find('.',arguments.thestruct.thefinalname)>
						<cfset arguments.thestruct.thefinalname = replacenocase(thenameorg,'.'&listlast(thenameorg,'.'),'') & '_' & uniqueCount & '.' & listLast(arguments.thestruct.thefinalname,'.')> 
					<cfelse>
						<cfset arguments.thestruct.thefinalname = arguments.thestruct.thefinalname & '_' & uniqueCount> 
					</cfif>
					<cfset uniqueCount = uniqueCount + 1>
				<cfelse>
					<cfset fileNameOK = false>	
				</cfif>	
			</cfloop>

			<!--- convert the filename without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefinalname" thename="#arguments.thestruct.thefinalname#">

			<!--- Local --->
			<cfif application.razuna.storage EQ "local" AND qry.link_kind EQ "">
				<cfif theart EQ "versions">
					<cfthread name="#thethreadid#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid##attributes.intstruct.qry.path_to_asset#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thefinalname#" mode="775">
					</cfthread>	
				<cfelse>
					<cfthread name="#thethreadid#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.theimgname#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thefinalname#" mode="775" >
					</cfthread>	
				</cfif>
				<!--- Wait for the thread above until the file is downloaded fully --->
				<cfthread action="join" name="#thethreadid#" />
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon" AND qry.link_kind EQ "">
				<!--- set asset path --->
				<cfif theart EQ "versions">
					<cfset arguments.thestruct.asset_path = "/#arguments.thestruct.qry.folder_id_r#/img/#arguments.thestruct.qry.av_id#/#arguments.thestruct.theimgname#">
				<cfelse>
					<cfset arguments.thestruct.asset_path = "/#arguments.thestruct.qry.path_to_asset#/#arguments.thestruct.theimgname#">
				</cfif>
				<cfthread name="#thethreadid#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Download">
						<cfinvokeargument name="key" value="#attributes.intstruct.asset_path#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.thedir#/#attributes.intstruct.thefinalname#">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
				<!--- Wait for the thread above until the file is downloaded fully --->
				<cfthread action="join" name="#thethreadid#" />
			<!--- Akamai --->
			<cfelseif application.razuna.storage EQ "akamai" AND qry.link_kind EQ "">
				<cfif theart EQ "thumb">
					<cfthread name="#thethreadid#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.theimgname#" destination="#arguments.thestruct.thedir#/#attributes.intstruct.thefinalname#" mode="775">
					</cfthread>
					<!--- Wait for the thread above until the file is downloaded fully --->
					<cfthread action="join" name="#thethreadid#" />
				<cfelseif theart EQ "versions">
					<cfthread name="#thethreadid#" intstruct="#arguments.thestruct#">
						<cfhttp url="#attributes.intstruct.qry.path_to_asset#" file="#attributes.intstruct.thefinalname#" path="#attributes.intstruct.newpath#/#attributes.intstruct.thefname#/#attributes.intstruct.theart#"></cfhttp>
					</cfthread>
					<!--- Wait for the thread above until the file is downloaded fully --->
					<cfthread action="join" name="#thethreadid#" />
				<cfelse>
					<cfthread name="#thethreadid#" intstruct="#arguments.thestruct#">
						<cfhttp url="#attributes.intstruct.akaurl##attributes.intstruct.akaimg#/#attributes.intstruct.thefinalname#" file="#attributes.intstruct.thefinalname#" path="#attributes.intstruct.newpath#/#attributes.intstruct.thefname#/#attributes.intstruct.theart#"></cfhttp>
					</cfthread>
					<!--- Wait for the thread above until the file is downloaded fully --->
					<cfthread action="join" name="#thethreadid#" />
				</cfif>
			<!--- If this is a URL we write a file in the directory with the PATH --->
			<cfelseif qry.link_kind EQ "url">
				<cfthread name="#thethreadid#" intstruct="#arguments.thestruct#">
					<cffile action="write" file="#attributes.intstruct.thedir#/#attributes.intstruct.qry.img_filename#.txt" output="This asset is located on a external source. Here is the direct link to the asset:
							
#attributes.intstruct.qry.link_path_url#" mode="775">
				</cfthread>
				<!--- Wait for the thread above until the file is downloaded fully --->
				<cfthread action="join" name="#thethreadid#" />
			<!--- If this is a linked asset --->
			<cfelseif qry.link_kind EQ "lan">
				<cfthread name="#thethreadid#" intstruct="#arguments.thestruct#">
					<cffile action="copy" source="#attributes.intstruct.qry.link_path_url#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thefinalname#" mode="775">
				</cfthread>
				<!--- Wait for the thread above until the file is downloaded fully --->
				<cfthread action="join" name="#thethreadid#" />
			</cfif>
			<!--- RAZ-2906: Check the settings for download assets with ext or not  --->
			<!--- <cfif theart EQ "versions">
				<cfset var name = qry.av_link_title>
				<cfset var orgname = listfirst(qry.av_link_title,".")>
			<cfelse>
				<cfset var name = qry.img_filename>
				<cfset var orgname = listfirst(qry.img_filename_org,".")>
			</cfif>
			<cfif structKeyExists(arguments.thestruct.getsettings,"set2_custom_file_ext") AND arguments.thestruct.getsettings.set2_custom_file_ext EQ "false">
				<cfif name EQ orgname>
					<cfif theart EQ "thumb">
						<cfset thenewname = "thumb_" & theimgid >
					<cfelse>
						<cfset thenewname = qry.img_filename >
					</cfif>
				<cfelse>
					<cfif theart EQ "thumb">
						<cfset thenewname = "thumb_" & theimgid & ".#qry.thumb_extension#">
					</cfif>
				</cfif>
			<cfelse>
				<cfif theart EQ "thumb">
					<cfset thenewname = "thumb_#theimgid#.#qry.thumb_extension#">
				</cfif>
			</cfif>
			<!--- Rename the file --->
			<cfif structkeyexists(qry, "link_kind") AND qry.link_kind NEQ "url" AND fileExists("#arguments.thestruct.newpath#/#arguments.thestruct.thefname#/#arguments.thestruct.theart#/#arguments.thestruct.thefinalname#")>
				<cffile action="move" source="#arguments.thestruct.newpath#/#arguments.thestruct.thefname#/#arguments.thestruct.theart#/#arguments.thestruct.thefinalname#" destination="#arguments.thestruct.newpath#/#arguments.thestruct.thefname#/#arguments.thestruct.theart#/#thenewname#">
			</cfif> --->
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- WRITE VIDEO TO SYSTEM --->
<cffunction name="writevideos" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset var qry = "">
	<!--- RAZ-2906 : Get the dam settings --->
	<!--- <cfinvoke component="global.cfc.settings"  method="getsettingsfromdam" returnvariable="arguments.thestruct.getsettings" /> --->
	<!--- Start the loop to get the different kinds of videos --->
	<cfloop delimiters="," list="#arguments.thestruct.artofvideo#" index="art">
		<!--- Put image id and art into variables --->
		<cfset thevidid = listfirst(art, "-")>
		<cfset theart = listlast(art, "-")>
		<cfif arguments.thestruct.theid EQ thevidid>
			<!--- If this is not the original video --->
			<cfif theart NEQ "video" AND theart NEQ "versions">
				<cfset thevidid = theart>
				<!--- Set the video id for this type of format and set the extension --->
				<cfquery name="ext" datasource="#variables.dsn#">
				SELECT vid_extension
				FROM #session.hostdbprefix#videos
				WHERE vid_id = <cfqueryparam value="#thevidid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfset theart = ext.vid_extension & "_" & thevidid>
			</cfif>
			<!--- Query the db --->
			<cfif theart EQ "versions">
				<!--- set addtional version id --->
				<cfset theavid = listGetAt(art,2,'-')>
				<cfquery name="qry" datasource="#variables.dsn#">
					SELECT av.av_id,av.asset_id_r, av.folder_id_r,av.av_type,av_link_title,av.av_link_url AS path_to_asset,'' AS vid_group,'' AS link_kind
					FROM #session.hostdbprefix#additional_versions av
					WHERE av.av_id = <cfqueryparam value="#theavid#" cfsqltype="CF_SQL_VARCHAR">
					AND av.av_type = <cfqueryparam value="vid" cfsqltype="CF_SQL_VARCHAR">
					AND av.host_id = <cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="cf_sql_numeric">
				</cfquery>
			<cfelse>
				<cfquery name="qry" datasource="#variables.dsn#">
					SELECT v.vid_mimetype mt, v.vid_filename, v.vid_extension, v.vid_name_pre, v.vid_name_org, v.folder_id_r,
					v.vid_group, v.link_kind, v.link_path_url, v.path_to_asset, v.cloud_url_org
					FROM #session.hostdbprefix#videos v
					WHERE v.vid_id = <cfqueryparam value="#thevidid#" cfsqltype="CF_SQL_VARCHAR">
					AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>


			<cfif qry.vid_group NEQ "">
				<!--- The filename for the folder --->
				 <cfset rep = replacenocase(qry.vid_filename,".#qry.vid_extension#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = rep & "." & qry.vid_extension> 
				<cfset thenewname = "rend_" & thenewname>
			<cfelseif theart EQ "versions">
				<cfset theext = listlast(qry.path_to_asset,".")>
				<cfset rep = replacenocase(qry.av_link_title,".#theext#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = "add_rend_" & replacenocase(qry.av_link_title,".#theext#","") & "_" & qry.av_id & ".#theext#">
			<cfelse>
				<!--- The filename for the folder --->
				<cfset rep = replacenocase(qry.vid_filename,".#qry.vid_extension#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = rep & "." & qry.vid_extension>
			</cfif>
			<!--- If thenewname variable contains /\ --->
			<cfset thenewname = replace(thenewname,"/","-","all")>
			<cfset thenewname = replace(thenewname,"\","-","all")>
			
			<!--- convert the foldername without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="thefnamewithext" thename="#thefname#">
			<cfset thefname = listfirst(thefnamewithext, ".")>
			
			<!--- Get Parent folder names --->
			<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry.folder_id_r#" returnvariable="crumbs" />
			<cfset parentfoldersname = ''>
			<cfloop list="#crumbs#" index="idx" delimiters=";">
				<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
			</cfloop>
			<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#">
			<!--- Create subfolder for the kind of image --->
			<cfif NOT directoryexists("#arguments.thestruct.thedir#")>
				<cfdirectory action="create" directory="#arguments.thestruct.thedir#" mode="775">
			</cfif>

			<!--- Put variables into struct for threads --->
			<cfset arguments.thestruct.qry = qry>
			<cfset arguments.thestruct.thevideoid = thevidid>
			<cfset arguments.thestruct.theart = theart>
			<cfset arguments.thestruct.thenewname = thenewname>
			<cfset arguments.thestruct.thefname = thefname>

			<!--- RAZ-2918:: If the file have same name in basket then rename the file --->
			<cfset var fileNameOK = true>
			<cfset var uniqueCount = 1>
			<cfset var thenameorg = arguments.thestruct.thenewname>
			<cfloop condition="#fileNameOK#">
				<cfif fileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thenewname#")>
					<cfset arguments.thestruct.thenewname = replacenocase(thenameorg,'.'&listlast(thenameorg,'.'),'') & '_' & uniqueCount & '.' & listLast(arguments.thestruct.thenewname,'.')> 
					<cfset uniqueCount = uniqueCount + 1>
				<cfelse>
					<cfset fileNameOK = false>	
				</cfif>	
			</cfloop>

			<!--- RAZ-2906: Check the settings for download assets with ext or not  --->
			<!--- <cfif theart EQ "versions">
				<cfset var name = qry.av_link_title>
				<cfset var orgname = listfirst(qry.av_link_title,".")>
			<cfelse>
				<cfset var name = qry.vid_filename>
				<cfset var orgname = listfirst(qry.vid_name_org,".")>
			</cfif>
			<cfif structKeyExists(arguments.thestruct.getsettings,"set2_custom_file_ext") AND arguments.thestruct.getsettings.set2_custom_file_ext EQ "false">
				<cfif name EQ orgname>
					<cfset arguments.thestruct.thenewname = qry.vid_filename >
				<cfelse>
					<cfset arguments.thestruct.thenewname = qry.vid_filename >
				</cfif>
			</cfif> --->

			<!--- convert the filename without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thenewname" thename="#arguments.thestruct.thenewname#">

			<!--- Create uuid for thread --->
			<cfset wvt = createuuid("")>
			<!--- Local --->
			<cfif application.razuna.storage EQ "local" AND qry.link_kind EQ "">
				<cfif theart EQ "versions">
					<cfthread name="#wvt#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid##attributes.intstruct.qry.path_to_asset#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#" mode="775">
					</cfthread>
				<cfelse>
					<cfthread name="#wvt#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.qry.vid_name_org#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#" mode="775">
					</cfthread>
				</cfif>
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon" AND qry.link_kind EQ "">
				<!--- set asset path --->
				<cfif theart EQ "versions">
					<cfset arguments.thestruct.asset_path = "/#arguments.thestruct.qry.folder_id_r#/vid/#arguments.thestruct.qry.av_id#/#arguments.thestruct.qry.av_link_title#">
				<cfelse>
					<cfset arguments.thestruct.asset_path = "/#arguments.thestruct.qry.path_to_asset#/#arguments.thestruct.qry.vid_name_org#">
				</cfif>
				<!--- Download file --->
				<cfthread name="#wvt#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Download">
						<cfinvokeargument name="key" value="#attributes.intstruct.asset_path#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
			<!--- Akamai --->
			<cfelseif application.razuna.storage EQ "akamai" AND qry.link_kind EQ "">
				<cfif theart EQ "versions">
					<cfthread name="#wvt#" intstruct="#arguments.thestruct#">
						<cfhttp url="#attributes.intstruct.qry.path_to_asset#" file="#attributes.intstruct.thenewname#" path="#attributes.intstruct.newpath#/#attributes.intstruct.thefname#/#attributes.intstruct.theart#"></cfhttp>
					</cfthread>
				<cfelse>
					<cfthread name="#wvt#" intstruct="#arguments.thestruct#">
						<cfhttp url="#attributes.intstruct.akaurl##attributes.intstruct.akavid#/#attributes.intstruct.thenewname#" file="#attributes.intstruct.thenewname#" path="#attributes.intstruct.newpath#/#attributes.intstruct.thefname#/#attributes.intstruct.theart#"></cfhttp>
					</cfthread>
				</cfif>		
			<!--- If this is a URL we write a file in the directory with the PATH --->
			<cfelseif qry.link_kind EQ "url">
				<cfthread name="#wvt#" intstruct="#arguments.thestruct#">
					<cffile action="write" file="#attributes.intstruct.thedir#/#attributes.intstruct.qry.vid_filename#.txt" output="This asset is located on a external source. Here is the direct link (or the embeeded code) to the asset:
							
#attributes.intstruct.qry.link_path_url#" mode="775">
				</cfthread>
			<!--- If this is a linked asset --->
			<cfelseif qry.link_kind EQ "lan">
				<cfthread name="#wvt#" intstruct="#arguments.thestruct#">
					<cffile action="copy" source="#attributes.intstruct.qry.link_path_url#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#" mode="775">
				</cfthread>
			</cfif>
			<!--- Wait for the thread above until the file is downloaded fully --->
			<cfthread action="join" name="#wvt#" />
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- WRITE AUDIO TO SYSTEM --->
<cffunction name="writeaudios" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset var qry = "">
	<!--- RAZ-2906 : Get the dam settings --->
	<!--- <cfinvoke component="global.cfc.settings"  method="getsettingsfromdam" returnvariable="arguments.thestruct.getsettings" /> --->
	<!--- Start the loop to get the different kinds of videos --->
	<cfloop delimiters="," list="#arguments.thestruct.artofaudio#" index="art">
		<!--- Put image id and art into variables --->
		<cfset theaudid = listfirst(art, "-")>
		<cfset theart = listlast(art, "-")>
		<cfif arguments.thestruct.theid EQ theaudid>
			<!--- Since the video format could be from the related table we need to check this here so if the value is a number it is the id for the video --->
			<cfif theart NEQ "audio" AND theart NEQ "versions">
				<cfset theaudid = theart>
				<!--- Set the video id for this type of format and set the extension --->
				<cfquery name="ext" datasource="#variables.dsn#">
				SELECT aud_extension
				FROM #session.hostdbprefix#audios
				WHERE aud_id = <cfqueryparam value="#theaudid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfset theart = ext.aud_extension & "_" & theaudid>
			</cfif>
			<!--- Query the db --->
			<cfif theart EQ "versions">
				<!--- set addtional version id --->
				<cfset theavid = listGetAt(art,2,'-')>
				<cfquery name="qry" datasource="#variables.dsn#">
					SELECT av_id,asset_id_r,folder_id_r,av_type,av_link_title,av_link_url AS path_to_asset,'' AS aud_group,'' AS link_kind, folder_id_r
					FROM #session.hostdbprefix#additional_versions
					WHERE av_id = <cfqueryparam value="#theavid#" cfsqltype="CF_SQL_VARCHAR">
					AND av_type = <cfqueryparam value="aud" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="cf_sql_numeric">
				</cfquery>
			<cfelse>
				<cfquery name="qry" datasource="#variables.dsn#">
					SELECT a.aud_name, a.aud_extension, a.aud_name_org, a.folder_id_r, a.aud_group, a.link_kind, a.link_path_url,
					a.path_to_asset, a.cloud_url_org
					FROM #session.hostdbprefix#audios a
					WHERE a.aud_id = <cfqueryparam value="#theaudid#" cfsqltype="CF_SQL_VARCHAR">
					AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
			<cfif qry.aud_group NEQ "">
				<cfset rep = replacenocase(qry.aud_name,".#qry.aud_extension#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = rep & "." & qry.aud_extension> 
				<cfset thenewname = "rend_" & thenewname>
			<cfelseif theart EQ "versions">
				<cfset theext = listlast(qry.path_to_asset,".")>
				<cfset rep = replacenocase(qry.av_link_title,".#theext#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = "add_rend_" & replacenocase(qry.av_link_title,".#theext#","") & "_" & qry.av_id & ".#theext#">
			<cfelse>
				<cfset rep = replacenocase(qry.aud_name,".#qry.aud_extension#","","one")>
				<cfset thefname = replace(rep,".","-","all")>
				<cfset thenewname = rep & "." & qry.aud_extension>
			</cfif>
			<!--- If thenewname variable contains /\ --->
			<cfset thenewname = replace(thenewname,"/","-","all")>
			<cfset thenewname = replace(thenewname,"\","-","all")>
			<!--- convert the foldername without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="thefnamewithext" thename="#thefname#">
			<cfset thefname = listfirst(thefnamewithext, ".")>
			
			<!--- Get Parent folder names --->
			<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry.folder_id_r#" returnvariable="crumbs" />
			<cfset parentfoldersname = ''>
			<cfloop list="#crumbs#" index="idx" delimiters=";">
				<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
			</cfloop>
			<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#">
			<!--- Create subfolder for the kind of image --->
			<cfif NOT directoryexists("#arguments.thestruct.thedir#")>
				<cfdirectory action="create" directory="#arguments.thestruct.thedir#" mode="775">
			</cfif>

			<!--- Put variables into struct for threads --->
			<cfset arguments.thestruct.qry = qry>
			<cfset arguments.thestruct.theaudioid = theaudid>
			<cfset arguments.thestruct.theart = theart>
			<cfset arguments.thestruct.thenewname = thenewname>
			<cfset arguments.thestruct.thefname = thefname>

			<!--- RAZ-2918:: If the file have same name in basket then rename the file --->
			<cfset var fileNameOK = true>
			<cfset var uniqueCount = 1>
			<cfset var thenameorg  = arguments.thestruct.thenewname>
			<cfloop condition="#fileNameOK#">
				<cfif fileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thenewname#")>
					<cfset arguments.thestruct.thenewname = replacenocase(thenameorg,'.'&listlast(thenameorg,'.'),'') & '_' & uniqueCount & '.' & listLast(arguments.thestruct.thenewname,'.')> 
					<cfset uniqueCount = uniqueCount + 1>
				<cfelse>
					<cfset fileNameOK = false>	
				</cfif>	
			</cfloop>

			<!--- RAZ-2906: Check the settings for download assets with ext or not  --->
			<!--- <cfif theart EQ "versions">
				<cfset var name = qry.av_link_title>
				<cfset var orgname = listfirst(qry.av_link_title,".")>
			<cfelse>
				<cfset var name = qry.aud_name>
				<cfset var orgname = listfirst(qry.aud_name_org,".")>
			</cfif>
			<cfif structKeyExists(arguments.thestruct.getsettings,"set2_custom_file_ext") AND arguments.thestruct.getsettings.set2_custom_file_ext EQ "false">
				<cfif name EQ orgname>
					<cfset arguments.thestruct.thenewname = qry.aud_name >
				<cfelse>
					<cfset arguments.thestruct.thenewname = qry.aud_name >
				</cfif>
			</cfif> --->

			<!--- convert the filename without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thenewname" thename="#arguments.thestruct.thenewname#">

			<!--- Local --->
			<cfif application.razuna.storage EQ "local" AND qry.link_kind EQ "">
				<cfif theart EQ "versions">
					<cfthread name="download#theart##theaudid#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid##attributes.intstruct.qry.path_to_asset#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#" mode="775">
					</cfthread>
				<cfelse>
					<cfthread name="download#theart##theaudid#" intstruct="#arguments.thestruct#">
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.qry.aud_name_org#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#" mode="775">
					</cfthread>
				</cfif>
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon" AND qry.link_kind EQ "">
				<!--- set asset path --->
				<cfif theart EQ "versions">
					<cfset arguments.thestruct.asset_path = "/#arguments.thestruct.qry.folder_id_r#/aud/#arguments.thestruct.qry.av_id#/#arguments.thestruct.qry.av_link_title#">
				<cfelse>
					<cfset arguments.thestruct.asset_path = "/#arguments.thestruct.qry.path_to_asset#/#arguments.thestruct.qry.aud_name_org#">
				</cfif>
				<!--- Download file --->
				<cfthread name="download#theart##theaudid#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Download">
						<cfinvokeargument name="key" value="#attributes.intstruct.asset_path#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
			<!--- Akamai --->
			<cfelseif application.razuna.storage EQ "akamai" AND qry.link_kind EQ "">
				<cfif theart EQ "versions">
					<cfthread name="download#theart##theaudid#" intstruct="#arguments.thestruct#">
						<cfhttp url="#attributes.intstruct.qry.path_to_asset#" file="#attributes.intstruct.thenewname# " path="#attributes.intstruct.newpath#/#attributes.intstruct.thefname#/#attributes.intstruct.theart#"></cfhttp>
					</cfthread>
				<cfelse>
					<cfthread name="download#theart##theaudid#" intstruct="#arguments.thestruct#">
						<cfhttp url="#attributes.intstruct.akaurl##attributes.intstruct.akaaud#/#attributes.intstruct.thefinalname#" file="#attributes.intstruct.thenewname# " path="#attributes.intstruct.newpath#/#attributes.intstruct.thefname#/#attributes.intstruct.theart#"></cfhttp>
					</cfthread>
				</cfif>
			<!--- If this is a URL we write a file in the directory with the PATH --->
			<cfelseif qry.link_kind EQ "url">
				<cfthread name="download#theart##theaudid#" intstruct="#arguments.thestruct#">
					<cffile action="write" file="#attributes.intstruct.thedir#/#attributes.intstruct.qry.aud_name#.txt" output="This asset is located on a external source. Here is the direct link to the asset:
							
#attributes.intstruct.qry.link_path_url#" mode="775">
				</cfthread>
			<!--- If this is a linked asset --->
			<cfelseif qry.link_kind EQ "lan">
				<cfthread name="download#theart##theaudid#" intstruct="#arguments.thestruct#">
					<cfif attributes.intstruct.theart EQ "audio">
						<cffile action="copy" source="#attributes.intstruct.qry.link_path_url#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#" mode="775">
					<!--- different format --->
					<cfelse>
						<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.qry.aud_name_org#" destination="#attributes.intstruct.thedir#/#attributes.intstruct.thenewname#" mode="775">
					</cfif>
				</cfthread>
			</cfif>
			<!--- Wait for the thread above until the file is downloaded fully --->
			<cfthread action="join" name="download#theart##theaudid#" />
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- ORDER BASKET --->
<cffunction name="basket_order" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Query user info --->
	<cfquery datasource="#variables.dsn#" name="qry_user">
	SELECT u.user_email, f.share_order_user
	FROM users u, #session.hostdbprefix#folders f
	WHERE f.folder_id = <cfqueryparam value="#session.fid#" cfsqltype="CF_SQL_VARCHAR">
	AND f.share_order_user = u.user_id
	</cfquery>
	<!--- Save info --->
	<cfquery datasource="#variables.dsn#">
	UPDATE #session.hostdbprefix#cart
	SET
	cart_order_email = <cfqueryparam value="#arguments.thestruct.cart_order_email#" cfsqltype="cf_sql_varchar">,
	cart_order_message = <cfqueryparam value="#arguments.thestruct.cart_order_message#" cfsqltype="cf_sql_varchar">,
	cart_order_done = <cfqueryparam value="0" cfsqltype="cf_sql_varchar">,
	cart_order_date = <cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP">,
	cart_order_user_r = <cfqueryparam value="#qry_user.share_order_user#" cfsqltype="CF_SQL_VARCHAR">
	WHERE cart_id = <cfqueryparam value="#session.thecart#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<!--- Get date format --->
	<cfinvoke component="defaults" method="getdateformat" dsn="#variables.dsn#" returnVariable="thedateformat" />
	<!--- Send out eMail to the one who is responsible for Orders --->
	<cfset var thesubject = "Basket Order: #session.thecart#">
	<cfset var mailmessage = "Hello,
		The below order just came in:
		
		Basket Order: #session.thecart#
		Date: #dateformat(now(), "#thedateformat#")#
		
		Log in to Razuna to process this order.">
	<cftry>
		<cfinvoke component="email" method="send_email" to="#qry_user.user_email#" subject="#thesubject#" themessage="#mailmessage#">
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while sending email in function basket.basket_order">
			<cfset errObj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- Read Orders --->
<cffunction name="get_orders" output="false">
	<!--- Read orders --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#get_orders */ cart_id, cart_order_date, cart_order_done
	FROM #session.hostdbprefix#cart
	WHERE cart_order_done IS NOT NULL
	AND cart_order_user_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
	GROUP BY cart_id, cart_order_date, cart_order_done
	</cfquery>
	<cfreturn qry />
</cffunction>

<!--- Read Orders --->
<cffunction name="set_done" output="true">
	<!--- Read orders --->
	<cfquery datasource="#variables.dsn#">
	UPDATE #session.hostdbprefix#cart
	SET cart_order_done = <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">
	WHERE cart_id = <cfqueryparam value="#session.thecart#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfoutput>Done!</cfoutput>
	<cfreturn />
</cffunction>

</cfcomponent>