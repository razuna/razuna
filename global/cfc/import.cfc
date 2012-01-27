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
		ORDER BY imp_field
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
	<cffunction name="upload" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Upload file to the temp folder --->
		<cffile action="upload" destination="#GetTempdirectory()#" nameconflict="overwrite" filefield="#arguments.thestruct.thefieldname#" result="thefile">
		<!--- Grab the extensions and create new name --->
		<cfset var ext = listlast(thefile.serverFile,".")>
		<cfset var thenamenew = arguments.thestruct.tempid & "." & ext>
		<!--- Rename --->
		<cffile action="rename" source="#GetTempdirectory()#/#thefile.serverFile#" destination="#GetTempdirectory()#/#thenamenew#" />
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
	<!--- Do the Import ---------------------------------------------------------------------->
	<cffunction name="doimport" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Feedback --->
		<cfoutput><strong>Starting the import</strong><br><br></cfoutput>
		<cfflush>
		<!--- CSV and XML --->
		<cfif arguments.thestruct.file_format EQ "csv">
			<!--- Read the file --->
			<cffile action="read" file="#GetTempdirectory()#/#arguments.thestruct.tempid#.#arguments.thestruct.file_format#" charset="utf-8" variable="thefile" />
			<!--- Read CSV --->
			<cfset arguments.thestruct.theimport = csvread(string=thefile,headerline=true)>
		<!--- XLS and XLSX --->
		<cfelse>
			<!--- Read the file --->
			<cfset var thexls = SpreadsheetRead("#GetTempdirectory()#/#arguments.thestruct.tempid#.#arguments.thestruct.file_format#")>
			<cfset arguments.thestruct.theimport = SpreadsheetQueryread(spreadsheet=thexls,sheet=0,headerrow=1)>
		</cfif>
		<!--- Feedback --->
		<cfoutput>We could read your file. Continuing...<br><br></cfoutput>
		<cfflush>
		<!--- Do the import --->
		<cfinvoke method="doimporttables" thestruct="#arguments.thestruct#" />
		<!--- Remove the file --->
		
		<!--- Feedback --->
		<cfoutput><strong style="color:green;">Import successfully done!</strong><br><br></cfoutput>
		<cfflush>
		<!--- Return --->
		<cfreturn  />
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
		<!--- Custom Fields --->
		
		<!--- Labels --->
		

		
		<!--- Flush tables --->
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_images" />
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_videos" />
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_audios" />
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_files" />
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_labels" />
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
	<!---Import: Images ---------------------------------------------------------------------->
	<cffunction name="doimportimages" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var theid = "img_id" />
		<cfset var thisid = "id" />
		<cfset var thefilename = "filename" />
		<cfset var thekeywords = "keywords" />
		<cfset var thedescription = "description" />
		<!--- Params XMP --->
		<cfset var theiptcsubjectcode = "iptcsubjectcode" />
		<cfset var thecreator = "creator" />
		<cfset var thetitle = "title" />
		<cfset var theauthorstitle = "authorstitle" />
		<cfset var thedescwriter = "descwriter" />
		<cfset var theiptcaddress = "iptcaddress" />
		<cfset var thecategory = "category" />
		<cfset var thecategorysub = "categorysub" />
		<cfset var theurgency = "urgency" />
		<cfset var thedescription = "description" />
		<cfset var theiptccity = "iptccity" />
		<cfset var theiptccountry = "iptccountry" />
		<cfset var theiptclocation = "iptclocation" />
		<cfset var theiptczip = "iptczip" />
		<cfset var theiptcemail = "iptcemail" />
		<cfset var theiptcwebsite = "iptcwebsite" />
		<cfset var theiptcphone = "iptcphone" />
		<cfset var theiptcintelgenre = "iptcintelgenre" />
		<cfset var theiptcinstructions = "iptcinstructions" />
		<cfset var theiptcsource = "iptcsource" />
		<cfset var theiptcusageterms = "iptcusageterms" />
		<cfset var thecopystatus = "copystatus" />
		<cfset var theiptcjobidentifier = "iptcjobidentifier" />
		<cfset var thecopyurl = "copyurl" />
		<cfset var theiptcheadline = "iptcheadline" />
		<cfset var theiptcdatecreated = "iptcdatecreated" />
		<cfset var theiptcimagecity = "iptcimagecity" />
		<cfset var theiptcimagestate = "iptcimagestate" />
		<cfset var theiptcimagecountry = "iptcimagecountry" />
		<cfset var theiptcimagecountrycode = "iptcimagecountrycode" />
		<cfset var theiptcscene = "iptcscene" />
		<cfset var theiptcstate = "iptcstate" />
		<cfset var theiptccredit = "iptccredit" />
		<cfset var thecopynotice = "copynotice" />
		<!--- Feedback --->
		<cfoutput><strong>Import to images...</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var theid = "img_id">
			<cfelse>
				<cfset var theid = arguments.thestruct.template.impkey.imp_map>
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cfquery dataSource="#application.razuna.datasource#" name="found">
			SELECT img_id, path_to_asset, img_filename AS filenameorg, lucene_key, link_path_url
			FROM #session.hostdbprefix#images
			WHERE #theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thisid)#">
			AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			</cfquery>
			<!--- If record is found continue --->
			<cfif found.img_id EQ evaluate(thisid)>
				<!--- Feedback --->
				<cfoutput>Importing ID: #evaluate(thisid)#<br><br></cfoutput>
				<cfflush>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset thefilename = gettemplatevalue(arguments.thestruct.impp_template,"filename")>
				</cfif>
				<!--- Images: main table --->
				<cfquery dataSource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images
				SET img_filename = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thefilename)#">
				WHERE #theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfquery>
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
					<cfset thekeywords = gettemplatevalue(arguments.thestruct.impp_template,"keywords")>
					<cfset thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
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
						<cfif thekeywords NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thekeywords)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfif thedescription NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thedescription)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfif thekeywords NEQ "">
							<cfset tkeywords = khere.img_keywords & " " & evaluate(thekeywords)>
						<cfelse>
							<cfset tkeywords = khere.img_keywords>
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = khere.img_description & " " & evaluate(thedescription)>
						<cfelse>
							<cfset tdescription = khere.img_description>
						</cfif>
					<cfelse>
						<cfif thekeywords NEQ "">
							<cfset tkeywords = evaluate(thekeywords)>
						<cfelse>
							<cfset tkeywords = "">
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = evaluate(thedescription)>
						<cfelse>
							<cfset tdescription = "">
						</cfif>
					</cfif>
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#images_text
					SET 
					img_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tkeywords#">,
					img_description = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tdescription#">
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
					<cfset theiptcsubjectcode = gettemplatevalue(arguments.thestruct.impp_template,"iptcsubjectcode")>
					<cfset thecreator = gettemplatevalue(arguments.thestruct.impp_template,"creator")>
					<cfset thetitle = gettemplatevalue(arguments.thestruct.impp_template,"title")>
					<cfset theauthorstitle = gettemplatevalue(arguments.thestruct.impp_template,"authorstitle")>
					<cfset thedescwriter = gettemplatevalue(arguments.thestruct.impp_template,"descwriter")>
					<cfset theiptcaddress = gettemplatevalue(arguments.thestruct.impp_template,"iptcaddress")>
					<cfset thecategory = gettemplatevalue(arguments.thestruct.impp_template,"category")>
					<cfset thecategorysub = gettemplatevalue(arguments.thestruct.impp_template,"categorysub")>
					<cfset theurgency = gettemplatevalue(arguments.thestruct.impp_template,"urgency")>
					<cfset thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
					<cfset theiptccity = gettemplatevalue(arguments.thestruct.impp_template,"iptccity")>
					<cfset theiptccountry = gettemplatevalue(arguments.thestruct.impp_template,"iptccountry")>
					<cfset theiptclocation = gettemplatevalue(arguments.thestruct.impp_template,"iptclocation")>
					<cfset theiptczip = gettemplatevalue(arguments.thestruct.impp_template,"iptczip")>
					<cfset theiptcemail = gettemplatevalue(arguments.thestruct.impp_template,"iptcemail")>
					<cfset theiptcwebsite = gettemplatevalue(arguments.thestruct.impp_template,"iptcwebsite")>
					<cfset theiptcphone = gettemplatevalue(arguments.thestruct.impp_template,"iptcphone")>
					<cfset theiptcintelgenre = gettemplatevalue(arguments.thestruct.impp_template,"iptcintelgenre")>
					<cfset theiptcinstructions = gettemplatevalue(arguments.thestruct.impp_template,"iptcinstructions")>
					<cfset theiptcsource = gettemplatevalue(arguments.thestruct.impp_template,"iptcsource")>
					<cfset theiptcusageterms = gettemplatevalue(arguments.thestruct.impp_template,"iptcusageterms")>
					<cfset thecopystatus = gettemplatevalue(arguments.thestruct.impp_template,"copystatus")>
					<cfset theiptcjobidentifier = gettemplatevalue(arguments.thestruct.impp_template,"iptcjobidentifier")>
					<cfset thecopyurl = gettemplatevalue(arguments.thestruct.impp_template,"copyurl")>
					<cfset theiptcheadline = gettemplatevalue(arguments.thestruct.impp_template,"iptcheadline")>
					<cfset theiptcdatecreated = gettemplatevalue(arguments.thestruct.impp_template,"iptcdatecreated")>
					<cfset theiptcimagecity = gettemplatevalue(arguments.thestruct.impp_template,"iptcimagecity")>
					<cfset theiptcimagestate = gettemplatevalue(arguments.thestruct.impp_template,"iptcimagestate")>
					<cfset theiptcimagecountry = gettemplatevalue(arguments.thestruct.impp_template,"iptcimagecountry")>
					<cfset theiptcimagecountrycode = gettemplatevalue(arguments.thestruct.impp_template,"iptcimagecountrycode")>
					<cfset theiptcscene = gettemplatevalue(arguments.thestruct.impp_template,"iptcscene")>
					<cfset theiptcstate = gettemplatevalue(arguments.thestruct.impp_template,"iptcstate")>
					<cfset theiptccredit = gettemplatevalue(arguments.thestruct.impp_template,"iptccredit")>
					<cfset thecopynotice = gettemplatevalue(arguments.thestruct.impp_template,"copynotice")>
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
						<cfif theiptcsubjectcode NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcsubjectcode)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thecreator NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thecreator)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thetitle NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thetitle)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theauthorstitle NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theauthorstitle)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thedescwriter NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thedescwriter)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcaddress NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcaddress)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thecategory NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thecategory)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thecategorysub NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thecategorysub)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theurgency NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theurgency)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thedescription NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thedescription)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptccity NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptccity)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptccountry NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptccountry)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptclocation NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptclocation)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptczip NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptczip)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcemail NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcemail)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcwebsite NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcwebsite)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcphone NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcphone)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcintelgenre NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcintelgenre)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcinstructions NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcinstructions)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcsource NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcsource)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcusageterms NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcusageterms)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thecopystatus NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thecopystatus)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcjobidentifier NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcjobidentifier)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thecopyurl NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thecopyurl)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcheadline NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcheadline)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcdatecreated NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcdatecreated)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcimagecity NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcimagecity)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcimagestate NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcimagestate)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcimagecountry NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcimagecountry)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcimagecountrycode NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcimagecountrycode)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcscene NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcscene)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptcstate NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptcstate)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif theiptccredit NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(theiptccredit)#">, 
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thecopynotice NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thecopynotice)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfif theiptcsubjectcode NEQ "">
							<cfset tiptcsubjectcode = xmphere.subjectcode & " " & evaluate(theiptcsubjectcode)>
						<cfelse>
							<cfset tiptcsubjectcode = xmphere.subjectcode>
						</cfif>
						<cfif thecreator NEQ "">
							<cfset tcreator = xmphere.creator & " " & evaluate(thecreator)>
						<cfelse>
							<cfset tcreator = xmphere.creator>
						</cfif>
						<cfif thetitle NEQ "">
							<cfset ttitle = xmphere.title & " " & evaluate(thetitle)>
						<cfelse>
							<cfset ttitle = xmphere.title>
						</cfif>
						<cfif theauthorstitle NEQ "">
							<cfset tauthorstitle = xmphere.authorsposition & " " & evaluate(theauthorstitle)>
						<cfelse>
							<cfset tauthorstitle = xmphere.authorsposition>
						</cfif>
						<cfif thedescwriter NEQ "">
							<cfset tdescwriter = xmphere.captionwriter & " " & evaluate(thedescwriter)>
						<cfelse>
							<cfset tdescwriter = xmphere.captionwriter>
						</cfif>
						<cfif theiptcaddress NEQ "">
							<cfset tiptcaddress = xmphere.ciadrextadr & " " & evaluate(theiptcaddress)>
						<cfelse>
							<cfset tiptcaddress = xmphere.ciadrextadr>
						</cfif>
						<cfif thecategory NEQ "">
							<cfset tcategory = xmphere.category & " " & evaluate(thecategory)>
						<cfelse>
							<cfset tcategory = xmphere.category>
						</cfif>
						<cfif thecategorysub NEQ "">
							<cfset tcategorysub = xmphere.supplementalcategories & " " & evaluate(thecategorysub)>
						<cfelse>
							<cfset tcategorysub = xmphere.supplementalcategories>
						</cfif>
						<cfif theurgency NEQ "">
							<cfset turgency = xmphere.urgency & " " & evaluate(theurgency)>
						<cfelse>
							<cfset turgency = xmphere.urgency>
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = xmphere.description & " " & evaluate(thedescription)>
						<cfelse>
							<cfset tdescription = xmphere.description>
						</cfif>
						<cfif theiptccity NEQ "">
							<cfset tiptccity = xmphere.ciadrcity & " " & evaluate(theiptccity)>
						<cfelse>
							<cfset tiptccity = xmphere.ciadrcity>
						</cfif>
						<cfif theiptccountry NEQ "">
							<cfset tiptccountry = xmphere.ciadrctry & " " & evaluate(theiptccountry)>
						<cfelse>
							<cfset tiptccountry = xmphere.ciadrctry>
						</cfif>
						<cfif theiptclocation NEQ "">
							<cfset tiptclocation = xmphere.location & " " & evaluate(theiptclocation)>
						<cfelse>
							<cfset tiptclocation = xmphere.location>
						</cfif>
						<cfif theiptczip NEQ "">
							<cfset tiptczip = xmphere.ciadrpcode & " " & evaluate(theiptczip)>
						<cfelse>
							<cfset tiptczip = xmphere.ciadrpcode>
						</cfif>
						<cfif theiptcemail NEQ "">
							<cfset tiptcemail = xmphere.ciemailwork & " " & evaluate(theiptcemail)>
						<cfelse>
							<cfset tiptcemail = xmphere.ciemailwork>
						</cfif>
						<cfif theiptcwebsite NEQ "">
							<cfset tiptcwebsite = xmphere.ciurlwork & " " & evaluate(theiptcwebsite)>
						<cfelse>
							<cfset tiptcwebsite = xmphere.ciurlwork>
						</cfif>
						<cfif theiptcphone NEQ "">
							<cfset tiptcphone = xmphere.citelwork & " " & evaluate(theiptcphone)>
						<cfelse>
							<cfset tiptcphone = xmphere.citelwork>
						</cfif>
						<cfif theiptcintelgenre NEQ "">
							<cfset tiptcintelgenre = xmphere.intellectualgenre & " " & evaluate(theiptcintelgenre)>
						<cfelse>
							<cfset tiptcintelgenre = xmphere.intellectualgenre>
						</cfif>
						<cfif theiptcintelgenre NEQ "">
							<cfset tiptcintelgenre = xmphere.instructions & " " & evaluate(theiptcintelgenre)>
						<cfelse>
							<cfset tiptcintelgenre = xmphere.instructions>
						</cfif>
						<cfif theiptcsource NEQ "">
							<cfset tiptcsource = xmphere.source & " " & evaluate(theiptcsource)>
						<cfelse>
							<cfset tiptcsource = xmphere.source>
						</cfif>
						<cfif theiptcusageterms NEQ "">
							<cfset tiptcusageterms = xmphere.usageterms & " " & evaluate(theiptcusageterms)>
						<cfelse>
							<cfset tiptcusageterms = xmphere.usageterms>
						</cfif>
						<cfif thecopystatus NEQ "">
							<cfset tcopystatus = xmphere.copyrightstatus & " " & evaluate(thecopystatus)>
						<cfelse>
							<cfset tcopystatus = xmphere.copyrightstatus>
						</cfif>
						<cfif theiptcjobidentifier NEQ "">
							<cfset tiptcjobidentifier = xmphere.transmissionreference & " " & evaluate(theiptcjobidentifier)>
						<cfelse>
							<cfset tiptcjobidentifier = xmphere.transmissionreference>
						</cfif>
						<cfif thecopyurl NEQ "">
							<cfset tcopyurl = xmphere.webstatement & " " & evaluate(thecopyurl)>
						<cfelse>
							<cfset tcopyurl = xmphere.webstatement>
						</cfif>
						<cfif theiptcheadline NEQ "">
							<cfset tiptcheadline = xmphere.headline & " " & evaluate(theiptcheadline)>
						<cfelse>
							<cfset tiptcheadline = xmphere.headline>
						</cfif>
						<cfif theiptcdatecreated NEQ "">
							<cfset tiptcdatecreated = xmphere.datecreated & " " & evaluate(theiptcdatecreated)>
						<cfelse>
							<cfset tiptcdatecreated = xmphere.datecreated>
						</cfif>
						<cfif theiptcimagecity NEQ "">
							<cfset tiptcimagecity = xmphere.city & " " & evaluate(theiptcimagecity)>
						<cfelse>
							<cfset tiptcimagecity = xmphere.city>
						</cfif>
						<cfif theiptcimagestate NEQ "">
							<cfset tiptcimagestate = xmphere.ciadrregion & " " & evaluate(theiptcimagestate)>
						<cfelse>
							<cfset tiptcimagestate = xmphere.ciadrregion>
						</cfif>
						<cfif theiptcimagecountry NEQ "">
							<cfset tiptcimagecountry = xmphere.country & " " & evaluate(theiptcimagecountry)>
						<cfelse>
							<cfset tiptcimagecountry = xmphere.country>
						</cfif>
						<cfif theiptcimagecountrycode NEQ "">
							<cfset tiptcimagecountrycode = xmphere.countrycode & " " & evaluate(theiptcimagecountrycode)>
						<cfelse>
							<cfset tiptcimagecountrycode = xmphere.countrycode>
						</cfif>
						<cfif theiptcsubjectcode NEQ "">
							<cfset tiptcscene = xmphere.scene & " " & evaluate(theiptcscene)>
						<cfelse>
							<cfset tiptcscene = xmphere.scene>
						</cfif>
						<cfif theiptcstate NEQ "">
							<cfset tiptcstate = xmphere.state & " " & evaluate(theiptcstate)>
						<cfelse>
							<cfset tiptcstate = xmphere.state>
						</cfif>
						<cfif theiptccredit NEQ "">
							<cfset tiptccredit = xmphere.credit & " " & evaluate(theiptccredit)>
						<cfelse>
							<cfset tiptccredit = xmphere.credit>
						</cfif>
						<cfif thecopynotice NEQ "">
							<cfset tcopynotice = xmphere.rights & " " & evaluate(thecopynotice)>
						<cfelse>
							<cfset tcopynotice = xmphere.rights>
						</cfif>
					<cfelse>
						<cfif theiptcsubjectcode NEQ "">
							<cfset tiptcsubjectcode = evaluate(theiptcsubjectcode)>
						<cfelse>
							<cfset tiptcsubjectcode = "">
						</cfif>
						<cfif thecreator NEQ "">
							<cfset tcreator = evaluate(thecreator)>
						<cfelse>
							<cfset tcreator = "">
						</cfif>
						<cfif thetitle NEQ "">
							<cfset ttitle = evaluate(thetitle)>
						<cfelse>
							<cfset ttitle = "">
						</cfif>
						<cfif theauthorstitle NEQ "">
							<cfset tauthorstitle = evaluate(theauthorstitle)>
						<cfelse>
							<cfset tauthorstitle = "">
						</cfif>
						<cfif thedescwriter NEQ "">
							<cfset tdescwriter = evaluate(thedescwriter)>
						<cfelse>
							<cfset tdescwriter = "">
						</cfif>
						<cfif theiptcaddress NEQ "">
							<cfset tiptcaddress = evaluate(theiptcaddress)>
						<cfelse>
							<cfset tiptcaddress = "">
						</cfif>
						<cfif thecategory NEQ "">
							<cfset tcategory = evaluate(thecategory)>
						<cfelse>
							<cfset tcategory = "">
						</cfif>
						<cfif thecategorysub NEQ "">
							<cfset tcategorysub = evaluate(thecategorysub)>
						<cfelse>
							<cfset tcategorysub = "">
						</cfif>
						<cfif theurgency NEQ "">
							<cfset turgency = evaluate(theurgency)>
						<cfelse>
							<cfset turgency = "">
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = evaluate(thedescription)>
						<cfelse>
							<cfset tdescription = "">
						</cfif>
						<cfif theiptccity NEQ "">
							<cfset tiptccity = evaluate(theiptccity)>
						<cfelse>
							<cfset tiptccity = "">
						</cfif>
						<cfif theiptccountry NEQ "">
							<cfset tiptccountry = evaluate(theiptccountry)>
						<cfelse>
							<cfset tiptccountry = "">
						</cfif>
						<cfif theiptclocation NEQ "">
							<cfset tiptclocation = evaluate(theiptclocation)>
						<cfelse>
							<cfset tiptclocation = "">
						</cfif>
						<cfif theiptczip NEQ "">
							<cfset tiptczip = evaluate(theiptczip)>
						<cfelse>
							<cfset tiptczip = "">
						</cfif>
						<cfif theiptcemail NEQ "">
							<cfset tiptcemail = evaluate(theiptcemail)>
						<cfelse>
							<cfset tiptcemail = "">
						</cfif>
						<cfif theiptcwebsite NEQ "">
							<cfset tiptcwebsite = evaluate(theiptcwebsite)>
						<cfelse>
							<cfset tiptcwebsite = "">
						</cfif>
						<cfif theiptcphone NEQ "">
							<cfset tiptcphone = evaluate(theiptcphone)>
						<cfelse>
							<cfset tiptcphone = "">
						</cfif>
						<cfif theiptcintelgenre NEQ "">
							<cfset tiptcintelgenre = evaluate(theiptcintelgenre)>
						<cfelse>
							<cfset tiptcintelgenre = "">
						</cfif>
						<cfif theiptcinstructions NEQ "">
							<cfset tiptcinstructions = evaluate(theiptcinstructions)>
						<cfelse>
							<cfset tiptcinstructions = "">
						</cfif>
						<cfif theiptcsource NEQ "">
							<cfset tiptcsource = evaluate(theiptcsource)>
						<cfelse>
							<cfset tiptcsource = "">
						</cfif>
						<cfif theiptcusageterms NEQ "">
							<cfset tiptcusageterms = evaluate(theiptcusageterms)>
						<cfelse>
							<cfset tiptcusageterms = "">
						</cfif>
						<cfif thecopystatus NEQ "">
							<cfset tcopystatus = evaluate(thecopystatus)>
						<cfelse>
							<cfset tcopystatus = "">
						</cfif>
						<cfif theiptcjobidentifier NEQ "">
							<cfset tiptcjobidentifier = evaluate(theiptcjobidentifier)>
						<cfelse>
							<cfset tiptcjobidentifier = "">
						</cfif>
						<cfif thecopyurl NEQ "">
							<cfset tcopyurl = evaluate(thecopyurl)>
						<cfelse>
							<cfset tcopyurl = "">
						</cfif>
						<cfif theiptcheadline NEQ "">
							<cfset tiptcheadline = evaluate(theiptcheadline)>
						<cfelse>
							<cfset tiptcheadline = "">
						</cfif>
						<cfif theiptcdatecreated NEQ "">
							<cfset tiptcdatecreated = evaluate(theiptcdatecreated)>
						<cfelse>
							<cfset tiptcdatecreated = "">
						</cfif>
						<cfif theiptcimagecity NEQ "">
							<cfset tiptcimagecity = evaluate(theiptcimagecity)>
						<cfelse>
							<cfset tiptcimagecity = "">
						</cfif>
						<cfif theiptcimagestate NEQ "">
							<cfset tiptcimagestate = evaluate(theiptcimagestate)>
						<cfelse>
							<cfset tiptcimagestate = "">
						</cfif>
						<cfif theiptcimagecountry NEQ "">
							<cfset tiptcimagecountry = evaluate(theiptcimagecountry)>
						<cfelse>
							<cfset tiptcimagecountry = "">
						</cfif>
						<cfif theiptcimagecountrycode NEQ "">
							<cfset tiptcimagecountrycode = evaluate(theiptcimagecountrycode)>
						<cfelse>
							<cfset tiptcimagecountrycode = "">
						</cfif>
						<cfif theiptcscene NEQ "">
							<cfset tiptcscene = evaluate(theiptcscene)>
						<cfelse>
							<cfset tiptcscene = "">
						</cfif>
						<cfif theiptcstate NEQ "">
							<cfset tiptcstate = evaluate(theiptcstate)>
						<cfelse>
							<cfset tiptcstate = "">
						</cfif>
						<cfif theiptccredit NEQ "">
							<cfset tiptccredit = evaluate(theiptccredit)>
						<cfelse>
							<cfset tiptccredit = "">
						</cfif>
						<cfif thecopynotice NEQ "">
							<cfset tcopynotice = evaluate(thecopynotice)>
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
				<!--- For Lucene --->
				<cfset arguments.thestruct.qrydetail.path_to_asset = found.path_to_asset>
				<cfset arguments.thestruct.filenameorg = found.filenameorg>
				<cfset arguments.thestruct.qrydetail.lucene_key = found.lucene_key>
				<cfset arguments.thestruct.qrydetail.link_path_url = found.link_path_url>
				<!--- Lucene: Delete Records --->
				<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#found.img_id#" category="img">
				<!--- Lucene: Update Records --->
				<cfinvoke component="lucene" method="index_update" dsn="#application.razuna.datasource#" thestruct="#arguments.thestruct#" assetid="#found.img_id#" category="img">
			</cfif>
		</cfloop>
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
	<!---Import: Videos ---------------------------------------------------------------------->
	<cffunction name="doimportvideos" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var theid = "vid_id" />
		<cfset var thisid = "id" />
		<cfset var thefilename = "filename" />
		<cfset var thekeywords = "keywords" />
		<cfset var thedescription = "description" />
		<!--- Feedback --->
		<cfoutput><strong>Import to videos...</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var theid = "vid_id">
			<cfelse>
				<cfset var theid = arguments.thestruct.template.impkey.imp_map>
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cfquery dataSource="#application.razuna.datasource#" name="found">
			SELECT vid_id, path_to_asset, vid_filename AS filenameorg, lucene_key, link_path_url
			FROM #session.hostdbprefix#videos
			WHERE #theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thisid)#">
			AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			</cfquery>
			<!--- If record is found continue --->
			<cfif found.vid_id EQ evaluate(thisid)>
				<!--- Feedback --->
				<cfoutput>Importing ID: #evaluate(thisid)#<br><br></cfoutput>
				<cfflush>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset thefilename = gettemplatevalue(arguments.thestruct.impp_template,"filename")>
				</cfif>
				<!--- Images: main table --->
				<cfquery dataSource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#videos
				SET vid_filename = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thefilename)#">
				WHERE #theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfquery>
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
					<cfset thekeywords = gettemplatevalue(arguments.thestruct.impp_template,"keywords")>
					<cfset thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
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
						<cfif thekeywords NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thekeywords)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfif thedescription NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thedescription)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfif thekeywords NEQ "">
							<cfset tkeywords = khere.vid_keywords & " " & evaluate(thekeywords)>
						<cfelse>
							<cfset tkeywords = khere.vid_keywords>
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = khere.vid_description & " " & evaluate(thedescription)>
						<cfelse>
							<cfset tdescription = khere.vid_description>
						</cfif>
					<cfelse>
						<cfif thekeywords NEQ "">
							<cfset tkeywords = evaluate(thekeywords)>
						<cfelse>
							<cfset tkeywords = "">
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = evaluate(thedescription)>
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
				<!--- For Lucene --->
				<cfset arguments.thestruct.qrydetail.path_to_asset = found.path_to_asset>
				<cfset arguments.thestruct.filenameorg = found.filenameorg>
				<cfset arguments.thestruct.qrydetail.lucene_key = found.lucene_key>
				<cfset arguments.thestruct.qrydetail.link_path_url = found.link_path_url>
				<!--- Lucene: Delete Records --->
				<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#found.vid_id#" category="vid">
				<!--- Lucene: Update Records --->
				<cfinvoke component="lucene" method="index_update" dsn="#application.razuna.datasource#" thestruct="#arguments.thestruct#" assetid="#found.vid_id#" category="vid">
			</cfif>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!---Import: Audios ---------------------------------------------------------------------->
	<cffunction name="doimportaudios" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var theid = "aud_id" />
		<cfset var thisid = "id" />
		<cfset var thefilename = "filename" />
		<cfset var thekeywords = "keywords" />
		<cfset var thedescription = "description" />
		<!--- Feedback --->
		<cfoutput><strong>Import to audios...</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var theid = "aud_id">
			<cfelse>
				<cfset var theid = arguments.thestruct.template.impkey.imp_map>
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cfquery dataSource="#application.razuna.datasource#" name="found">
			SELECT aud_id, path_to_asset, aud_name AS filenameorg, lucene_key, link_path_url
			FROM #session.hostdbprefix#audios
			WHERE #theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thisid)#">
			AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			</cfquery>
			<!--- If record is found continue --->
			<cfif found.aud_id EQ evaluate(thisid)>
				<!--- Feedback --->
				<cfoutput>Importing ID: #evaluate(thisid)#<br><br></cfoutput>
				<cfflush>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset thefilename = gettemplatevalue(arguments.thestruct.impp_template,"filename")>
				</cfif>
				<!--- Images: main table --->
				<cfquery dataSource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#audios
				SET aud_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thefilename)#">
				WHERE #theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfquery>
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
					<cfset thekeywords = gettemplatevalue(arguments.thestruct.impp_template,"keywords")>
					<cfset thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
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
						<cfif thekeywords NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thekeywords)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfif thedescription NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thedescription)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfif thekeywords NEQ "">
							<cfset tkeywords = khere.aud_keywords & " " & evaluate(thekeywords)>
						<cfelse>
							<cfset tkeywords = khere.aud_keywords>
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = khere.aud_description & " " & evaluate(thedescription)>
						<cfelse>
							<cfset tdescription = khere.aud_description>
						</cfif>
					<cfelse>
						<cfif thekeywords NEQ "">
							<cfset tkeywords = evaluate(thekeywords)>
						<cfelse>
							<cfset tkeywords = "">
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = evaluate(thedescription)>
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
				<!--- For Lucene --->
				<cfset arguments.thestruct.qrydetail.path_to_asset = found.path_to_asset>
				<cfset arguments.thestruct.filenameorg = found.filenameorg>
				<cfset arguments.thestruct.qrydetail.lucene_key = found.lucene_key>
				<cfset arguments.thestruct.qrydetail.link_path_url = found.link_path_url>
				<!--- Lucene: Delete Records --->
				<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#found.aud_id#" category="aud">
				<!--- Lucene: Update Records --->
				<cfinvoke component="lucene" method="index_update" dsn="#application.razuna.datasource#" thestruct="#arguments.thestruct#" assetid="#found.aud_id#" category="aud">
			</cfif>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!---Import: Docs ---------------------------------------------------------------------->
	<cffunction name="doimportdocs" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var theid = "file_id" />
		<cfset var thisid = "id" />
		<cfset var thefilename = "filename" />
		<cfset var thekeywords = "keywords" />
		<cfset var thedescription = "description" />
		<!--- Params XMP --->
		<cfset var thepdf_author = "pdf_author" />
		<cfset var thepdf_rights = "pdf_rights" />
		<cfset var thepdf_authorsposition = "pdf_authorsposition" />
		<cfset var thepdf_captionwriter = "pdf_captionwriter" />
		<cfset var thepdf_webstatement = "pdf_webstatement" />
		<cfset var thepdf_rightsmarked = "pdf_rightsmarked" />	
		<!--- Feedback --->
		<cfoutput><strong>Import to documents...</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var theid = "file_id">
			<cfelse>
				<cfset var theid = arguments.thestruct.template.impkey.imp_map>
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cfquery dataSource="#application.razuna.datasource#" name="found">
			SELECT file_id, path_to_asset, file_name AS filenameorg, lucene_key, link_path_url
			FROM #session.hostdbprefix#files
			WHERE #theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thisid)#">
			AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			</cfquery>
			<!--- If record is found continue --->
			<cfif found.file_id EQ evaluate(thisid)>
				<!--- Feedback --->
				<cfoutput>Importing ID: #evaluate(thisid)#<br><br></cfoutput>
				<cfflush>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset thefilename = gettemplatevalue(arguments.thestruct.impp_template,"filename")>
				</cfif>
				<!--- Images: main table --->
				<cfquery dataSource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET file_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thefilename)#">
				WHERE #theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfquery>
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
					<cfset thekeywords = gettemplatevalue(arguments.thestruct.impp_template,"keywords")>
					<cfset thedescription = gettemplatevalue(arguments.thestruct.impp_template,"description")>
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
						<cfif thekeywords NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thekeywords)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfif thedescription NEQ "">
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(thedescription)#">,
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
						</cfif>
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
					)
					</cfquery>
				<cfelse>
					<!--- If append --->
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfif thekeywords NEQ "">
							<cfset tkeywords = khere.file_keywords & " " & evaluate(thekeywords)>
						<cfelse>
							<cfset tkeywords = khere.file_keywords>
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = khere.file_desc & " " & evaluate(thedescription)>
						<cfelse>
							<cfset tdescription = khere.file_desc>
						</cfif>
					<cfelse>
						<cfif thekeywords NEQ "">
							<cfset tkeywords = evaluate(thekeywords)>
						<cfelse>
							<cfset tkeywords = "">
						</cfif>
						<cfif thedescription NEQ "">
							<cfset tdescription = evaluate(thedescription)>
						<cfelse>
							<cfset tdescription = "">
						</cfif>
					</cfif>
					<cfquery dataSource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files_desc
					SET 
					file_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tkeywords#">,
					file_desc = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tdescription#">
					WHERE file_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#id#">
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
					<cfset thepdf_author = gettemplatevalue(arguments.thestruct.impp_template,"pdf_author")>
					<cfset thepdf_rights = gettemplatevalue(arguments.thestruct.impp_template,"pdf_rights")>
					<cfset thepdf_authorsposition = gettemplatevalue(arguments.thestruct.impp_template,"pdf_authorsposition")>
					<cfset thepdf_captionwriter = gettemplatevalue(arguments.thestruct.impp_template,"pdf_captionwriter")>
					<cfset thepdf_webstatement = gettemplatevalue(arguments.thestruct.impp_template,"pdf_webstatement")>
					<cfset thepdf_rightsmarked = gettemplatevalue(arguments.thestruct.impp_template,"pdf_rightsmarked")>
				</cfif>
				<!--- record not found, so do an insert --->
				<cfif xmphere.asset_id_r EQ "">
					<cfquery dataSource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#files_xmp
					(author, rights, authorsposition, captionwriter, webstatement, rightsmarked, asset_id_r, host_id)
					VALUES(
						<cfif thepdf_author NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thepdf_author)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thepdf_rights NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thepdf_rights)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
						<cfif thepdf_authorsposition NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thepdf_authorsposition)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
				  	  	<cfif thepdf_captionwriter NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thepdf_captionwriter)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
				  	  	<cfif thepdf_webstatement NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thepdf_webstatement)#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
						</cfif>
				  	  	<cfif thepdf_rightsmarked NEQ "">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(thepdf_rightsmarked)#">,
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
						<cfif thepdf_author NEQ "">
							<cfset tpdf_author = xmphere.author & " " & evaluate(thepdf_author)>
						<cfelse>
							<cfset tpdf_author = xmphere.author>
						</cfif>
						<cfif thepdf_rights NEQ "">
							<cfset tpdf_rights = xmphere.rights & " " & evaluate(thepdf_rights)>
						<cfelse>
							<cfset tpdf_rights = xmphere.rights>
						</cfif>
						<cfif thepdf_authorsposition NEQ "">
							<cfset tpdf_authorsposition = xmphere.authorsposition & " " & evaluate(thepdf_authorsposition)>
						<cfelse>
							<cfset tpdf_authorsposition = xmphere.authorsposition>
						</cfif>
						<cfif thepdf_captionwriter NEQ "">
							<cfset tpdf_captionwriter = xmphere.captionwriter & " " & evaluate(thepdf_captionwriter)>
						<cfelse>
							<cfset tpdf_captionwriter = xmphere.captionwriter>
						</cfif>
						<cfif thepdf_webstatement NEQ "">
							<cfset tpdf_webstatement = xmphere.webstatement & " " & evaluate(thepdf_webstatement)>
						<cfelse>
							<cfset tpdf_webstatement = xmphere.webstatement>
						</cfif>
						<cfif thepdf_rightsmarked NEQ "">
							<cfset tpdf_rightsmarked = xmphere.rightsmarked & " " & evaluate(thepdf_rightsmarked)>
						<cfelse>
							<cfset tpdf_rightsmarked = xmphere.rightsmarked>
						</cfif>
					<cfelse>
						<cfif thepdf_author NEQ "">
							<cfset tpdf_author = evaluate(thepdf_author)>
						<cfelse>
							<cfset tpdf_author = "">
						</cfif>
						<cfif thepdf_rights NEQ "">
							<cfset tpdf_rights = evaluate(thepdf_rights)>
						<cfelse>
							<cfset tpdf_rights = "">
						</cfif>
						<cfif thepdf_authorsposition NEQ "">
							<cfset tpdf_authorsposition = evaluate(thepdf_authorsposition)>
						<cfelse>
							<cfset tpdf_authorsposition = "">
						</cfif>
						<cfif thepdf_captionwriter NEQ "">
							<cfset tpdf_captionwriter = evaluate(thepdf_captionwriter)>
						<cfelse>
							<cfset tpdf_captionwriter = "">
						</cfif>
						<cfif thepdf_webstatement NEQ "">
							<cfset tpdf_webstatement = evaluate(thepdf_webstatement)>
						<cfelse>
							<cfset tpdf_webstatement = "">
						</cfif>
						<cfif thepdf_rightsmarked NEQ "">
							<cfset tpdf_rightsmarked = evaluate(thepdf_rightsmarked)>
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
				<!--- For Lucene --->
				<cfset arguments.thestruct.qrydetail.path_to_asset = found.path_to_asset>
				<cfset arguments.thestruct.filenameorg = found.filenameorg>
				<cfset arguments.thestruct.qrydetail.lucene_key = found.lucene_key>
				<cfset arguments.thestruct.qrydetail.link_path_url = found.link_path_url>
				<!--- Lucene: Delete Records --->
				<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#found.file_id#" category="doc">
				<!--- Lucene: Update Records --->
				<cfinvoke component="lucene" method="index_update" dsn="#application.razuna.datasource#" thestruct="#arguments.thestruct#" assetid="#found.file_id#" category="doc">
			</cfif>
		</cfloop>
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
</cfcomponent>