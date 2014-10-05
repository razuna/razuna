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

	<!--- Templates: Get all --->
	<cffunction name="getTemplates" output="true">
		<cfargument name="theactive" type="boolean" required="false" default="false">
		<cfset var qry = "">
		<!--- Query --->
		<cfquery dataSource="#application.razuna.datasource#" name="qry">
		SELECT imp_temp_id, imp_active, imp_name, imp_description
		FROM #session.hostdbprefix#import_templates
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif arguments.theactive>
			AND imp_active = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
		</cfif>
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Get DETAILED Upload Templates ---------------------------------------------------------------------->
	<cffunction name="gettemplatedetail" output="false">
		<cfargument name="imp_temp_id" type="string" required="true">
		<!--- New struct --->
		<cfset var qry = structnew()>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.imp">
		SELECT imp_who, imp_active, imp_name, imp_description
		FROM #session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Query values --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.impval">
		SELECT imp_field, imp_map, imp_key
		FROM #session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		ORDER BY imp_key DESC, imp_field
		</cfquery>
		<!--- Query key record --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.impkey">
		SELECT imp_field, imp_map, imp_key
		FROM #session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND imp_key = <cfqueryparam cfsqltype="CF_SQL_DOUBLE" value="true">
		</cfquery>
		<cfreturn qry />
	</cffunction>
	
	<!--- Get template value ---------------------------------------------------------------------->
	<cffunction name="gettemplatevalue" output="false">
		<cfargument name="imp_temp_id" type="string" required="true">
		<cfargument name="map" type="string" required="true">
		<!--- Query values --->
		<cfquery datasource="#application.razuna.datasource#" name="q">
		SELECT imp_field
		FROM #session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND imp_map = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.map#">
		</cfquery>
		<cfreturn q.imp_field />
	</cffunction>
	
	
	<!--- Save Upload Templates ---------------------------------------------------------------------->
	<cffunction name="settemplate" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfparam name="arguments.thestruct.imp_active" default="0">
		<!--- Delete all records with this ID in the MAIN DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">
		</cfquery>
		<!--- Save to main DB --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#import_templates
		(imp_temp_id, imp_date_create, imp_date_update, imp_who, imp_active, host_id, imp_name, imp_description)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_active#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_name#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_description#">
		)
		</cfquery>
		<!--- Delete all records with this ID in the DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">
		</cfquery>
		<!--- Get the name and select fields --->
		<cfset var thefield = "">
		<cfset var theselect = "">
		<cfloop collection="#arguments.thestruct#" item="i">
			<cfif i CONTAINS "field_">
				<!--- Get values --->
				<cfset f = listfirst(i,"_")>
				<cfset fn = listlast(i,"_")>
				<cfset fg = f & "_" & fn>
				<cfset thefield = thefield & "," & fg>
			</cfif>
			<cfif i CONTAINS "select_">
				<!--- Get values --->
				<cfset s = listfirst(i,"_")>
				<cfset sn = listlast(i,"_")>
				<cfset sg = s & "_" & sn>
				<cfset theselect = theselect & "," & sg>
			</cfif>
		</cfloop>
		<!--- loop over list amount and do insert and listgetat --->
		<cfloop from="1" to="#listlen(thefield)#" index="i">
			<cfset fi = listgetat(thefield, listfindnocase(thefield,"field_#i#"))>
			<cfset se = listgetat(theselect, listfindnocase(theselect,"select_#i#"))>
			<cfset fi_value = arguments.thestruct["#fi#"]>
			<cfset se_value = arguments.thestruct["#se#"]>
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#import_templates_val
			(imp_temp_id_r, host_id, rec_uuid, imp_field, imp_map<cfif arguments.thestruct.radio_key EQ i>, imp_key</cfif>)
			VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#createuuid()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#fi_value#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#se_value#">
			<cfif arguments.thestruct.radio_key EQ i>, 				
				<cfqueryparam cfsqltype="CF_SQL_DOUBLE" value="true">
			</cfif>
			)
			</cfquery>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Remove Templates ---------------------------------------------------------------------->
	<cffunction name="removetemplate" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfreturn  />
	</cffunction>
	
	<!--- Upload ---------------------------------------------------------------------->
	<cffunction name="upload" output="false" returntype="String">
		<cfargument name="thestruct" type="struct">
		<!--- Upload file to the temp folder --->
		<cffile action="upload" destination="#GetTempdirectory()#" nameconflict="overwrite" filefield="#arguments.thestruct.thefieldname#" result="thefile">
		<!--- Grab the extensions and create new name --->
		<cfset var ext = listlast(thefile.serverFile,".")>
		<cfset var thenamenew = arguments.thestruct.tempid & "." & ext>
		<!--- Rename --->
		<cffile action="rename" source="#GetTempdirectory()#/#thefile.serverFile#" destination="#GetTempdirectory()#/#thenamenew#" />
		<!--- Set filename in session --->
		<cfset session.importfilename = thenamenew>
		<!--- Return --->
		<cfreturn ext />
	</cffunction>
	
	<!--- Do the Import ---------------------------------------------------------------------->
	<cffunction name="doimport" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Check if file exists if not show error message --->
		<cfif !FileExists("#GetTempdirectory()#/#session.importfilename#")>
			<!--- Feedback --->
			<cfoutput><h2>The file is not readable. Please upload it again!</h2><br><br></cfoutput>
			<cfflush>
			<cfabort>
		</cfif>
		<!--- Feedback --->
		<cfoutput><strong>Starting the import</strong><br><br></cfoutput>
		<cfflush>
		<!--- CSV and XML --->
		<cfif listlast(session.importfilename,".") EQ "csv">
			<!--- Read the file --->
			<cffile action="read" file="#GetTempdirectory()#/#session.importfilename#" charset="utf-8" variable="thefile" />
			<!--- Read CSV --->
			<cfset arguments.thestruct.theimport = csvread(string=thefile,headerline=true)>
		<!--- XLS and XLSX --->
		<cfelse>
			<!--- Read the file --->
			<cftry>
				<cfset var thexls = SpreadsheetRead("#GetTempdirectory()#/#session.importfilename#")>
				<cfset arguments.thestruct.theimport = SpreadsheetQueryread(spreadsheet=thexls,sheet=0,headerrow=1)>
			<cfcatch>
				<cfoutput>We could not read the excel file properly. Please convert it into a CSV and try again. <br/>You can save an excel file as CSV using the 'File>Save As' feature in excel.</cfoutput>
				<cfflush>
				<cfabort>
			</cfcatch>
			</cftry>
		</cfif>
		<!--- Feedback --->
		<cfoutput>We could read your file. Continuing...<br><br></cfoutput>
		<cfflush>
		<!--- Do the import --->
		<cfinvoke method="doimporttables" thestruct="#arguments.thestruct#" />
		<!--- Feedback --->
		<cfoutput>Cleaning up...<br><br></cfoutput>
		<cfflush>
		<!--- Remove the file --->
		<cffile action="delete" file="#GetTempdirectory()#/#session.importfilename#" />
		<!--- Feedback --->
		<cfoutput><strong style="color:green;">Import successfully done!</strong><br><br></cfoutput>
		<cfflush>
		<!--- Flush Cache --->
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")> 
		<cfset resetcachetoken("general")> 
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!---Import: Loop over tables ---------------------------------------------------------------------->
	<cffunction name="doimporttables" output="false">
		<cfargument name="thestruct" type="struct">		
		<!--- Is a header template there --->
		<cfif arguments.thestruct.impp_template EQ "">
			<!--- Feedback --->
			<cfoutput>No template chosen. We assume the first row has headers!<br><br></cfoutput>
			<cfflush>
		<!--- If a template has been chosen --->
		<cfelse>
			<!--- Feedback --->
			<cfoutput>Applying your chosen template to the records!<br><br></cfoutput>
			<cfflush>
			<!--- get template values --->
			<cfset arguments.thestruct.template = gettemplatedetail(arguments.thestruct.impp_template)>
		</cfif>
		<!--- Do images --->
		<cfinvoke method="doimportimages" thestruct="#arguments.thestruct#" />
		<!--- Do videos --->
		<cfinvoke method="doimportvideos" thestruct="#arguments.thestruct#" />
		<!--- Do audios --->
		<cfinvoke method="doimportaudios" thestruct="#arguments.thestruct#" />
		<!--- Do docs --->
		<cfinvoke method="doimportdocs" thestruct="#arguments.thestruct#" />
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
	<!---Import: Images ---------------------------------------------------------------------->
	<cffunction name="doimportimages" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var c_theid = "img_id" />
		<cfset var c_thisid = "id" />
		<cfset var c_thefilename = "filename" />
		<cfset var c_thekeywords = "keywords" />
		<cfset var c_thedescription = "description" />
		<cfset var c_thelabels = "labels" />
		<cfset var c_theupcnumber = "upc_number" />
		<!--- Params XMP --->
		<cfset var c_theiptcsubjectcode = "iptcsubjectcode" />
		<cfset var c_thecreator = "creator" />
		<cfset var c_thetitle = "title" />
		<cfset var c_theauthorstitle = "authorstitle" />
		<cfset var c_thedescwriter = "descwriter" />
		<cfset var c_theiptcaddress = "iptcaddress" />
		<cfset var c_thecategory = "category" />
		<cfset var c_thecategorysub = "categorysub" />
		<cfset var c_theurgency = "urgency" />
		<cfset var c_theiptccity = "iptccity" />
		<cfset var c_theiptccountry = "iptccountry" />
		<cfset var c_theiptclocation = "iptclocation" />
		<cfset var c_theiptczip = "iptczip" />
		<cfset var c_theiptcemail = "iptcemail" />
		<cfset var c_theiptcwebsite = "iptcwebsite" />
		<cfset var c_theiptcphone = "iptcphone" />
		<cfset var c_theiptcintelgenre = "iptcintelgenre" />
		<cfset var c_theiptcinstructions = "iptcinstructions" />
		<cfset var c_theiptcsource = "iptcsource" />
		<cfset var c_theiptcusageterms = "iptcusageterms" />
		<cfset var c_thecopystatus = "copystatus" />
		<cfset var c_theiptcjobidentifier = "iptcjobidentifier" />
		<cfset var c_thecopyurl = "copyurl" />
		<cfset var c_theiptcheadline = "iptcheadline" />
		<cfset var c_theiptcdatecreated = "iptcdatecreated" />
		<cfset var c_theiptcimagecity = "iptcimagecity" />
		<cfset var c_theiptcimagestate = "iptcimagestate" />
		<cfset var c_theiptcimagecountry = "iptcimagecountry" />
		<cfset var c_theiptcimagecountrycode = "iptcimagecountrycode" />
		<cfset var c_theiptcscene = "iptcscene" />
		<cfset var c_theiptcstate = "iptcstate" />
		<cfset var c_theiptccredit = "iptccredit" />
		<cfset var c_thecopynotice = "copynotice" />
		<!--- Feedback --->
		<cfoutput><strong>Import to images...</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var c_theid = "img_id">
			<cfelse>
				<cfset var c_theid = "img_filename">
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<cftry>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thisid = arguments.thestruct.template.impkey.imp_field>
				</cfif>

				<cfif NOT isdefined("#c_thisid#") >
					<cfoutput><strong><font color="##CD5C5C">The 'ID' key column is missing in the file. Please ensure the 'ID' key column is present in the file or if using a import template make sure to define a mapping to a key column.</font></strong></cfoutput>
					<cfflush>
					<cfabort>
				</cfif> 

				<!--- Query for existence of the record --->
				<cftry>
					<cfquery dataSource="#application.razuna.datasource#" name="found">
					SELECT img_id, path_to_asset, img_filename AS filenameorg, lucene_key, link_path_url
					FROM #session.hostdbprefix#images
					WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					<cfif arguments.thestruct.expwhat NEQ "all">
						AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
					</cfif>
					</cfquery>
					<cfcatch type="database">
						<h2>Oops... #cfcatch.message#</h2>
						<cfset cfcatch.custom_message = "Database error in function import.doimportimages">
						<cfset errobj.logerrors(cfcatch,false)/>
						<cfabort>
					</cfcatch>
				</cftry>
				<!--- If record is found continue --->
				<cfif found.recordcount NEQ 0>
					<!--- Feedback --->
					<cfoutput>Importing ID: #evaluate(c_thisid)#<br><br></cfoutput>
					<cfflush>
					<!--- Labels --->
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thelabels = gettemplatevalue(arguments.thestruct.impp_template,"labels")>
					</cfif>
					<cfif c_thelabels NEQ "">
						<cfset tlabel = evaluate(c_thelabels)>
					<cfelse>
						<cfset tlabel = "">
					</cfif>
					<!--- Import Labels --->
					<cfinvoke method="doimportlabels" labels="#tlabel#" assetid="#found.img_id#" kind="img" thestruct="#arguments.thestruct#" />
					<!--- Import Custom Fields --->
					<cfinvoke method="doimportcustomfields" thestruct="#arguments.thestruct#" assetid="#found.img_id#" thecurrentRow="#currentRow#" />
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thefilename = gettemplatevalue(arguments.thestruct.impp_template,"filename")>
					</cfif>
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_theupcnumber = gettemplatevalue(arguments.thestruct.impp_template,"upc_number")>
					</cfif>
					<!--- Images: main table --->
					<cfif isdefined("#c_thefilename#") AND evaluate(c_thefilename) NEQ "">
						<cfquery dataSource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#images
						SET img_filename = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thefilename)#">
						WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
						AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
						<cfif arguments.thestruct.expwhat NEQ "all">
							AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
						</cfif>
						</cfquery>
					</cfif>
					<!--- UPC --->
					<cfif isdefined("#c_theupcnumber#") AND evaluate(c_theupcnumber) NEQ "">
						<cfquery dataSource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#images
						SET img_upc_number= <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_theupcnumber)#">
						WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
						AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
						<cfif arguments.thestruct.expwhat NEQ "all">
							AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
						</cfif>
						</cfquery>
					</cfif>
					<!--- Keywords & Descriptions --->
					<!--- Check if record is here --->
					<cfquery dataSource="#application.razuna.datasource#" name="khere">
					SELECT it.img_id_r, i.img_id, it.img_keywords, it.img_description
					FROM #session.hostdbprefix#images i JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r
					WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					AND i.img_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.img_id#">
					</cfquery>
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thekeywords = gettemplatevalue(arguments.thestruct.impp_template,"keywords")>
						<cfset c_thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
					</cfif>
					<!--- record not found, so do an insert --->
					<cfif khere.img_id_r EQ "">
						<cfquery dataSource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#images_text
						(id_inc,img_id_r,lang_id_r,img_keywords,img_description,host_id)
						VALUES(
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.img_id#">,
							<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">,
							<cfif c_thekeywords NEQ "">
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thekeywords)#">,
							<cfelse>
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thedescription)#">,
							<cfelse>
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
							</cfif>
							<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
						)
						</cfquery>
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add">
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = khere.img_keywords & " " & evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = khere.img_keywords>
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = khere.img_description & " " & evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = khere.img_description>
							</cfif>
						<cfelse>
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = khere.img_keywords>
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = khere.img_description>
							</cfif>
						</cfif>
						<cfquery dataSource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#images_text
						SET 
						img_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ltrim(tkeywords)#">,
						img_description = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ltrim(tdescription)#">
						WHERE img_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.img_id#">
						AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
						</cfquery>
					</cfif>
					<!--- Images: XMP --->
					<!--- Check if record is here --->
					<cfquery dataSource="#application.razuna.datasource#" name="xmphere">
					SELECT it.id_r, i.img_id, it.subjectcode, it.creator, it.title, it.authorsposition, it.captionwriter, it.ciadrextadr, it.category,
					it.supplementalcategories, it.urgency, it.description, it.ciadrcity, it.ciadrctry, it.location, it.ciadrpcode, it.ciemailwork,
					it.ciurlwork, it.citelwork, it.intellectualgenre, it.instructions, it.source, it.usageterms, it.copyrightstatus, it.transmissionreference,
					it.webstatement, it.headline, it.datecreated, it.city, it.ciadrregion, it.country, it.countrycode, it.scene, it.state, it.credit, it.rights
					FROM #session.hostdbprefix#images i JOIN #session.hostdbprefix#xmp it ON i.img_id = it.id_r
					WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					AND i.img_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.img_id#">
					</cfquery>
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_theiptcsubjectcode = gettemplatevalue(arguments.thestruct.impp_template,"iptcsubjectcode")>
						<cfset c_thecreator = gettemplatevalue(arguments.thestruct.impp_template,"creator")>
						<cfset c_thetitle = gettemplatevalue(arguments.thestruct.impp_template,"title")>
						<cfset c_theauthorstitle = gettemplatevalue(arguments.thestruct.impp_template,"authorstitle")>
						<cfset c_thedescwriter = gettemplatevalue(arguments.thestruct.impp_template,"descwriter")>
						<cfset c_theiptcaddress = gettemplatevalue(arguments.thestruct.impp_template,"iptcaddress")>
						<cfset c_thecategory = gettemplatevalue(arguments.thestruct.impp_template,"category")>
						<cfset c_thecategorysub = gettemplatevalue(arguments.thestruct.impp_template,"categorysub")>
						<cfset c_theurgency = gettemplatevalue(arguments.thestruct.impp_template,"urgency")>
						<cfset c_thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
						<cfset c_theiptccity = gettemplatevalue(arguments.thestruct.impp_template,"iptccity")>
						<cfset c_theiptccountry = gettemplatevalue(arguments.thestruct.impp_template,"iptccountry")>
						<cfset c_theiptclocation = gettemplatevalue(arguments.thestruct.impp_template,"iptclocation")>
						<cfset c_theiptczip = gettemplatevalue(arguments.thestruct.impp_template,"iptczip")>
						<cfset c_theiptcemail = gettemplatevalue(arguments.thestruct.impp_template,"iptcemail")>
						<cfset c_theiptcwebsite = gettemplatevalue(arguments.thestruct.impp_template,"iptcwebsite")>
						<cfset c_theiptcphone = gettemplatevalue(arguments.thestruct.impp_template,"iptcphone")>
						<cfset c_theiptcintelgenre = gettemplatevalue(arguments.thestruct.impp_template,"iptcintelgenre")>
						<cfset c_theiptcinstructions = gettemplatevalue(arguments.thestruct.impp_template,"iptcinstructions")>
						<cfset c_theiptcsource = gettemplatevalue(arguments.thestruct.impp_template,"iptcsource")>
						<cfset c_theiptcusageterms = gettemplatevalue(arguments.thestruct.impp_template,"iptcusageterms")>
						<cfset c_thecopystatus = gettemplatevalue(arguments.thestruct.impp_template,"copystatus")>
						<cfset c_theiptcjobidentifier = gettemplatevalue(arguments.thestruct.impp_template,"iptcjobidentifier")>
						<cfset c_thecopyurl = gettemplatevalue(arguments.thestruct.impp_template,"copyurl")>
						<cfset c_theiptcheadline = gettemplatevalue(arguments.thestruct.impp_template,"iptcheadline")>
						<cfset c_theiptcdatecreated = gettemplatevalue(arguments.thestruct.impp_template,"iptcdatecreated")>
						<cfset c_theiptcimagecity = gettemplatevalue(arguments.thestruct.impp_template,"iptcimagecity")>
						<cfset c_theiptcimagestate = gettemplatevalue(arguments.thestruct.impp_template,"iptcimagestate")>
						<cfset c_theiptcimagecountry = gettemplatevalue(arguments.thestruct.impp_template,"iptcimagecountry")>
						<cfset c_theiptcimagecountrycode = gettemplatevalue(arguments.thestruct.impp_template,"iptcimagecountrycode")>
						<cfset c_theiptcscene = gettemplatevalue(arguments.thestruct.impp_template,"iptcscene")>
						<cfset c_theiptcstate = gettemplatevalue(arguments.thestruct.impp_template,"iptcstate")>
						<cfset c_theiptccredit = gettemplatevalue(arguments.thestruct.impp_template,"iptccredit")>
						<cfset c_thecopynotice = gettemplatevalue(arguments.thestruct.impp_template,"copynotice")>
					</cfif>
					<!--- record not found, so do an insert --->
					<cfif xmphere.id_r EQ "">
						<cfquery dataSource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#xmp
						(id_r,
						asset_type,
						subjectcode,
						creator,
						title,
						authorsposition,
						captionwriter,
						ciadrextadr,
						category,
						supplementalcategories,
						urgency,
						description,
						ciadrcity,
						ciadrctry,
						location,
						ciadrpcode,
						ciemailwork,
						ciurlwork,
						citelwork,
						intellectualgenre,
						instructions,
						source,
						usageterms,
						copyrightstatus,
						transmissionreference,
						webstatement,
						headline,
						datecreated,
						city,
						ciadrregion,
						country,
						countrycode,
						scene,
						state,
						credit,
						rights,
						host_id)
						VALUES(
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#found.img_id#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="img">,
							<cfif c_theiptcsubjectcode NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcsubjectcode)#">,
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thecreator NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thecreator)#">,
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thetitle NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thetitle)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theauthorstitle NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theauthorstitle)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thedescwriter NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thedescwriter)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcaddress NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcaddress)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thecategory NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thecategory)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thecategorysub NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thecategorysub)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theurgency NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theurgency)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thedescription)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptccity NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptccity)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptccountry NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptccountry)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptclocation NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptclocation)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptczip NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptczip)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcemail NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcemail)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcwebsite NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcwebsite)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcphone NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcphone)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcintelgenre NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcintelgenre)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcinstructions NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcinstructions)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcsource NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcsource)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcusageterms NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcusageterms)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thecopystatus NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thecopystatus)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcjobidentifier NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcjobidentifier)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thecopyurl NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thecopyurl)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcheadline NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcheadline)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcdatecreated NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcdatecreated)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcimagecity NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcimagecity)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcimagestate NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcimagestate)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcimagecountry NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcimagecountry)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcimagecountrycode NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcimagecountrycode)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcscene NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcscene)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptcstate NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptcstate)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_theiptccredit NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_theiptccredit)#">, 
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfif c_thecopynotice NEQ "">
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thecopynotice)#">,
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							</cfif>
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
						</cfquery>
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add">
							<cfif c_theiptcsubjectcode NEQ "">
								<cfset tiptcsubjectcode = xmphere.subjectcode & " " & evaluate(c_theiptcsubjectcode)>
							<cfelse>
								<cfset tiptcsubjectcode = xmphere.subjectcode>
							</cfif>
							<cfif c_thecreator NEQ "">
								<cfset tcreator = xmphere.creator & " " & evaluate(c_thecreator)>
							<cfelse>
								<cfset tcreator = xmphere.creator>
							</cfif>
							<cfif c_thetitle NEQ "">
								<cfset ttitle = xmphere.title & " " & evaluate(c_thetitle)>
							<cfelse>
								<cfset ttitle = xmphere.title>
							</cfif>
							<cfif c_theauthorstitle NEQ "">
								<cfset tauthorstitle = xmphere.authorsposition & " " & evaluate(c_theauthorstitle)>
							<cfelse>
								<cfset tauthorstitle = xmphere.authorsposition>
							</cfif>
							<cfif c_thedescwriter NEQ "">
								<cfset tdescwriter = xmphere.captionwriter & " " & evaluate(c_thedescwriter)>
							<cfelse>
								<cfset tdescwriter = xmphere.captionwriter>
							</cfif>
							<cfif c_theiptcaddress NEQ "">
								<cfset tiptcaddress = xmphere.ciadrextadr & " " & evaluate(c_theiptcaddress)>
							<cfelse>
								<cfset tiptcaddress = xmphere.ciadrextadr>
							</cfif>
							<cfif c_thecategory NEQ "">
								<cfset tcategory = xmphere.category & " " & evaluate(c_thecategory)>
							<cfelse>
								<cfset tcategory = xmphere.category>
							</cfif>
							<cfif c_thecategorysub NEQ "">
								<cfset tcategorysub = xmphere.supplementalcategories & " " & evaluate(c_thecategorysub)>
							<cfelse>
								<cfset tcategorysub = xmphere.supplementalcategories>
							</cfif>
							<cfif c_theurgency NEQ "">
								<cfset turgency = xmphere.urgency & " " & evaluate(c_theurgency)>
							<cfelse>
								<cfset turgency = xmphere.urgency>
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = xmphere.description & " " & evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = xmphere.description>
							</cfif>
							<cfif c_theiptccity NEQ "">
								<cfset tiptccity = xmphere.ciadrcity & " " & evaluate(c_theiptccity)>
							<cfelse>
								<cfset tiptccity = xmphere.ciadrcity>
							</cfif>
							<cfif c_theiptccountry NEQ "">
								<cfset tiptccountry = xmphere.ciadrctry & " " & evaluate(c_theiptccountry)>
							<cfelse>
								<cfset tiptccountry = xmphere.ciadrctry>
							</cfif>
							<cfif c_theiptclocation NEQ "">
								<cfset tiptclocation = xmphere.location & " " & evaluate(c_theiptclocation)>
							<cfelse>
								<cfset tiptclocation = xmphere.location>
							</cfif>
							<cfif c_theiptczip NEQ "">
								<cfset tiptczip = xmphere.ciadrpcode & " " & evaluate(c_theiptczip)>
							<cfelse>
								<cfset tiptczip = xmphere.ciadrpcode>
							</cfif>
							<cfif c_theiptcemail NEQ "">
								<cfset tiptcemail = xmphere.ciemailwork & " " & evaluate(c_theiptcemail)>
							<cfelse>
								<cfset tiptcemail = xmphere.ciemailwork>
							</cfif>
							<cfif c_theiptcwebsite NEQ "">
								<cfset tiptcwebsite = xmphere.ciurlwork & " " & evaluate(c_theiptcwebsite)>
							<cfelse>
								<cfset tiptcwebsite = xmphere.ciurlwork>
							</cfif>
							<cfif c_theiptcphone NEQ "">
								<cfset tiptcphone = xmphere.citelwork & " " & evaluate(c_theiptcphone)>
							<cfelse>
								<cfset tiptcphone = xmphere.citelwork>
							</cfif>
							<cfif c_theiptcintelgenre NEQ "">
								<cfset tiptcintelgenre = xmphere.intellectualgenre & " " & evaluate(c_theiptcintelgenre)>
							<cfelse>
								<cfset tiptcintelgenre = xmphere.intellectualgenre>
							</cfif>
							<cfif c_theiptcinstructions NEQ "">
								<cfset tiptcinstructions = xmphere.instructions & " " & evaluate(c_theiptcinstructions)>
							<cfelse>
								<cfset tiptcinstructions = xmphere.instructions>
							</cfif>
							<cfif c_theiptcsource NEQ "">
								<cfset tiptcsource = xmphere.source & " " & evaluate(c_theiptcsource)>
							<cfelse>
								<cfset tiptcsource = xmphere.source>
							</cfif>
							<cfif c_theiptcusageterms NEQ "">
								<cfset tiptcusageterms = xmphere.usageterms & " " & evaluate(c_theiptcusageterms)>
							<cfelse>
								<cfset tiptcusageterms = xmphere.usageterms>
							</cfif>
							<cfif c_thecopystatus NEQ "">
								<cfset tcopystatus = xmphere.copyrightstatus & " " & evaluate(c_thecopystatus)>
							<cfelse>
								<cfset tcopystatus = xmphere.copyrightstatus>
							</cfif>
							<cfif c_theiptcjobidentifier NEQ "">
								<cfset tiptcjobidentifier = xmphere.transmissionreference & " " & evaluate(c_theiptcjobidentifier)>
							<cfelse>
								<cfset tiptcjobidentifier = xmphere.transmissionreference>
							</cfif>
							<cfif c_thecopyurl NEQ "">
								<cfset tcopyurl = xmphere.webstatement & " " & evaluate(c_thecopyurl)>
							<cfelse>
								<cfset tcopyurl = xmphere.webstatement>
							</cfif>
							<cfif c_theiptcheadline NEQ "">
								<cfset tiptcheadline = xmphere.headline & " " & evaluate(c_theiptcheadline)>
							<cfelse>
								<cfset tiptcheadline = xmphere.headline>
							</cfif>
							<cfif c_theiptcdatecreated NEQ "">
								<cfset tiptcdatecreated = xmphere.datecreated & " " & evaluate(c_theiptcdatecreated)>
							<cfelse>
								<cfset tiptcdatecreated = xmphere.datecreated>
							</cfif>
							<cfif c_theiptcimagecity NEQ "">
								<cfset tiptcimagecity = xmphere.city & " " & evaluate(c_theiptcimagecity)>
							<cfelse>
								<cfset tiptcimagecity = xmphere.city>
							</cfif>
							<cfif c_theiptcimagestate NEQ "">
								<cfset tiptcimagestate = xmphere.ciadrregion & " " & evaluate(c_theiptcimagestate)>
							<cfelse>
								<cfset tiptcimagestate = xmphere.ciadrregion>
							</cfif>
							<cfif c_theiptcimagecountry NEQ "">
								<cfset tiptcimagecountry = xmphere.country & " " & evaluate(c_theiptcimagecountry)>
							<cfelse>
								<cfset tiptcimagecountry = xmphere.country>
							</cfif>
							<cfif c_theiptcimagecountrycode NEQ "">
								<cfset tiptcimagecountrycode = xmphere.countrycode & " " & evaluate(c_theiptcimagecountrycode)>
							<cfelse>
								<cfset tiptcimagecountrycode = xmphere.countrycode>
							</cfif>
							<cfif c_theiptcsubjectcode NEQ "">
								<cfset tiptcscene = xmphere.scene & " " & evaluate(c_theiptcscene)>
							<cfelse>
								<cfset tiptcscene = xmphere.scene>
							</cfif>
							<cfif c_theiptcstate NEQ "">
								<cfset tiptcstate = xmphere.state & " " & evaluate(c_theiptcstate)>
							<cfelse>
								<cfset tiptcstate = xmphere.state>
							</cfif>
							<cfif c_theiptccredit NEQ "">
								<cfset tiptccredit = xmphere.credit & " " & evaluate(c_theiptccredit)>
							<cfelse>
								<cfset tiptccredit = xmphere.credit>
							</cfif>
							<cfif c_thecopynotice NEQ "">
								<cfset tcopynotice = xmphere.rights & " " & evaluate(c_thecopynotice)>
							<cfelse>
								<cfset tcopynotice = xmphere.rights>
							</cfif>
						<cfelse>
							<cfif c_theiptcsubjectcode NEQ "">
								<cfset tiptcsubjectcode = evaluate(c_theiptcsubjectcode)>
							<cfelse>
								<cfset tiptcsubjectcode = "">
							</cfif>
							<cfif c_thecreator NEQ "">
								<cfset tcreator = evaluate(c_thecreator)>
							<cfelse>
								<cfset tcreator = "">
							</cfif>
							<cfif c_thetitle NEQ "">
								<cfset ttitle = evaluate(c_thetitle)>
							<cfelse>
								<cfset ttitle = "">
							</cfif>
							<cfif c_theauthorstitle NEQ "">
								<cfset tauthorstitle = evaluate(c_theauthorstitle)>
							<cfelse>
								<cfset tauthorstitle = "">
							</cfif>
							<cfif c_thedescwriter NEQ "">
								<cfset tdescwriter = evaluate(c_thedescwriter)>
							<cfelse>
								<cfset tdescwriter = "">
							</cfif>
							<cfif c_theiptcaddress NEQ "">
								<cfset tiptcaddress = evaluate(c_theiptcaddress)>
							<cfelse>
								<cfset tiptcaddress = "">
							</cfif>
							<cfif c_thecategory NEQ "">
								<cfset tcategory = evaluate(c_thecategory)>
							<cfelse>
								<cfset tcategory = "">
							</cfif>
							<cfif c_thecategorysub NEQ "">
								<cfset tcategorysub = evaluate(c_thecategorysub)>
							<cfelse>
								<cfset tcategorysub = "">
							</cfif>
							<cfif c_theurgency NEQ "">
								<cfset turgency = evaluate(c_theurgency)>
							<cfelse>
								<cfset turgency = "">
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = "">
							</cfif>
							<cfif c_theiptccity NEQ "">
								<cfset tiptccity = evaluate(c_theiptccity)>
							<cfelse>
								<cfset tiptccity = "">
							</cfif>
							<cfif c_theiptccountry NEQ "">
								<cfset tiptccountry = evaluate(c_theiptccountry)>
							<cfelse>
								<cfset tiptccountry = "">
							</cfif>
							<cfif c_theiptclocation NEQ "">
								<cfset tiptclocation = evaluate(c_theiptclocation)>
							<cfelse>
								<cfset tiptclocation = "">
							</cfif>
							<cfif c_theiptczip NEQ "">
								<cfset tiptczip = evaluate(c_theiptczip)>
							<cfelse>
								<cfset tiptczip = "">
							</cfif>
							<cfif c_theiptcemail NEQ "">
								<cfset tiptcemail = evaluate(c_theiptcemail)>
							<cfelse>
								<cfset tiptcemail = "">
							</cfif>
							<cfif c_theiptcwebsite NEQ "">
								<cfset tiptcwebsite = evaluate(c_theiptcwebsite)>
							<cfelse>
								<cfset tiptcwebsite = "">
							</cfif>
							<cfif c_theiptcphone NEQ "">
								<cfset tiptcphone = evaluate(c_theiptcphone)>
							<cfelse>
								<cfset tiptcphone = "">
							</cfif>
							<cfif c_theiptcintelgenre NEQ "">
								<cfset tiptcintelgenre = evaluate(c_theiptcintelgenre)>
							<cfelse>
								<cfset tiptcintelgenre = "">
							</cfif>
							<cfif c_theiptcinstructions NEQ "">
								<cfset tiptcinstructions = evaluate(c_theiptcinstructions)>
							<cfelse>
								<cfset tiptcinstructions = "">
							</cfif>
							<cfif c_theiptcsource NEQ "">
								<cfset tiptcsource = evaluate(c_theiptcsource)>
							<cfelse>
								<cfset tiptcsource = "">
							</cfif>
							<cfif c_theiptcusageterms NEQ "">
								<cfset tiptcusageterms = evaluate(c_theiptcusageterms)>
							<cfelse>
								<cfset tiptcusageterms = "">
							</cfif>
							<cfif c_thecopystatus NEQ "">
								<cfset tcopystatus = evaluate(c_thecopystatus)>
							<cfelse>
								<cfset tcopystatus = "">
							</cfif>
							<cfif c_theiptcjobidentifier NEQ "">
								<cfset tiptcjobidentifier = evaluate(c_theiptcjobidentifier)>
							<cfelse>
								<cfset tiptcjobidentifier = "">
							</cfif>
							<cfif c_thecopyurl NEQ "">
								<cfset tcopyurl = evaluate(c_thecopyurl)>
							<cfelse>
								<cfset tcopyurl = "">
							</cfif>
							<cfif c_theiptcheadline NEQ "">
								<cfset tiptcheadline = evaluate(c_theiptcheadline)>
							<cfelse>
								<cfset tiptcheadline = "">
							</cfif>
							<cfif c_theiptcdatecreated NEQ "">
								<cfset tiptcdatecreated = evaluate(c_theiptcdatecreated)>
							<cfelse>
								<cfset tiptcdatecreated = "">
							</cfif>
							<cfif c_theiptcimagecity NEQ "">
								<cfset tiptcimagecity = evaluate(c_theiptcimagecity)>
							<cfelse>
								<cfset tiptcimagecity = "">
							</cfif>
							<cfif c_theiptcimagestate NEQ "">
								<cfset tiptcimagestate = evaluate(c_theiptcimagestate)>
							<cfelse>
								<cfset tiptcimagestate = "">
							</cfif>
							<cfif c_theiptcimagecountry NEQ "">
								<cfset tiptcimagecountry = evaluate(c_theiptcimagecountry)>
							<cfelse>
								<cfset tiptcimagecountry = "">
							</cfif>
							<cfif c_theiptcimagecountrycode NEQ "">
								<cfset tiptcimagecountrycode = evaluate(c_theiptcimagecountrycode)>
							<cfelse>
								<cfset tiptcimagecountrycode = "">
							</cfif>
							<cfif c_theiptcscene NEQ "">
								<cfset tiptcscene = evaluate(c_theiptcscene)>
							<cfelse>
								<cfset tiptcscene = "">
							</cfif>
							<cfif c_theiptcstate NEQ "">
								<cfset tiptcstate = evaluate(c_theiptcstate)>
							<cfelse>
								<cfset tiptcstate = "">
							</cfif>
							<cfif c_theiptccredit NEQ "">
								<cfset tiptccredit = evaluate(c_theiptccredit)>
							<cfelse>
								<cfset tiptccredit = "">
							</cfif>
							<cfif c_thecopynotice NEQ "">
								<cfset tcopynotice = evaluate(c_thecopynotice)>
							<cfelse>
								<cfset tcopynotice = "">
							</cfif>
						</cfif>
						<cfquery dataSource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#xmp
						SET 
						subjectcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcsubjectcode#">,
						creator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tcreator#">, 
						title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ttitle#">, 
						authorsposition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tauthorstitle#">, 
						captionwriter = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tdescwriter#">, 
						ciadrextadr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcaddress#">, 
						category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tcategory#">, 
						supplementalcategories = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tcategorysub#">, 
						urgency = <cfqueryparam cfsqltype="cf_sql_varchar" value="#turgency#">,
						description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tdescription#">, 
						ciadrcity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptccity#">, 
						ciadrctry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptccountry#">, 
						location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptclocation#">, 
						ciadrpcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptczip#">, 
						ciemailwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcemail#">, 
						ciurlwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcwebsite#">, 
						citelwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcphone#">, 
						intellectualgenre = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcintelgenre#">, 
						instructions = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcinstructions#">, 
						source = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcsource#">, 
						usageterms = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcusageterms#">, 
						copyrightstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tcopystatus#">, 
						transmissionreference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcjobidentifier#">, 
						webstatement = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tcopyurl#">, 
						headline = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcheadline#">, 
						datecreated = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcdatecreated#">, 
						city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcimagecity#">, 
						ciadrregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcimagestate#">, 
						country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcimagecountry#">, 
						countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcimagecountrycode#">, 
						scene = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcscene#">, 
						state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptcstate#">, 
						credit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tiptccredit#">, 
						rights  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tcopynotice#">
						WHERE id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#found.img_id#">
						AND asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="img">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						</cfquery>
					</cfif>
					<!--- Set for indexing --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#images
					SET
					is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
					WHERE img_id = <cfqueryparam value="#found.img_id#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				</cfif>
				<!--- Show if error --->
				<cfcatch type="any">
					<!--- Feedback --->
					<cfoutput>Following error occurred:<br /><cfdump var="#cfcatch#"><span style="font-weight:bold;color:red;">#cfcatch.message#<br />#cfcatch.detail#</span><br><br></cfoutput>
					<cfset cfcatch.custom_message = "Error in function import.doimportimages">
					<cfset errobj.logerrors(cfcatch,false)/>
					<cfflush>
				</cfcatch>
			</cftry>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")> 
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
	<!---Import: Videos ---------------------------------------------------------------------->
	<cffunction name="doimportvideos" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var c_theid = "vid_id" />
		<cfset var c_thisid = "id" />
		<cfset var c_thefilename = "filename" />
		<cfset var c_thekeywords = "keywords" />
		<cfset var c_thedescription = "description" />
		<cfset var c_thelabels = "labels" />
		<!--- Feedback --->
		<cfoutput><strong>Import to videos...</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var c_theid = "vid_id">
			<cfelse>
				<cfset var c_theid = "vid_filename">
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset c_thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cftry>
				<cfquery dataSource="#application.razuna.datasource#" name="found">
				SELECT vid_id, path_to_asset, vid_filename AS filenameorg, lucene_key, link_path_url
				FROM #session.hostdbprefix#videos
				WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				<cfif arguments.thestruct.expwhat NEQ "all">
					AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfif>
				</cfquery>
				<cfcatch type="database">
					<h2>Oops... #cfcatch.message#</h2>
					<cfset cfcatch.custom_message = "Database error in function import.doimportvideos">
					<cfset errobj.logerrors(cfcatch,false)/>
					<cfabort>
				</cfcatch>
			</cftry>
			<!--- If record is found continue --->
			<cfif found.recordcount NEQ 0>
				<!--- Feedback --->
				<cfoutput>Importing ID: #evaluate(c_thisid)#<br><br></cfoutput>
				<cfflush>
				<!--- Labels --->
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thelabels = gettemplatevalue(arguments.thestruct.impp_template,"labels")>
				</cfif>
				<cfif c_thelabels NEQ "">
					<cfset tlabel = evaluate(c_thelabels)>
				<cfelse>
					<cfset tlabel = "">
				</cfif>
				<cfinvoke method="doimportlabels" labels="#tlabel#" assetid="#found.vid_id#" kind="vid" thestruct="#arguments.thestruct#" />
				<!--- Import Custom Fields --->
				<cfinvoke method="doimportcustomfields" thestruct="#arguments.thestruct#" assetid="#found.vid_id#" thecurrentRow="#currentRow#" />
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thefilename = gettemplatevalue(arguments.thestruct.impp_template,"filename")>
				</cfif>
				<!--- Images: main table --->
				<cfif isdefined("#c_thefilename#") AND evaluate(c_thefilename) NEQ "">
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#videos
					SET 
					vid_filename = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thefilename)#">,
					is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
					WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					<cfif arguments.thestruct.expwhat NEQ "all">
						AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
					</cfif>
					</cfquery>
				</cfif>
				<!--- Keywords & Descriptions --->
				<!--- Check if record is here --->
				<cfquery dataSource="#application.razuna.datasource#" name="khere">
				SELECT it.vid_id_r, i.vid_id, it.vid_keywords, it.vid_description
				FROM #session.hostdbprefix#videos i JOIN #session.hostdbprefix#videos_text it ON i.vid_id = it.vid_id_r
				WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				AND i.vid_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.vid_id#">
				</cfquery>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thekeywords = gettemplatevalue(arguments.thestruct.impp_template,"keywords")>
					<cfset c_thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
				</cfif>
				<!--- record not found, so do an insert --->
				<cfif khere.vid_id_r EQ "">
					<cfquery dataSource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#videos_text
					(id_inc,vid_id_r,lang_id_r,vid_keywords,vid_description,host_id)
					VALUES(
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.vid_id#">,
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">,
						<cfif c_thekeywords NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thekeywords)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thedescription)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfif c_thekeywords NEQ "">
							<cfset tkeywords = khere.vid_keywords & " " & evaluate(c_thekeywords)>
						<cfelse>
							<cfset tkeywords = khere.vid_keywords>
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfset tdescription = khere.vid_description & " " & evaluate(c_thedescription)>
						<cfelse>
							<cfset tdescription = khere.vid_description>
						</cfif>
					<cfelse>
						<cfif c_thekeywords NEQ "">
							<cfset tkeywords = evaluate(c_thekeywords)>
						<cfelse>
							<cfset tkeywords = "">
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfset tdescription = evaluate(c_thedescription)>
						<cfelse>
							<cfset tdescription = "">
						</cfif>
					</cfif>
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#videos_text
					SET 
					vid_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tkeywords#">,
					vid_description = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tdescription#">
					WHERE vid_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.vid_id#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")> 
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!---Import: Audios ---------------------------------------------------------------------->
	<cffunction name="doimportaudios" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var c_theid = "aud_id" />
		<cfset var c_thisid = "id" />
		<cfset var c_thefilename = "filename" />
		<cfset var c_thekeywords = "keywords" />
		<cfset var c_thedescription = "description" />
		<cfset var c_thelabels = "labels" />
		<!--- Feedback --->
		<cfoutput><strong>Import to audios...</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var c_theid = "aud_id">
			<cfelse>
				<cfset var c_theid = "aud_name">
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset c_thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cftry>
				<cfquery dataSource="#application.razuna.datasource#" name="found">
				SELECT aud_id, path_to_asset, aud_name AS filenameorg, lucene_key, link_path_url
				FROM #session.hostdbprefix#audios
				WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				<cfif arguments.thestruct.expwhat NEQ "all">
					AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfif>
				</cfquery>
				<cfcatch type="database">
					<h2>Oops... #cfcatch.message#</h2>
					<cfset cfcatch.custom_message = "Database error in function import.doimportaudios">
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					<cfabort>
				</cfcatch>
			</cftry>
			<!--- If record is found continue --->
			<cfif found.recordcount NEQ 0>
				<!--- Feedback --->
				<cfoutput>Importing ID: #evaluate(c_thisid)#<br><br></cfoutput>
				<cfflush>
				<!--- Labels --->
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thelabels = gettemplatevalue(arguments.thestruct.impp_template,"labels")>
				</cfif>
				<cfif c_thelabels NEQ "">
					<cfset tlabel = evaluate(c_thelabels)>
				<cfelse>
					<cfset tlabel = "">
				</cfif>
				<cfinvoke method="doimportlabels" labels="#tlabel#" assetid="#found.aud_id#" kind="aud" thestruct="#arguments.thestruct#" />
				<!--- Import Custom Fields --->
				<cfinvoke method="doimportcustomfields" thestruct="#arguments.thestruct#" assetid="#found.aud_id#" thecurrentRow="#currentRow#" />
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thefilename = gettemplatevalue(arguments.thestruct.impp_template,"filename")>
				</cfif>
				<!--- Images: main table --->
				<cfif isdefined("#c_thefilename#") AND evaluate(c_thefilename) NEQ "">
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#audios
					SET 
					aud_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thefilename)#">,
					is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
					WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					<cfif arguments.thestruct.expwhat NEQ "all">
						AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
					</cfif>
					</cfquery>
				</cfif>
				<!--- Keywords & Descriptions --->
				<!--- Check if record is here --->
				<cfquery dataSource="#application.razuna.datasource#" name="khere">
				SELECT it.aud_id_r, i.aud_id, it.aud_keywords, it.aud_description
				FROM #session.hostdbprefix#audios i JOIN #session.hostdbprefix#audios_text it ON i.aud_id = it.aud_id_r
				WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				AND i.aud_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.aud_id#">
				</cfquery>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thekeywords = gettemplatevalue(arguments.thestruct.impp_template,"keywords")>
					<cfset c_thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
				</cfif>
				<!--- record not found, so do an insert --->
				<cfif khere.aud_id_r EQ "">
					<cfquery dataSource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#audios_text
					(id_inc,aud_id_r,lang_id_r,aud_keywords,aud_description,host_id)
					VALUES(
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.aud_id#">,
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">,
						<cfif c_thekeywords NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thekeywords)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thedescription)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfif c_thekeywords NEQ "">
							<cfset tkeywords = khere.aud_keywords & " " & evaluate(c_thekeywords)>
						<cfelse>
							<cfset tkeywords = khere.aud_keywords>
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfset tdescription = khere.aud_description & " " & evaluate(c_thedescription)>
						<cfelse>
							<cfset tdescription = khere.aud_description>
						</cfif>
					<cfelse>
						<cfif c_thekeywords NEQ "">
							<cfset tkeywords = evaluate(c_thekeywords)>
						<cfelse>
							<cfset tkeywords = "">
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfset tdescription = evaluate(c_thedescription)>
						<cfelse>
							<cfset tdescription = "">
						</cfif>
					</cfif>
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#audios_text
					SET 
					aud_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tkeywords#">,
					aud_description = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tdescription#">
					WHERE aud_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.aud_id#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")> 
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!---Import: Docs ---------------------------------------------------------------------->
	<cffunction name="doimportdocs" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var c_theid = "file_id" />
		<cfset var c_thisid = "id" />
		<cfset var c_thefilename = "filename" />
		<cfset var c_thekeywords = "keywords" />
		<cfset var c_thedescription = "description" />
		<cfset var c_thelabels = "labels" />
		<!--- Params XMP --->
		<cfset var c_thepdf_author = "pdf_author" />
		<cfset var c_thepdf_rights = "pdf_rights" />
		<cfset var c_thepdf_authorsposition = "pdf_authorsposition" />
		<cfset var c_thepdf_captionwriter = "pdf_captionwriter" />
		<cfset var c_thepdf_webstatement = "pdf_webstatement" />
		<cfset var c_thepdf_rightsmarked = "pdf_rightsmarked" />	
		<!--- Feedback --->
		<cfoutput><strong>Import to documents...</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var c_theid = "file_id">
			<cfelse>
				<cfset var c_theid = "file_name">
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset c_thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cftry>
				<cfquery dataSource="#application.razuna.datasource#" name="found">
				SELECT file_id, path_to_asset, file_name AS filenameorg, lucene_key, link_path_url
				FROM #session.hostdbprefix#files
				WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				<cfif arguments.thestruct.expwhat NEQ "all">
					AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfif>
				</cfquery>
				<cfcatch type="database">
					<h2>Oops... #cfcatch.message#</h2>
					<cfset cfcatch.custom_message = "Database error in function import.doimportdocs">
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					<cfabort>
				</cfcatch>
			</cftry>
			<!--- If record is found continue --->
			<cfif found.recordcount NEQ 0>
				<!--- Feedback --->
				<cfoutput>Importing ID: #evaluate(c_thisid)#<br><br></cfoutput>
				<cfflush>
				<!--- Labels --->
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thelabels = gettemplatevalue(arguments.thestruct.impp_template,"labels")>
				</cfif>
				<cfif c_thelabels NEQ "">
					<cfset tlabel = evaluate(c_thelabels)>
				<cfelse>
					<cfset tlabel = "">
				</cfif>
				<!--- Import Labels --->
				<cfinvoke method="doimportlabels" labels="#tlabel#" assetid="#found.file_id#" kind="doc" thestruct="#arguments.thestruct#" />
				<!--- Import Custom Fields --->
				<cfinvoke method="doimportcustomfields" thestruct="#arguments.thestruct#" assetid="#found.file_id#" thecurrentRow="#currentRow#" />
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thefilename = gettemplatevalue(arguments.thestruct.impp_template,"filename")>
				</cfif>
				<!--- Images: main table --->
				<cfif isdefined("#c_thefilename#") AND evaluate(c_thefilename) NEQ "">
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files
					SET 
					file_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thefilename)#">,
					is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
					WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					<cfif arguments.thestruct.expwhat NEQ "all">
						AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
					</cfif>
					</cfquery>
				</cfif>
				<!--- Keywords & Descriptions --->
				<!--- Check if record is here --->
				<cfquery dataSource="#application.razuna.datasource#" name="khere">
				SELECT it.file_id_r, i.file_id, it.file_keywords, it.file_desc
				FROM #session.hostdbprefix#files i JOIN #session.hostdbprefix#files_desc it ON i.file_id = it.file_id_r
				WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				AND i.file_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">
				</cfquery>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thekeywords = gettemplatevalue(arguments.thestruct.impp_template,"keywords")>
					<cfset c_thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
				</cfif>
				<!--- record not found, so do an insert --->
				<cfif khere.file_id_r EQ "">
					<cfquery dataSource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#files_desc
					(id_inc,file_id_r,lang_id_r,file_keywords,file_desc,host_id)
					VALUES(
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">,
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">,
						<cfif c_thekeywords NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thekeywords)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thedescription)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfif c_thekeywords NEQ "">
							<cfset tkeywords = khere.file_keywords & " " & evaluate(c_thekeywords)>
						<cfelse>
							<cfset tkeywords = khere.file_keywords>
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfset tdescription = khere.file_desc & " " & evaluate(c_thedescription)>
						<cfelse>
							<cfset tdescription = khere.file_desc>
						</cfif>
					<cfelse>
						<cfif c_thekeywords NEQ "">
							<cfset tkeywords = evaluate(c_thekeywords)>
						<cfelse>
							<cfset tkeywords = "">
						</cfif>
						<cfif c_thedescription NEQ "">
							<cfset tdescription = evaluate(c_thedescription)>
						<cfelse>
							<cfset tdescription = "">
						</cfif>
					</cfif>
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files_desc
					SET 
					file_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tkeywords#">,
					file_desc = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tdescription#">
					WHERE file_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					</cfquery>
				</cfif>
				<!--- Files: XMP --->
				<!--- Check if record is here --->
				<cfquery dataSource="#application.razuna.datasource#" name="xmphere">
				SELECT it.asset_id_r, i.file_id, it.author, it.rights, it.authorsposition, it.captionwriter, it.webstatement, it.rightsmarked
				FROM #session.hostdbprefix#files i JOIN #session.hostdbprefix#files_xmp it ON i.file_id = it.asset_id_r
				WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				AND i.file_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">
				</cfquery>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thepdf_author = gettemplatevalue(arguments.thestruct.impp_template,"pdf_author")>
					<cfset c_thepdf_rights = gettemplatevalue(arguments.thestruct.impp_template,"pdf_rights")>
					<cfset c_thepdf_authorsposition = gettemplatevalue(arguments.thestruct.impp_template,"pdf_authorsposition")>
					<cfset c_thepdf_captionwriter = gettemplatevalue(arguments.thestruct.impp_template,"pdf_captionwriter")>
					<cfset c_thepdf_webstatement = gettemplatevalue(arguments.thestruct.impp_template,"pdf_webstatement")>
					<cfset c_thepdf_rightsmarked = gettemplatevalue(arguments.thestruct.impp_template,"pdf_rightsmarked")>
				</cfif>
				<!--- record not found, so do an insert --->
				<cfif xmphere.asset_id_r EQ "">
					<cfquery dataSource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#files_xmp
					(author, rights, authorsposition, captionwriter, webstatement, rightsmarked, asset_id_r, host_id)
					VALUES(
						<cfif c_thepdf_author NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_author)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif c_thepdf_rights NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_rights)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif c_thepdf_authorsposition NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_authorsposition)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
				  	  	<cfif c_thepdf_captionwriter NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_captionwriter)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
				  	  	<cfif c_thepdf_webstatement NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_webstatement)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
				  	  	<cfif c_thepdf_rightsmarked NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_rightsmarked)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
				  	  	<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">,
				  	  	<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#"> 	
				  	)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">	
						<cfif c_thepdf_author NEQ "">
							<cfset tpdf_author = xmphere.author & " " & evaluate(c_thepdf_author)>
						<cfelse>
							<cfset tpdf_author = xmphere.author>
						</cfif>
						<cfif c_thepdf_rights NEQ "">
							<cfset tpdf_rights = xmphere.rights & " " & evaluate(c_thepdf_rights)>
						<cfelse>
							<cfset tpdf_rights = xmphere.rights>
						</cfif>
						<cfif c_thepdf_authorsposition NEQ "">
							<cfset tpdf_authorsposition = xmphere.authorsposition & " " & evaluate(c_thepdf_authorsposition)>
						<cfelse>
							<cfset tpdf_authorsposition = xmphere.authorsposition>
						</cfif>
						<cfif c_thepdf_captionwriter NEQ "">
							<cfset tpdf_captionwriter = xmphere.captionwriter & " " & evaluate(c_thepdf_captionwriter)>
						<cfelse>
							<cfset tpdf_captionwriter = xmphere.captionwriter>
						</cfif>
						<cfif c_thepdf_webstatement NEQ "">
							<cfset tpdf_webstatement = xmphere.webstatement & " " & evaluate(c_thepdf_webstatement)>
						<cfelse>
							<cfset tpdf_webstatement = xmphere.webstatement>
						</cfif>
						<cfif c_thepdf_rightsmarked NEQ "">
							<cfset tpdf_rightsmarked = xmphere.rightsmarked & " " & evaluate(c_thepdf_rightsmarked)>
						<cfelse>
							<cfset tpdf_rightsmarked = xmphere.rightsmarked>
						</cfif>
					<cfelse>
						<cfif c_thepdf_author NEQ "">
							<cfset tpdf_author = evaluate(c_thepdf_author)>
						<cfelse>
							<cfset tpdf_author = "">
						</cfif>
						<cfif c_thepdf_rights NEQ "">
							<cfset tpdf_rights = evaluate(c_thepdf_rights)>
						<cfelse>
							<cfset tpdf_rights = "">
						</cfif>
						<cfif c_thepdf_authorsposition NEQ "">
							<cfset tpdf_authorsposition = evaluate(c_thepdf_authorsposition)>
						<cfelse>
							<cfset tpdf_authorsposition = "">
						</cfif>
						<cfif c_thepdf_captionwriter NEQ "">
							<cfset tpdf_captionwriter = evaluate(c_thepdf_captionwriter)>
						<cfelse>
							<cfset tpdf_captionwriter = "">
						</cfif>
						<cfif c_thepdf_webstatement NEQ "">
							<cfset tpdf_webstatement = evaluate(c_thepdf_webstatement)>
						<cfelse>
							<cfset tpdf_webstatement = "">
						</cfif>
						<cfif c_thepdf_rightsmarked NEQ "">
							<cfset tpdf_rightsmarked = evaluate(c_thepdf_rightsmarked)>
						<cfelse>
							<cfset tpdf_rightsmarked = "">
						</cfif>
					</cfif>
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files_xmp
					SET 
					author = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_author#">,
  				  	rights = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_rights#">,
				  	authorsposition = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_authorsposition#">,
				  	captionwriter = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_captionwriter#">,
				  	webstatement = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_webstatement#">,
				  	rightsmarked = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_rightsmarked#">
					WHERE asset_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")> 
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
	<!---Import: Labels ---------------------------------------------------------------------->
	<cffunction name="doimportlabels" output="false">
		<cfargument name="labels" type="string">
		<cfargument name="assetid" type="string">
		<cfargument name="kind" type="string">
		<cfargument name="thestruct" type="struct">
		<!--- Remove all labels for this record --->
		<cfif arguments.thestruct.imp_write NEQ "add">
			<cfquery dataSource="#application.razuna.datasource#">
			DELETE FROM ct_labels
			WHERE ct_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">
			AND ct_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.kind#">
			</cfquery>
		</cfif>
		<!--- Label is usually a list, thus loop it --->
		<cfloop list="#arguments.labels#" delimiters="," index="i">
			<!--- Check if label is in the label db --->
			<cfquery dataSource="#application.razuna.datasource#" name="labhere">
			SELECT label_id
			FROM #session.hostdbprefix#labels
			WHERE lower(label_path) = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#lcase(i)#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- If not we add it or else we simply update the ct db --->
			<cfif labhere.recordcount EQ 0>
				<cfset label_path_list = "">
				<cfset label_root_id=0>
				<!--- Get label's individually to insert in Labels table --->
				<cfloop list="#i#" delimiters="/" index="idx" >
					<!--- Create uuid --->
					<cfset theid = createuuid("")>
					<!--- Set Label path --->
					<cfset label_path_list = listappend(label_path_list,'#idx#','/')>
					<!--- Check if Label path already exists --->
					<cfquery dataSource="#application.razuna.datasource#" name="checklabelpath">
					SELECT label_id, label_text, label_path
					FROM #session.hostdbprefix#labels
					WHERE lower(label_path) = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#lcase(label_path_list)#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- Insert only new labels --->
					<cfif checklabelpath.RecordCount EQ 0>
						<!--- Insert --->
						<cfquery dataSource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#labels
						(label_id, label_text, label_date, user_id, host_id, label_path, label_id_r)
						VALUES(
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#idx#">,
							<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#session.theuserid#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#label_path_list#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#label_root_id#">
						)
						</cfquery>
					</cfif>
					<!--- Insert into CT --->
					<cfif idx EQ listLast(i,"/")>
						<cfquery dataSource="#application.razuna.datasource#">
						INSERT INTO ct_labels
						(ct_label_id, ct_id_r, ct_type, rec_uuid)
						VALUES(
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.kind#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
						)
						</cfquery>
					</cfif>
					<!--- Set Parent id --->
					<cfif checklabelpath.RecordCount NEQ 0>
						<cfset label_root_id = checklabelpath.label_id>
					<cfelse>
						<cfset label_root_id = theid>
					</cfif>
				</cfloop>
			<!--- Label is here --->
			<cfelse>
				<cfquery dataSource="#application.razuna.datasource#">
				INSERT INTO ct_labels
				(ct_label_id, ct_id_r, ct_type, rec_uuid)
				VALUES(
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#labhere.label_id#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.kind#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
				)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("labels")> 
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
	<!---Import: Custom Fields ---------------------------------------------------------------------->
	<cffunction name="doimportcustomfields" output="false">
		<cfargument name="thestruct" type="struct">
		<cfargument name="assetid" type="string">
		<cfargument name="thecurrentRow" type="string">
		<!--- Param --->
		<cfset var doloop = false>
		<cfset var theid = "">
		<cfset var qry = "">
		<!--- Get the columlist --->
		<cfloop list="#arguments.thestruct.theimport.columnList#" delimiters="," index="i">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfloop query="arguments.thestruct.template.impval">
					<cfif imp_field EQ listfirst(i,":") AND !imp_key>
						<!--- <cfset var cfvalue = arguments.thestruct.theimport[i][arguments.thecurrentRow]> --->
						<cfset var theid = imp_map>
						<cfset var doloop = true>
					</cfif>
				</cfloop>
			<cfelseif i contains ":">
				<!--- The ID --->
				<cfset var theid = ucase(listLast(i,":"))>
				<cfset var doloop = true>
			</cfif>
			<!--- Custom fields magic --->
			<cfif doloop>
				<!--- The value --->
				<cfset var cfvalue = ltrim(arguments.thestruct.theimport[i][arguments.thecurrentRow])>
				<!--- Insert or update --->
				<cfquery datasource="#application.razuna.datasource#" name="qry">
				SELECT v.cf_id_r, v.cf_value, f.cf_type
				FROM #session.hostdbprefix#custom_fields_values v, #session.hostdbprefix#custom_fields f
				WHERE v.cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND v.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ucase(arguments.assetid)#">
				AND v.cf_id_r = f.cf_id
				</cfquery>
				<!--- Make sure custom field id exists --->
				<cfquery datasource="#application.razuna.datasource#" name="iscf">
				SELECT 1
				FROM #session.hostdbprefix#custom_fields 
				WHERE cf_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				</cfquery>

				 <!--- RAZ-2965: If custom field is found then do insert/update. This avoids database constraint errors --->
				 <cfif iscf.recordcount neq 0>
					<!--- Insert --->
					<cfif qry.recordcount EQ 0>
						<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#custom_fields_values
						(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
						VALUES(
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#cfvalue#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
						<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
						)
						</cfquery>
					<!--- Update --->
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add" AND qry.cf_type NEQ "select">
							<cfif cfvalue NEQ "">
								<cfset var cfvalue = qry.cf_value & " " & cfvalue>
							<cfelse>
								<cfset var cfvalue = qry.cf_value>
							</cfif>
						</cfif>
						<cfquery datasource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#custom_fields_values
						SET cf_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cfvalue#">
						WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
						AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
			<!--- Param --->
			<cfset var doloop = false>
			<cfset var theid = "">
		</cfloop>
		<!--- Return --->
		<cfreturn  />
	</cffunction>

</cfcomponent>