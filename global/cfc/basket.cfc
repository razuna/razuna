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
		<cfquery datasource="#application.razuna.datasource#" name="here">
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
			<!--- Sometimes we have a 0 in the list, filter this out --->
			<cfif thenr NEQ 0 AND len(thetype) LTE 5>
				<!--- insert the prodcut to the cart --->
				<cfquery datasource="#application.razuna.datasource#">
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
			</cfif>
		</cfif>
	</cfloop>
	<!--- Remove expired assets from cart --->
	<cfquery datasource="#application.razuna.datasource#" name="removeexpired">
		<cfif application.razuna.thedatabase NEQ "h2">
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
		<cfelse>
		DELETE FROM #session.hostdbprefix#cart c
			WHERE EXISTS (
			SELECT 1 FROM #session.hostdbprefix#cart cc
			LEFT JOIN #session.hostdbprefix#images i ON cc.cart_product_id = i.img_id AND cc.cart_file_type = 'img'
			LEFT JOIN #session.hostdbprefix#audios a ON cc.cart_product_id = a.aud_id AND cc.cart_file_type = 'aud'
			LEFT JOIN #session.hostdbprefix#videos v ON cc.cart_product_id = v.vid_id AND cc.cart_file_type = 'vid'
			LEFT JOIN #session.hostdbprefix#files f ON cc.cart_product_id = f.file_id AND cc.cart_file_type = 'doc'
			WHERE
			c.cart_product_id=cc.cart_product_id
			AND
			(i.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR a.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR v.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR f.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			)
		)
		</cfif>
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- READ BASKET --->
<cffunction name="readbasket" output="false" returnType="query">
	<cfset var qry = "">
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
	<cfset var getbasket = readbasket()>
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
	<cfparam default="false" name="arguments.thestruct.skipduplicates">
	<!--- Feedback --->
	<cfif !arguments.thestruct.noemail>
	<cfinvoke component="defaults" method="trans" transid="download_basket_output" returnvariable="download_basket_output" />
	<!--- Feedback --->
	<cfoutput><br/><strong>#download_basket_output#</strong><br /></cfoutput>
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
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Feedback --->
	<cfif !arguments.thestruct.noemail>
		<cfinvoke component="defaults" method="trans" transid="download_basket_output2" returnvariable="download_basket_output2" />
		<!--- Feedback --->
		<cfoutput><br /><strong>#download_basket_output2#</strong><br /><br /></cfoutput>
		<cfflush>
	</cfif>
	<!--- Create directory --->
	<cfset var basketname = createuuid("")>
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
					<cfoutput><strong>Getting image "#filename#"</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Write Image --->
				<cfinvoke method="writeimages" thestruct="#arguments.thestruct#">
			</cfcase>
			<!--- Videos --->
			<cfcase value="vid">
				<!--- Feedback --->
				<cfif !arguments.thestruct.noemail>
					<cfoutput><strong>Getting video "#filename#"</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Write Video --->
				<cfinvoke method="writevideos" thestruct="#arguments.thestruct#">
			</cfcase>
			<!--- Audios --->
			<cfcase value="aud">
				<!--- Feedback --->
				<cfif !arguments.thestruct.noemail>
					<cfoutput><strong>Getting audio "#filename#"</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Write Video --->
				<cfinvoke method="writeaudios" thestruct="#arguments.thestruct#">
			</cfcase>
			<!--- All other files --->
			<cfdefaultcase>
				<!--- Feedback --->
				<cfif !arguments.thestruct.noemail>
					<cfoutput><strong>Getting file "#filename#"</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Write file --->
				<cfinvoke method="writefiles" thestruct="#arguments.thestruct#">
			</cfdefaultcase>
		</cfswitch>
	</cfloop>
	<!--- Feedback --->
	<cfif !arguments.thestruct.noemail>
		<cfinvoke component="defaults" method="trans" transid="download_basket_output4" returnvariable="download_basket_output4" />
		<cfoutput><strong>#download_basket_output4#</strong><br><br></cfoutput>
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
	<cfif arguments.thestruct.prefs.set2_meta_export EQ 't'>
		<cfif isdefined("arguments.thestruct.exportname")>
			<cfset var suffix = "#arguments.thestruct.exportname#">
		<cfelse>
			<cfset var suffix = "#session.hostid#-#session.theuserid#">
		</cfif>
		<cfif fileExists("#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv")>
			<cffile action="move" destination="#arguments.thestruct.newpath#" source="#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv">
		</cfif>
	</cfif>
	<!--- Zip the folder --->
	<cfthread name="#basketname#" intstruct="#arguments.thestruct#">
		<cfzip action="create" ZIPFILE="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.zipname#" source="#attributes.intstruct.newpath#" recurse="true" timeout="300" />
	</cfthread>
	<!--- Get thread status --->
	<cfset var thethread=cfthread["#basketname#"]> 
	<!--- Output to page to prevent it from timing out while thread is running --->
	<cfloop condition="#thethread.status# EQ 'RUNNING' OR thethread.Status EQ 'NOT_STARTED' "> <!--- Wait till thread is finished --->
		<cfoutput> . </cfoutput>
		<cfset sleep(3000) > 
		<cfflush>
	</cfloop>
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
		<cfinvoke component="email" method="send_email" subject="#basket_download_available_sub#" themessage="#basket_download_available_msg# <br/> <a href='#session.thehttp##cgi.HTTP_HOST##sn#/outgoing/#arguments.thestruct.zipname#'>#session.thehttp##cgi.HTTP_HOST##sn#/outgoing/#arguments.thestruct.zipname#</a>">
	</cfif>
	<!--- Feedback --->
	<cfif !arguments.thestruct.noemail>
		<cfinvoke component="defaults" method="trans" transid="download_basket_output3" returnvariable="download_basket_output3" />
		<cfoutput><br/><br/><strong style="color:green;"><a href="#session.thehttp##cgi.HTTP_HOST##sn#/outgoing/#arguments.thestruct.zipname#" style="color:green;">#download_basket_output3#</a></strong><br><br></cfoutput>
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
		<cfset var thefileid = listfirst(art, "-")>
		<cfset var theart = listlast(art, "-")>
		<cfif arguments.thestruct.theid EQ thefileid>
			<!--- Create thread  --->
			<cfset var ttd = createuuid()>
			<!--- Query --->
			<cfif theart EQ "versions" >
				<!--- set addtional version id --->
				<cfset var theavid = listGetAt(art,2,'-')>
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
				<cfset var theext = listlast(arguments.thestruct.qry.path_to_asset,".")>
				<!--- Check that the filename has an extension --->
				<cfset var rep = replacenocase(arguments.thestruct.qry.av_link_title,".#theext#","","one")>
				<cfset var thename = replace(rep,".","-","all")>
				<!--- If thenewname variable contains /\ --->
				<cfset var thename = replace(thename,"/","-","all")>
				<cfset var thename = replace(thename,"\","-","all")>
				<cfset arguments.thestruct.thename =  "add_rend_" & thename & "_" & arguments.thestruct.qry.av_id & ".#theext#">
			<cfelse>
				<!--- Check that the filename has an extension --->
				<cfset var rep = replacenocase(arguments.thestruct.qry.file_name,".#arguments.thestruct.qry.file_extension#","","one")>
				<cfset var thename = replace(rep,".","-","all")>
				<!--- If thenewname variable contains /\ --->
				<cfset var thename = replace(thename,"/","-","all")>
				<cfset var thename = replace(thename,"\","-","all")>
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
			<cfset var parentfoldersname = ''>
			<cfloop list="#crumbs#" index="idx" delimiters=";">
				<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
			</cfloop>
			<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#">
			<!--- If local directory for upload defined and this is not AWS copy then use the upload directory else create diretory --->
			<cfif isdefined("arguments.thestruct.localupload")AND NOT isdefined("arguments.thestruct.awsdatasource") >
				<cfset arguments.thestruct.thedir = arguments.thestruct.uploaddir>
			<cfelseif NOT directoryexists("#arguments.thestruct.thedir#")>
				<cfdirectory action="create" directory="#arguments.thestruct.thedir#" mode="775">
			</cfif>

			<!--- Copying to AWS --->
			<cfif isdefined("arguments.thestruct.awsdatasource") AND isdefined("arguments.thestruct.awsbucket")>
				<cfif theart EQ "versions">
					<cfset var thefilepath = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qry.path_to_asset#">
				<cfelse>
					<cfset var thefilepath = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qry.path_to_asset#/#arguments.thestruct.qry.file_name_org#">
				</cfif>
				<cfset var awsfileexists = false>
				<!--- convert the filename without space and foreign chars --->
				<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thename" thename="#arguments.thestruct.thename#">
				<cfif arguments.thestruct.skipduplicates><!--- If skip duplicate is on then look to see if file already is on AWS --->
					<cfloop query="arguments.thestruct.s3list">
						<cfif etag NEQ ''> <!--- Ignore folders --->
							<cfif arguments.thestruct.s3list.key EQ arguments.thestruct.thename>
								<cfset awsfileexists = true>
								<cfbreak>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
				<cfset var epoch = dateadd("yyyy", 10, now())>
				<cfif !awsfileexists>
					<cfset var fileext = listlast(thefilepath,'.')>
					<cffile action="rename" source="#thefilepath#" destination="#replacenocase(thefilepath,'.#fileext#','.zip')#">
					<cftry>
						<cfset AmazonS3write(
							datasource='#arguments.thestruct.awsdatasource#',
							bucket='#arguments.thestruct.awsbucket#',
							file='#replacenocase(thefilepath,'.#fileext#','.zip')#',
							key='#arguments.thestruct.thename#'
						)>
						<cfset AmazonS3setacl(
							datasource='#arguments.thestruct.awsdatasource#',
							bucket='#arguments.thestruct.awsbucket#',
							key='#arguments.thestruct.thename#',
							acl = 'public-read'
						)>
						<cfif art contains "doc">
							<cfset arguments.thestruct.theawsurl["#arguments.thestruct.thename#"] = AmazonS3geturl(
							 datasource='#arguments.thestruct.awsdatasource#',
							 bucket='#arguments.thestruct.awsbucket#',
							 key='#arguments.thestruct.thename#',
							 expiration=epoch
							)>
							<cfif arguments.thestruct.cs.basket_awsurl NEQ "">
								<cfset arguments.thestruct.theawsurl["#arguments.thestruct.thename#"] = replacenocase(arguments.thestruct.theawsurl["#arguments.thestruct.thename#"] ,"https://s3.amazonaws.com","#arguments.thestruct.cs.basket_awsurl#","ALL")>
							</cfif>
						</cfif>
						<cffile action="rename" destination="#thefilepath#" source="#replacenocase(thefilepath,'.#fileext#','.zip')#">
						<cfcatch>
							<!--- Rename file back if any error happens --->
							<cffile action="rename"destination="#thefilepath#" source="#replacenocase(thefilepath,'.#fileext#','.zip')#">
							<cfthrow detail="#cfcatch.detail#<br/>#cfcatch.message#">
						</cfcatch>
					</cftry>
					<cfcontinue>
				</cfif>
				<cfcontinue>
			</cfif>

			<!--- If skip duplicates is on then ignore file if it already exists intead of renaming it --->
			<cfif arguments.thestruct.skipduplicates AND fileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thename#")>
				<cfcontinue>
			</cfif>

			<!--- RAZ-2918:: If the file have same name in basket then rename the file --->
			<cfset var thenameorg = arguments.thestruct.thename>
			<cfset var fileNameOK = true>
			<cfset var uniqueCount = 1>
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
		<cfset var thethreadid = createuuid("")>
		<!--- Put image id and art into variables --->
		<cfset var theimgid = listfirst(art, "-")>
		<cfset var theart = listlast(art, "-")>
		<cfif arguments.thestruct.theid EQ theimgid>
			<!--- set the correct img_id for related assets --->
			<cfif theart NEQ "original" AND theart NEQ "thumb" AND theart NEQ "versions">
				<cfset theimgid = theart>
			</cfif>
			<!--- Query the db --->
			<cfif theart EQ "versions">
				<!--- set addtional version id --->
				<cfset var theavid = listGetAt(art,2,'-')>
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
				<cfset var theimgname = "thumb_#theimgid#.#qry.thumb_extension#">
				<cfset var thefinalname = theimgname>
				<cfset var theext = qry.thumb_extension>
			<cfelseif theart EQ "versions">
				<cfset var theimgname = qry.av_link_title>
				<cfset var theext = listlast(qry.path_to_asset,".")>
				<cfset var thefinalname = "add_rend_" & replacenocase(qry.av_link_title,".#theext#","") & "_" & qry.av_id & ".#theext#">
			<cfelse>
				<cfset var theimgname = qry.img_filename_org>
				<cfset var thefinalname = qry.img_filename>
				<cfset var theext = qry.img_extension>
				<cfset var theart = theext>
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
				<cfset var rep = replacenocase(qrysub.img_filename,".#qrysub.img_extension#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = rep & "." & theext>
				<cfset var thefinalname = "rend_" & replacenocase(thefinalname,".#theext#","","one") &  "." & theext>
				<cfset var theart = theext & "_" & theimgid>
				<cfset var upcnum = qrysub.upcnum>
			<cfelseif theart EQ "versions">
				<cfset var rep = replacenocase(qry.av_link_title,".#theext#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = qry.av_link_title>
			<cfelse>
				<!--- The filename for the folder --->
				<cfset var rep = replacenocase(qry.img_filename,".#qry.img_extension#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = rep & "." & theext>
			</cfif>
			<!--- If thenewname variable contains /\ --->
			<cfset var thenewname = replace(thenewname,"/","-","all")>
			<cfset thenewname = replace(thenewname,"\","-","all")>
			<!--- convert the foldername without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="thefnamewithext" thename="#thefname#">
			<cfset var thefname = listfirst(thefnamewithext, ".")>

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
			 	<cfset var fn_last_char = "">
			 	<cfquery name="qry_upcgrp" dbtype="query">
					SELECT * FROM arguments.thestruct.qry_GroupsOfUser WHERE upc_size <>'' AND upc_size is not null
				</cfquery>
				<cfif qry_upcgrp.recordcount gt 1>
					<cfinvoke component="defaults" method="trans" transid="upc_user_multi_grps" returnvariable="upc_user_multi_grps" />
					<cftry>
					<cfthrow message="User is in more than one UPC group which is not allowed.">
					 <cfcatch type="any">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
						<cfoutput><font color="##CD5C5C"><strong>#upc_user_multi_grps#</strong></font> </cfoutput>
						<cfabort>
					</cfcatch>
					</cftry>
				</cfif>
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
							<!--- Check if last char is alphabet and if it is then inlcude in filename for download --->
							<cfset fn_last_char = right(listfirst(thefilename,'.'),1)> 
							<cfif not isnumeric(fn_last_char)>
								<cfset var fn_ischar = true>
							<cfelse>
								<cfset fn_ischar = false>
								<cfset fn_last_char = "">
							</cfif>
					</cfif>

					<cfset arguments.thestruct.thefinalname = "#upcinfo.upcprodstr##fn_last_char##rendition_version#">
					<!--- Remove extension from filenames for UPC --->
					<cfset arguments.thestruct.thefinalname = replacenocase(replacenocase(arguments.thestruct.thefinalname,".#theext#","","ALL"),".jpg","ALL")>
				</cfif>
			</cfif>
			
			<!--- ************** UPC SPECIFIC CODE ENDS **************** --->

			<!--- Get Parent folder names --->
			<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry.folder_id_r#" returnvariable="crumbs" />
			<cfset var parentfoldersname = ''>
			<cfloop list="#crumbs#" index="idx" delimiters=";">
				<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
			</cfloop>
			<cfif upcstruct.upcenabled AND upcstruct.createupcfolder>
				<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#/#upcinfo.upcmanufstr#">
			<cfelse>
				<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#">
			</cfif>
			<!--- If local directory for upload defined and this is not AWS copy then use the upload directory else create diretory --->
			<cfif isdefined("arguments.thestruct.localupload") AND NOT isdefined("arguments.thestruct.awsdatasource")>
				<cfset arguments.thestruct.thedir = arguments.thestruct.uploaddir>
			<cfelseif NOT directoryexists("#arguments.thestruct.thedir#")>
				<cfdirectory action="create" directory="#arguments.thestruct.thedir#" mode="775">
			</cfif>
			<!--- If extension is missing then put it in  --->
			<cfif !upcstruct.upcenabled AND listlast(arguments.thestruct.thefinalname,'.') NEQ theext>
				<cfset arguments.thestruct.thefinalname = arguments.thestruct.thefinalname & ".#theext#">
			</cfif>

			<!--- RAZ-2918:: If the file have same name in basket then rename the file --->
			<cfset var fileNameOK = true>
			<cfset var uniqueCount = 1>
			<cfset var thenameorg = arguments.thestruct.thefinalname>

			<!--- Copying to AWS --->
			<cfif isdefined("arguments.thestruct.awsdatasource") AND isdefined("arguments.thestruct.awsbucket")>
				<cfif theart EQ "versions">
					<cfset var thefilepath = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qry.path_to_asset#">
				<cfelse>
					<cfset var thefilepath = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qry.path_to_asset#/#arguments.thestruct.theimgname#">
				</cfif>
				<cfset var awsfileexists = false>
				<!--- convert the filename without space and foreign chars --->
				<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefinalname" thename="#arguments.thestruct.thefinalname#">
				<cfif arguments.thestruct.skipduplicates><!--- If skip duplicate is on then look to see if file already is on AWS --->
					<cfloop query="arguments.thestruct.s3list">
						<cfif etag NEQ ''> <!--- Ignore folders --->
							<cfif arguments.thestruct.s3list.key EQ arguments.thestruct.thefinalname>
								<cfset awsfileexists = true>
								<cfbreak>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
				
				<cfset var epoch = dateadd("yyyy", 10, now())>
				<cfif !awsfileexists>
					<cfset var fileext = listlast(thefilepath,'.')>
					<cffile action="rename" source="#thefilepath#" destination="#replacenocase(thefilepath,'.#fileext#','.zip')#">
					<cftry>
						<cfset AmazonS3write(
							datasource='#arguments.thestruct.awsdatasource#',
							bucket='#arguments.thestruct.awsbucket#',
							file='#replacenocase(thefilepath,'.#fileext#','.zip')#',
							key='#arguments.thestruct.thefinalname#'
						)>
						<cfset AmazonS3setacl(
							datasource='#arguments.thestruct.awsdatasource#',
							bucket='#arguments.thestruct.awsbucket#',
							key='#arguments.thestruct.thefinalname#',
							acl = 'public-read'
						)>
						<cfif art contains "original">
							<cfset arguments.thestruct.theawsurl["#arguments.thestruct.thefinalname#"] = AmazonS3geturl(
							 datasource='#arguments.thestruct.awsdatasource#',
							 bucket='#arguments.thestruct.awsbucket#',
							 key='#arguments.thestruct.thefinalname#',
							 expiration=epoch
							)>
							<cfif arguments.thestruct.cs.basket_awsurl NEQ "">
								<cfset arguments.thestruct.theawsurl["#arguments.thestruct.thefinalname#"] = replacenocase(arguments.thestruct.theawsurl["#arguments.thestruct.thefinalname#"] ,"https://s3.amazonaws.com","#arguments.thestruct.cs.basket_awsurl#","ALL")>
							</cfif>
						</cfif>
						<cffile action="rename" destination="#thefilepath#" source="#replacenocase(thefilepath,'.#fileext#','.zip')#">
						<cfcatch>
							<!--- Rename file back if any error happens --->
							<cffile action="rename"destination="#thefilepath#" source="#replacenocase(thefilepath,'.#fileext#','.zip')#">
							<cfthrow detail="#cfcatch.detail#<br/>#cfcatch.message#">
						</cfcatch>
					</cftry>
					<cfcontinue>
				</cfif>
			</cfif>

			<!--- If skip duplicates is on then ignore file if it already exists intead of renaming it --->
			<cfif arguments.thestruct.skipduplicates AND fileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thefinalname#")>
				<cfcontinue>
			</cfif>

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
		<cfset var thevidid = listfirst(art, "-")>
		<cfset var theart = listlast(art, "-")>
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
				<cfset var theavid = listGetAt(art,2,'-')>
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
				<cfset var rep = replacenocase(qry.vid_filename,".#qry.vid_extension#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = rep & "." & qry.vid_extension> 
				<cfset thenewname = "rend_" & thenewname>
			<cfelseif theart EQ "versions">
				<cfset var theext = listlast(qry.path_to_asset,".")>
				<cfset var rep = replacenocase(qry.av_link_title,".#theext#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = "add_rend_" & replacenocase(qry.av_link_title,".#theext#","") & "_" & qry.av_id & ".#theext#">
			<cfelse>
				<!--- The filename for the folder --->
				<cfset var rep = replacenocase(qry.vid_filename,".#qry.vid_extension#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = rep & "." & qry.vid_extension>
			</cfif>
			<!--- If thenewname variable contains /\ --->
			<cfset var thenewname = replace(thenewname,"/","-","all")>
			<cfset thenewname = replace(thenewname,"\","-","all")>
			
			<!--- convert the foldername without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="thefnamewithext" thename="#thefname#">
			<cfset var thefname = listfirst(thefnamewithext, ".")>
			
			<!--- Get Parent folder names --->
			<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry.folder_id_r#" returnvariable="crumbs" />
			<cfset var parentfoldersname = ''>
			<cfloop list="#crumbs#" index="idx" delimiters=";">
				<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
			</cfloop>
			<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#">
			<!--- If local directory for upload defined and this is not AWS copy then use the upload directory else create diretory --->
			<cfif isdefined("arguments.thestruct.localupload") AND NOT isdefined("arguments.thestruct.awsdatasource") >
				<cfset arguments.thestruct.thedir = arguments.thestruct.uploaddir>
			<cfelseif NOT directoryexists("#arguments.thestruct.thedir#")>
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

			<!--- Copying to AWS --->
			<cfif isdefined("arguments.thestruct.awsdatasource") AND isdefined("arguments.thestruct.awsbucket")>
				<cfif theart EQ "versions">
					<cfset var thefilepath = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qry.path_to_asset#">
				<cfelse>
					<cfset var thefilepath = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qry.path_to_asset#/#arguments.thestruct.qry.vid_name_org#">
				</cfif>

				<cfset var awsfileexists = false>
				<!--- convert the filename without space and foreign chars --->
				<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thenewname" thename="#arguments.thestruct.thenewname#">
				<cfif arguments.thestruct.skipduplicates><!--- If skip duplicate is on then look to see if file already is on AWS --->
					<cfloop query="arguments.thestruct.s3list">
						<cfif etag NEQ ''> <!--- Ignore folders --->
							<cfif arguments.thestruct.s3list.key EQ arguments.thestruct.thenewname>
								<cfset awsfileexists = true>
								<cfbreak>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
				<cfset var epoch = dateadd("yyyy", 10, now())>
				<cfif !awsfileexists>
					<cfset var fileext = listlast(thefilepath,'.')>
					<cffile action="rename" source="#thefilepath#" destination="#replacenocase(thefilepath,'.#fileext#','.zip')#">
					<cftry>
						<cfset AmazonS3write(
							datasource='#arguments.thestruct.awsdatasource#',
							bucket='#arguments.thestruct.awsbucket#',
							file='#replacenocase(thefilepath,'.#fileext#','.zip')#',
							key='#arguments.thestruct.thenewname#'
						)>
						<cfset AmazonS3setacl(
							datasource='#arguments.thestruct.awsdatasource#',
							bucket='#arguments.thestruct.awsbucket#',
							key='#arguments.thestruct.thenewname#',
							acl = 'public-read'
						)>
						<cfif art contains "video">
							<cfset arguments.thestruct.theawsurl["#arguments.thestruct.thenewname#"] = AmazonS3geturl(
							 datasource='#arguments.thestruct.awsdatasource#',
							 bucket='#arguments.thestruct.awsbucket#',
							 key='#arguments.thestruct.thenewname#',
							 expiration=epoch
							)>
						</cfif>
						<cfif arguments.thestruct.cs.basket_awsurl NEQ "">
							<cfset arguments.thestruct.theawsurl["#arguments.thestruct.thenewname#"] = replacenocase(arguments.thestruct.theawsurl["#arguments.thestruct.thenewname#"] ,"https://s3.amazonaws.com","#arguments.thestruct.cs.basket_awsurl#","ALL")>
						</cfif>
						<cffile action="rename" destination="#thefilepath#" source="#replacenocase(thefilepath,'.#fileext#','.zip')#">
						<cfcatch>
							<!--- Rename file back if any error happens --->
							<cffile action="rename"destination="#thefilepath#" source="#replacenocase(thefilepath,'.#fileext#','.zip')#">
							<cfthrow detail="#cfcatch.detail#<br/>#cfcatch.message#">
						</cfcatch>
					</cftry>
					<cfcontinue>
				</cfif>
				<cfcontinue>
			</cfif>

			<!--- If skip duplicates is on then ignore file if it already exists intead of renaming it --->
			<cfif arguments.thestruct.skipduplicates AND fileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thenewname#")>
				<cfcontinue>
			</cfif>

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
			<cfset var wvt = createuuid("")>
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
		<cfset var theaudid = listfirst(art, "-")>
		<cfset var theart = listlast(art, "-")>
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
				<cfset var theavid = listGetAt(art,2,'-')>
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
				<cfset var rep = replacenocase(qry.aud_name,".#qry.aud_extension#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = rep & "." & qry.aud_extension> 
				<cfset var thenewname = "rend_" & thenewname>
			<cfelseif theart EQ "versions">
				<cfset theext = listlast(qry.path_to_asset,".")>
				<cfset var rep = replacenocase(qry.av_link_title,".#theext#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = "add_rend_" & replacenocase(qry.av_link_title,".#theext#","") & "_" & qry.av_id & ".#theext#">
			<cfelse>
				<cfset var rep = replacenocase(qry.aud_name,".#qry.aud_extension#","","one")>
				<cfset var thefname = replace(rep,".","-","all")>
				<cfset var thenewname = rep & "." & qry.aud_extension>
			</cfif>
			<!--- If thenewname variable contains /\ --->
			<cfset var thenewname = replace(thenewname,"/","-","all")>
			<cfset thenewname = replace(thenewname,"\","-","all")>
			<!--- convert the foldername without space and foreign chars --->
			<cfinvoke component="global" method="convertname" returnvariable="thefnamewithext" thename="#thefname#">
			<cfset var thefname = listfirst(thefnamewithext, ".")>
			
			<!--- Get Parent folder names --->
			<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry.folder_id_r#" returnvariable="crumbs" />
			<cfset var parentfoldersname = ''>
			<cfloop list="#crumbs#" index="idx" delimiters=";">
				<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
			</cfloop>
			<cfset arguments.thestruct.thedir = "#arguments.thestruct.newpath#/#parentfoldersname#">
			<!--- If local directory for upload defined and this is not AWS copy then use the upload directory else create diretory --->
			<cfif isdefined("arguments.thestruct.localupload") AND NOT isdefined("arguments.thestruct.awsdatasource")>
				<cfset arguments.thestruct.thedir = arguments.thestruct.uploaddir>
			<cfelseif NOT directoryexists("#arguments.thestruct.thedir#")>
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

			<!--- If copying to AWS --->
			<cfif isdefined("arguments.thestruct.awsdatasource") AND isdefined("arguments.thestruct.awsbucket")>
				<cfif theart EQ "versions">
					<cfset var thefilepath = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qry.path_to_asset#">
				<cfelse>
					<cfset var thefilepath = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qry.path_to_asset#/#arguments.thestruct.qry.aud_name_org#">
				</cfif>

				<cfset var awsfileexists = false>
				<!--- convert the filename without space and foreign chars --->
				<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thenewname" thename="#arguments.thestruct.thenewname#">
				<cfif arguments.thestruct.skipduplicates><!--- If skip duplicate is on then look to see if file already is on AWS --->
					<cfloop query="arguments.thestruct.s3list">
						<cfif etag NEQ ''> <!--- Ignore folders --->
							<cfif arguments.thestruct.s3list.key EQ arguments.thestruct.thenewname>
								<cfset awsfileexists = true>
								<cfbreak>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
				<cfset var epoch = dateadd("yyyy", 10, now())>
				<cfif !awsfileexists>
					<cfset var fileext = listlast(thefilepath,'.')>
					<cffile action="rename" source="#thefilepath#" destination="#replacenocase(thefilepath,'.#fileext#','.zip')#">
					<cftry>
						<cfset AmazonS3write(
							datasource='#arguments.thestruct.awsdatasource#',
							bucket='#arguments.thestruct.awsbucket#',
							file='#replacenocase(thefilepath,'.#fileext#','.zip')#',
							key='#arguments.thestruct.thenewname#'
						)>
						<cfset AmazonS3setacl(
							datasource='#arguments.thestruct.awsdatasource#',
							bucket='#arguments.thestruct.awsbucket#',
							key='#arguments.thestruct.thenewname#',
							acl = 'public-read'
						)>
						<cfif art contains "audio">
							<cfset arguments.thestruct.theawsurl["#arguments.thestruct.thenewname#"] = AmazonS3geturl(
							 datasource='#arguments.thestruct.awsdatasource#',
							 bucket='#arguments.thestruct.awsbucket#',
							 key='#arguments.thestruct.thenewname#',
							 expiration=epoch
							)>
							<cfif arguments.thestruct.cs.basket_awsurl NEQ "">
								<cfset arguments.thestruct.theawsurl["#arguments.thestruct.thenewname#"] = replacenocase(arguments.thestruct.theawsurl["#arguments.thestruct.thenewname#"] ,"https://s3.amazonaws.com","#arguments.thestruct.cs.basket_awsurl#","ALL")>
							</cfif>
						</cfif>
						<cffile action="rename" destination="#thefilepath#" source="#replacenocase(thefilepath,'.#fileext#','.zip')#">
						<cfcatch>
							<!--- Rename file back if any error happens --->
							<cffile action="rename"destination="#thefilepath#" source="#replacenocase(thefilepath,'.#fileext#','.zip')#">
							<cfthrow detail="#cfcatch.detail#<br/>#cfcatch.message#">
						</cfcatch>
					</cftry>
					<cfcontinue>
				</cfif>
				<cfcontinue>
			</cfif>

			<!--- If skip duplicates is on then ignore file if it already exists intead of renaming it --->
			<cfif arguments.thestruct.skipduplicates AND fileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thenewname#")>
				<cfcontinue>
			</cfif>

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
		The below order just came in:<br/><br/>
		
		Basket Order: #session.thecart#<br/>
		Date: #dateformat(now(), "#thedateformat#")#<br/><br/>
		
		Log in to Razuna to process this order.">
	<cftry>
		<cfinvoke component="email" method="send_email" to="#qry_user.user_email#" subject="#thesubject#" themessage="#mailmessage#">
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while sending email in function basket.basket_order">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- Read Orders --->
<cffunction name="get_orders" output="false">
	<cfset var qry = "">
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


<!--- WRITE FILES IN BASKET TO LOCAL FOLDER --->
<cffunction name="writebasket2local" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam default="" name="arguments.thestruct.artofimage">
	<cfparam default="" name="arguments.thestruct.artofvideo">
	<cfparam default="" name="arguments.thestruct.artoffile">
	<cfparam default="" name="arguments.thestruct.artofaudio">
	<cfparam default="false" name="arguments.thestruct.noemail">
	<cfparam default="" name="arguments.thestruct.newpath" >
	<cfparam default="true" name="arguments.thestruct.skipduplicates">
	<cfparam default="true" name="arguments.thestruct.localupload">
	<cftry>

		<cfset var res = structnew()>
		<cfset res.progress = 0>
		<cfif NOT directoryexists("#arguments.thestruct.uploaddir#")>
			<cfset res.message  = "<p><font color='##cd5c5c'>Directory not found. Please check path and try again.</font></p>">
			<cfoutput>#serializeJSON(res)#</cfoutput>
			<cfflush>
			<cfabort>
		</cfif>
		<!--- The tool paths --->
		<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
		<!--- Create directory --->
		<cfset var basketname = createuuid("")>
		<!--- Read Basket --->
		<cfinvoke method="readbasket" returnvariable="thebasket">
		<cfset var filectr = 0>
		<!--- Loop trough the basket --->
		<cfloop query="thebasket">
			<!--- Set the asset id into a var --->
			<cfset arguments.thestruct.theid = cart_product_id>
			<!--- Get the files according to the extension --->
			<cfswitch expression="#cart_file_type#">
				<!--- Images --->
				<cfcase value="img">
					<cfset res.message  = 'Copying image "#filename#"'>
					<cfoutput>#serializeJSON(res)#</cfoutput>
					<cfflush>
					<!--- Write Image --->
					<cfinvoke method="writeimages" thestruct="#arguments.thestruct#">
				</cfcase>
				<!--- Videos --->
				<cfcase value="vid">
					<!--- Write Video --->
					<cfinvoke method="writevideos" thestruct="#arguments.thestruct#">
					<cfset res.message  = 'Copying video "#filename#"'>
					<cfoutput>#serializeJSON(res)#</cfoutput>
					<cfflush>
				</cfcase>
				<!--- Audios --->
				<cfcase value="aud">
					<cfset res.message  = 'Copying audio "#filename#"'>
					<cfoutput>#serializeJSON(res)#</cfoutput>
					<cfflush>
					<!--- Write Audio --->
					<cfinvoke method="writeaudios" thestruct="#arguments.thestruct#">
				</cfcase>
				<!--- All other files --->
				<cfdefaultcase>
					<cfset res.message  = 'Copying file "#filename#"'>
					<cfoutput>#serializeJSON(res)#</cfoutput>
					<cfflush>
					<!--- Write file --->
					<cfinvoke method="writefiles" thestruct="#arguments.thestruct#">
				</cfdefaultcase>
			</cfswitch>
			<cfset filectr = filectr + 1>
			<cfset res.progress = int((filectr/thebasket.recordcount)*100)>
		</cfloop>
		<cfset res.message  = '-------------- DONE -------------- '>
		<cfoutput>#serializeJSON(res)#</cfoutput>
		<cfflush>
		<cfcatch>
		<cfset res.message  = '-------------- ERROR --------------<br/>' & cfcatch.message>
		<cfoutput>#serializeJSON(res)#</cfoutput>
		<cfflush>
	</cfcatch>
	</cftry>
</cffunction>


<!--- WRITE FILES IN BASKET TO AWS --->
<cffunction name="writebasket2aws" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam default="" name="arguments.thestruct.artofimage">
	<cfparam default="" name="arguments.thestruct.artofvideo">
	<cfparam default="" name="arguments.thestruct.artoffile">
	<cfparam default="" name="arguments.thestruct.artofaudio">
	<cfparam default="false" name="arguments.thestruct.noemail">
	<cfparam default="" name="arguments.thestruct.newpath" >
	<cfparam default="true" name="arguments.thestruct.skipduplicates">
	<cfparam default="true" name="arguments.thestruct.localupload">
	<cfset arguments.thestruct.theawsurl = structnew()>
	<cftry>
		<!--- The tool paths --->
		<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
		<!--- Create directory --->
		<cfset var basketname = createuuid("")>

		<cfset var aws_id = listlast(arguments.thestruct.bucket_aws,'_')>

		<cfquery name="aws_bucket" datasource="#variables.dsn#">
			SELECT set_pref
			FROM #session.hostdbprefix#settings
			WHERE set_id = <cfqueryparam value="#arguments.thestruct.bucket_aws#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>

		<cfquery name="aws_key" datasource="#variables.dsn#">
			SELECT set_pref
			FROM #session.hostdbprefix#settings
			WHERE set_id = <cfqueryparam value="aws_access_key_id_#aws_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>

		<cfquery name="aws_secret_key" datasource="#variables.dsn#">
			SELECT set_pref
			FROM #session.hostdbprefix#settings
			WHERE set_id = <cfqueryparam value="aws_secret_access_key_#aws_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>

		<!--- Register AWS datasource and set vars --->
		<cfset arguments.thestruct.awsdatasource = AmazonRegisterDataSource('basketaws','#aws_key.set_pref#','#aws_secret_key.set_pref#')>
		<cfset arguments.thestruct.awsbucket = aws_bucket.set_pref>
		<cfset arguments.thestruct.awskey= aws_key.set_pref>
		<cfset arguments.thestruct.awssecretkey= aws_secret_key.set_pref>
		<!--- Get list of files in AWS bucket --->
		<cfset arguments.thestruct.s3list = AmazonS3list(
			datasource='#arguments.thestruct.awsdatasource#',
			bucket='#arguments.thestruct.awsbucket#',
			prefix = ''
		)>
		<!--- Read Basket --->
		<cfinvoke method="readbasket" returnvariable="thebasket">
		<cfset var filectr = 0>
		<!--- Loop trough the basket --->
		<cfloop query="thebasket">
			<!--- Set the asset id into a var --->
			<cfset arguments.thestruct.theid = cart_product_id>
			<!--- Get the files according to the extension --->
			<cfswitch expression="#cart_file_type#">
				<!--- Images --->
				<cfcase value="img">
					<cfset res.message  = 'Copying image "#filename#"'>
					<cfoutput>#serializeJSON(res)#</cfoutput>
					<cfflush>
					<!--- Write Image --->
					<cfinvoke method="writeimages" thestruct="#arguments.thestruct#">
					
				</cfcase>
				<!--- Videos --->
				<cfcase value="vid">
					<!--- Write Video --->
					<cfinvoke method="writevideos" thestruct="#arguments.thestruct#">
					<cfset res.message  = 'Copying video "#filename#"'>
					<cfoutput>#serializeJSON(res)#</cfoutput>
					<cfflush>
				</cfcase>
				<!--- Audios --->
				<cfcase value="aud">
					<cfset res.message  = 'Copying audio "#filename#"'>
					<cfoutput>#serializeJSON(res)#</cfoutput>
					<cfflush>
					<!--- Write Audio --->
					<cfinvoke method="writeaudios" thestruct="#arguments.thestruct#">
				</cfcase>
				<!--- All other files --->
				<cfdefaultcase>
					<cfset res.message  = 'Copying file "#filename#"'>
					<cfoutput>#serializeJSON(res)#</cfoutput>
					<cfflush>
					<!--- Write file --->
					<cfinvoke method="writefiles" thestruct="#arguments.thestruct#">
				</cfdefaultcase>
			</cfswitch>
			<cfset filectr = filectr + 1>
			<cfset res.progress = int((filectr/thebasket.recordcount)*100)>
		</cfloop>
		<cfset res.message  = '-------------- DONE -------------- '>
		<cfoutput>#serializeJSON(res)#</cfoutput>
		<cfflush>

		<cfif !structIsEmpty(arguments.thestruct.theawsurl)>
			<cfoutput>
				<cfsavecontent variable="res.message">
					<strong>AWS URL's</strong><br/>Please be sure to copy these as once generated for a file these will not be re-generated.<br/><br/>
					<font size="1">
					<cfloop collection="#arguments.thestruct.theawsurl#" item="theurl">
						#theurl# : <a href="#structfind(arguments.thestruct.theawsurl,theurl)#" target="_blank">#structfind(arguments.thestruct.theawsurl,theurl)#</a><br/>
					</cfloop>
					</font>
				</cfsavecontent>
				#serializeJSON(res)#
			</cfoutput>
			<cfflush>
		</cfif>

		<cfcatch>
			<cfset res.message  = '<font color="##cd5c5c">-------------- ERROR --------------<br/>' & cfcatch.message & '<br/>'  & cfcatch.detail & '</font>'>
			<cfoutput>#serializeJSON(res)#</cfoutput>
			<cfflush>
			<cfif !structIsEmpty(arguments.thestruct.theawsurl)>
				<cfoutput>
					<cfsavecontent variable="res.message">
						<strong>AWS URL's</strong><br/>Please be sure to copy these as once generated for a file these will not be re-generated.<br/><br/>
						<font size="1">
						<cfloop collection="#arguments.thestruct.theawsurl#" item="theurl">
							#theurl# : <a href="#structfind(arguments.thestruct.theawsurl,theurl)#" target="_blank">#structfind(arguments.thestruct.theawsurl,theurl)#</a><br/>
						</cfloop>
						</font>
					</cfsavecontent>
					#serializeJSON(res)#
				</cfoutput>
				<cfflush>
			</cfif>
		</cfcatch>
	</cftry>
</cffunction>

</cfcomponent>