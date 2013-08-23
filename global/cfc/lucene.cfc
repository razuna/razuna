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
<cfcomponent output="true" extends="extQueryCaching">

	<!--- Check if collection exists for this host --->
	<cffunction name="exists" access="public" output="false">
		<cfthread>
			<cftry>
				<!--- Get the collection --->
				<cfset CollectionStatus(session.hostid)>
				<!--- Collection does NOT exists, thus create it --->
				<cfcatch>
			    	<cfinvoke method="setup" colname="#session.hostid#">
				</cfcatch>
			</cftry>
		</cfthread>
	</cffunction>
	
	<!--- Setup the Collection for the first time --->
	<!--- When adding a new host, creating one on the first time setup --->
	<cffunction name="setup" access="public" output="false">
		<cfargument name="colname" type="string">
			<!--- Delete collection --->
			<cftry>
				<cfset CollectionDelete(arguments.colname)>
				<cfcatch type="any">
					<!--- <cfmail from="server@razuna.com" to="support@razuna.com" subject="collection delete error #arguments.colname#" type="html"><cfdump var="#cfcatch#"></cfmail> --->
				</cfcatch>
			</cftry>
			<!--- Delete path on disk --->
			<cftry>
				<cfdirectory action="delete" directory="#expandpath("../..")#WEB-INF/collections/#arguments.colname#" recurse="true" />
				<cfcatch type="any">
					<!--- <cfmail from="server@razuna.com" to="support@razuna.com" subject="collection error remove directory #arguments.colname#" type="html"><cfdump var="#cfcatch#"></cfmail> --->
				</cfcatch>
			</cftry>
			<!--- Create collection --->
			<cftry>
				<cfset CollectionCreate(collection=arguments.colname,relative=true,path="/WEB-INF/collections/#arguments.colname#")>
				<cfcatch type="any">
					<!--- <cfmail from="server@razuna.com" to="support@razuna.com" subject="collection create error #arguments.colname#" type="html"><cfdump var="#cfcatch#"></cfmail> --->
				</cfcatch>
			</cftry>
	</cffunction>
	
	<!--- INDEX: Update --->
	<cffunction name="index_update" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="false">
		<cfargument name="assetid" type="string" required="false">
		<cfargument name="category" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="online" type="string" default="F" required="false">
		<cfargument name="notfile" type="string" default="F" required="false">
		<cfargument name="fromapi" type="string" default="F" required="false">
		<cfargument name="prefix" type="string" default="#session.hostdbprefix#" required="false">
		<cfargument name="hostid" type="string" default="#session.hostid#" required="false">
		<cfargument name="storage" type="string" default="#application.razuna.storage#" required="false">
		<cfargument name="thedatabase" type="string" default="#application.razuna.thedatabase#" required="false">
		<!--- Call indexing in a thread --->
		<cfthread action="run" intstruct="#arguments#" priority="low">
			<cfinvoke method="index_update_thread">
				<cfinvokeargument name="thestruct" value="#attributes.intstruct#" />
				<cfinvokeargument name="assetid" value="#attributes.intstruct.assetid#" />
				<cfinvokeargument name="category" value="#attributes.intstruct.category#" />
				<cfinvokeargument name="dsn" value="#attributes.intstruct.dsn#" />
				<cfinvokeargument name="online" value="#attributes.intstruct.online#" />
				<cfinvokeargument name="notfile" value="#attributes.intstruct.notfile#" />
				<cfinvokeargument name="fromapi" value="#attributes.intstruct.fromapi#" />
				<cfinvokeargument name="prefix" value="#attributes.intstruct.prefix#" />
				<cfinvokeargument name="hostid" value="#attributes.intstruct.hostid#" />
				<cfinvokeargument name="storage" value="#attributes.intstruct.storage#" />
				<cfinvokeargument name="thedatabase" value="#attributes.intstruct.thedatabase#" />
			</cfinvoke>
		</cfthread>
	</cffunction>

	<!--- INDEX: Update --->
	<cffunction name="index_update_thread" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="false">
		<cfargument name="assetid" type="string" required="false">
		<cfargument name="category" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="online" type="string" default="F" required="false">
		<cfargument name="notfile" type="string" default="F" required="false">
		<cfargument name="fromapi" type="string" default="F" required="false">
		<cfargument name="prefix" type="string" default="#session.hostdbprefix#" required="false">
		<cfargument name="hostid" type="string" default="#session.hostid#" required="false">
		<cfargument name="storage" type="string" default="#application.razuna.storage#" required="false">
		<cfargument name="thedatabase" type="string" default="#application.razuna.thedatabase#" required="false">
		<!--- Param --->
		<cfset var folderpath = "">
		<cfset var theregchars = "[\$\%\_\-\,\.\&\(\)\[\]\*\'\n\r]+">
		<!--- Call to GC to clean memory --->
		<cfset createObject( "java", "java.lang.Runtime" ).getRuntime().gc()>
		<cftry>
			<!--- FOR FILES --->
			<cfif arguments.category EQ "doc">
				<!--- Query Record --->
				<cfquery name="qry_all" datasource="#arguments.dsn#">
			    SELECT DISTINCT f.file_id id, f.folder_id_r folder, f.file_name filename, f.file_name_org filenameorg, f.link_kind, f.lucene_key,
			    ct.file_desc description, ct.file_keywords keywords, 
			    f.file_meta as rawmetadata, '#arguments.category#' as thecategory, f.file_extension theext,
			    x.author, x.rights, x.authorsposition, x.captionwriter, x.webstatement, x.rightsmarked
				FROM #arguments.prefix#files f 
				LEFT JOIN #arguments.prefix#files_desc ct ON f.file_id = ct.file_id_r
				LEFT JOIN #arguments.prefix#files_xmp x ON f.file_id = x.asset_id_r AND x.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				WHERE f.file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				</cfquery>
				<!--- Get folder path --->
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry_all.folder#" dsn="#arguments.dsn#" prefix="#arguments.prefix#" hostid="#arguments.hostid#" returnvariable="qry_bc" />
				<cfloop list="#qry_bc#" delimiters=";" index="p">
					<cfset folderpath = folderpath & "/" & listFirst(p, "|")>
				</cfloop>
				<!--- Get custom fields --->
				<cfquery name="qry_cf" datasource="#arguments.dsn#">
				SELECT DISTINCT <cfif arguments.thedatabase EQ "mssql">cast(ft.cf_id_r AS VARCHAR(100)) + ' ' + cast(v.cf_value AS NVARCHAR(max))<cfelse>CONCAT(cast(ft.cf_id_r AS CHAR),' ',cast(v.cf_value AS CHAR))</cfif> AS customfieldvalue
				FROM #arguments.prefix#custom_fields_values v, #arguments.prefix#custom_fields_text ft
				WHERE v.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND v.cf_value <cfif arguments.thedatabase EQ "oracle" OR arguments.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				AND v.cf_id_r = ft.cf_id_r 
				AND v.host_id = ft.host_id 
				AND ft.lang_id_r = 1
				</cfquery>
				<!--- Add custom fields to a list --->
				<cfset var c = valuelist(qry_cf.customfieldvalue, " ")>
				<!--- Query labels --->
				<cfquery name="qry_l" datasource="#arguments.dsn#">
				SELECT DISTINCT l.label_path
				FROM ct_labels ct, #arguments.prefix#labels l
				WHERE ct.ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND l.label_id = ct.ct_label_id
				AND l.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				</cfquery>
				<!--- Add labels to a list --->
				<cfset var l = valuelist(qry_l.label_path," ")>
				<cfset var l = replace(l,"/"," ","all")>
				<!--- Remove foreign chars for some columns --->
				<cfset var thefilename = REReplaceNoCase(qry_all.filename, theregchars, " ", "ALL")>
				<cfset var thedesc = REReplaceNoCase(qry_all.description, theregchars, " ", "ALL")>
				<cfset var thekeys = REReplaceNoCase(qry_all.keywords, theregchars, " ", "ALL")>
				<!--- Add labels to the query --->
				<cfquery dbtype="query" name="qry_all">
				SELECT 
				id, folder, '#thefilename# #qry_all.filename#' as filename, filenameorg, link_kind, lucene_key, '#thekeys#' as keywords, '#thedesc#' as description,
				rawmetadata, theext, author, rights, authorsposition, captionwriter, webstatement, rightsmarked, '#l#' as labels, 
				'#REReplace(c,"#chr(13)#|#chr(9)#|\n|\r","","ALL")#' as customfieldvalue, thecategory, '#folderpath#' as folderpath
				FROM qry_all
				</cfquery>
				<!--- Indexing --->
					<cfscript>
						args = {
						collection : arguments.hostid,
						query : qry_all,
						category : "thecategory",
						categoryTree : "id",
						key : "id",
						title : "id",
						body : "id,filename,filenameorg,keywords,description,rawmetadata,theext,author,rights,authorsposition,captionwriter,webstatement,rightsmarked,labels,customfieldvalue,folderpath,folder",
						custommap :{
							id : "id",
							filename : "filename",
							filenameorg : "filenameorg",
							keywords : "keywords",
							description : "description",
							rawmetadata : "rawmetadata",
							extension : "theext",
							author : "author",
							rights : "rights",
							authorsposition : "authorsposition", 
							captionwriter : "captionwriter", 
							webstatement : "webstatement", 
							rightsmarked : "rightsmarked",
							labels : "labels",
							customfieldvalue : "customfieldvalue",
							folderpath : "folderpath",
							folder : "folder"
							}
						};
						results = CollectionIndexCustom( argumentCollection=args );
					</cfscript>
			<!--- FOR IMAGES --->
			<cfelseif arguments.category EQ "img">
				<!--- Query Record --->
				<cfquery name="qry_all" datasource="#arguments.dsn#">
			    SELECT DISTINCT f.img_id id, f.folder_id_r folder, f.img_filename filename, f.img_filename_org filenameorg, f.link_kind, f.lucene_key,
			    ct.img_description description, ct.img_keywords keywords, 
				f.img_extension theext, img_meta as rawmetadata, '#arguments.category#' as thecategory,
				x.subjectcode, x.creator, x.title, x.authorsposition, x.captionwriter, x.ciadrextadr, x.category,
				x.supplementalcategories, x.urgency, x.ciadrcity, 
				x.ciadrctry, x.location, x.ciadrpcode, x.ciemailwork, x.ciurlwork, x.citelwork, x.intellectualgenre, x.instructions, x.source,
				x.usageterms, x.copyrightstatus, x.transmissionreference, x.webstatement, x.headline, x.datecreated, x.city, x.ciadrregion, 
				x.country, x.countrycode, x.scene, x.state, x.credit, x.rights
				FROM #arguments.prefix#images f 
				LEFT JOIN #arguments.prefix#images_text ct ON f.img_id = ct.img_id_r
				LEFT JOIN #arguments.prefix#xmp x ON f.img_id = x.id_r AND x.asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="img"> AND x.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				WHERE f.img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				</cfquery>
				<!--- Get folder path --->
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry_all.folder#" dsn="#arguments.dsn#" prefix="#arguments.prefix#" hostid="#arguments.hostid#" returnvariable="qry_bc" />
				<cfloop list="#qry_bc#" delimiters=";" index="p">
					<cfset folderpath = folderpath & "/" & listFirst(p, "|")>
				</cfloop>
				<!--- Get custom fields --->
				<cfquery name="qry_cf" datasource="#arguments.dsn#">
				SELECT DISTINCT <cfif arguments.thedatabase EQ "mssql">cast(ft.cf_id_r AS VARCHAR(100)) + ' ' + cast(v.cf_value AS NVARCHAR(max))<cfelse>CONCAT(cast(ft.cf_id_r AS CHAR),' ',cast(v.cf_value AS CHAR))</cfif> AS customfieldvalue
				FROM #arguments.prefix#custom_fields_values v, #arguments.prefix#custom_fields_text ft
				WHERE v.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND v.cf_value <cfif arguments.thedatabase EQ "oracle" OR arguments.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				AND v.cf_id_r = ft.cf_id_r 
				AND v.host_id = ft.host_id 
				AND ft.lang_id_r = 1
				</cfquery>
				<!--- Add custom fields to a list --->
				<cfset var c = valuelist(qry_cf.customfieldvalue, " ")>
				<!--- Query labels --->
				<cfquery name="qry_l" datasource="#arguments.dsn#">
				SELECT DISTINCT l.label_path
				FROM ct_labels ct, #arguments.prefix#labels l
				WHERE ct.ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND l.label_id = ct.ct_label_id
				AND l.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				</cfquery>
				<!--- Add query to list --->
				<cfset var l = valuelist(qry_l.label_path," ")>
				<cfset var l = replace(l,"/"," ","all")>
				<!--- Remove foreign chars for some columns --->
				<cfset var thefilename = REReplaceNoCase(qry_all.filename, theregchars, " ", "ALL")>
				<cfset var thedesc = REReplaceNoCase(qry_all.description, theregchars, " ", "ALL")>
				<cfset var thekeys = REReplaceNoCase(qry_all.keywords, theregchars, " ", "ALL")>
				<!--- Add labels to the query --->
				<cfquery dbtype="query" name="qry_all">
				SELECT 
				id, folder, '#thefilename# #qry_all.filename#' as filename, filenameorg, link_kind, lucene_key, '#thedesc#' as description, '#thekeys#' as keywords,
				theext, rawmetadata, thecategory, subjectcode, creator, title, authorsposition, captionwriter, ciadrextadr, category, 
				supplementalcategories, urgency, ciadrcity, ciadrctry, location, ciadrpcode, ciemailwork, ciurlwork, citelwork, 
				intellectualgenre, instructions, source, usageterms, copyrightstatus, transmissionreference, webstatement, headline, 
				datecreated, city, ciadrregion, country, countrycode, scene, state, credit, rights, '#l#' as labels, 
				'#REReplace(c,"#chr(13)#|#chr(9)#|\n|\r","","ALL")#' as customfieldvalue, '#folderpath#' as folderpath
				FROM qry_all
				</cfquery>
				<!--- Indexing --->
					<cfscript>
						args = {
						collection : arguments.hostid,
						query : qry_all,
						category : "thecategory",
						categoryTree : "id",
						key : "id",
						title : "id",
						body : "id,filename,filenameorg,keywords,description,rawmetadata,theext,subjectcode,creator,title,authorsposition,captionwriter,ciadrextadr,category,supplementalcategories,urgency,ciadrcity,ciadrctry,location,ciadrpcode,ciemailwork,ciurlwork,citelwork,intellectualgenre,instructions,source,usageterms,copyrightstatus,transmissionreference,webstatement,headline,datecreated,city,ciadrregion,country,countrycode,scene,state,credit,rights,labels,customfieldvalue,folderpath,folder",
						custommap :{
							id : "id",
							filename : "filename",
							filenameorg : "filenameorg",
							keywords : "keywords",
							description : "description",
							rawmetadata : "rawmetadata",
							extension : "theext",
							subjectcode : "subjectcode",
							creator : "creator",
							title : "title", 
							authorsposition : "authorsposition", 
							captionwriter : "captionwriter", 
							ciadrextadr : "ciadrextadr", 
							category : "category",
							supplementalcategories : "supplementalcategories", 
							urgency : "urgency",
							ciadrcity : "ciadrcity", 
							ciadrctry : "ciadrctry", 
							location : "location", 
							ciadrpcode : "ciadrpcode", 
							ciemailwork : "ciemailwork", 
							ciurlwork : "ciurlwork", 
							citelwork : "citelwork", 
							intellectualgenre : "intellectualgenre", 
							instructions : "instructions", 
							source : "source",
							usageterms : "usageterms", 
							copyrightstatus : "copyrightstatus", 
							transmissionreference : "transmissionreference", 
							webstatement : "webstatement", 
							headline : "headline", 
							datecreated : "datecreated", 
							city : "city", 
							ciadrregion : "ciadrregion", 
							country : "country", 
							countrycode : "countrycode", 
							scene : "scene", 
							state : "state", 
							credit : "credit", 
							rights : "rights",
							labels : "labels",
							customfieldvalue : "customfieldvalue",
							folderpath : "folderpath",
							folder : "folder"
							}
						};
						results = CollectionIndexCustom( argumentCollection=args );
					</cfscript>
			<!--- FOR VIDEOS --->
			<cfelseif arguments.category EQ "vid">
				<!--- Query Record --->
				<cfquery name="qry_all" datasource="#arguments.dsn#">
			    SELECT DISTINCT f.vid_id id, f.folder_id_r folder, f.vid_filename filename, f.vid_name_org filenameorg, f.link_kind, f.lucene_key,
			    ct.vid_description description, ct.vid_keywords keywords, 
				vid_meta as rawmetadata, '#arguments.category#' as thecategory,
				f.vid_extension theext
				FROM #arguments.prefix#videos f 
				LEFT JOIN #arguments.prefix#videos_text ct ON f.vid_id = ct.vid_id_r
				WHERE f.vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				</cfquery>
				<!--- Get folder path --->
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry_all.folder#" dsn="#arguments.dsn#" prefix="#arguments.prefix#" hostid="#arguments.hostid#" returnvariable="qry_bc" />
				<cfloop list="#qry_bc#" delimiters=";" index="p">
					<cfset folderpath = folderpath & "/" & listFirst(p, "|")>
				</cfloop>
				<!--- Get custom fields --->
				<cfquery name="qry_cf" datasource="#arguments.dsn#">
				SELECT DISTINCT <cfif arguments.thedatabase EQ "mssql">cast(ft.cf_id_r AS VARCHAR(100)) + ' ' + cast(v.cf_value AS NVARCHAR(max))<cfelse>CONCAT(cast(ft.cf_id_r AS CHAR),' ',cast(v.cf_value AS CHAR))</cfif> AS customfieldvalue
				FROM #arguments.prefix#custom_fields_values v, #arguments.prefix#custom_fields_text ft
				WHERE v.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND v.cf_value <cfif arguments.thedatabase EQ "oracle" OR arguments.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				AND v.cf_id_r = ft.cf_id_r 
				AND v.host_id = ft.host_id 
				AND ft.lang_id_r = 1
				</cfquery>
				<!--- Add custom fields to a list --->
				<cfset var c = valuelist(qry_cf.customfieldvalue, " ")>
				<!--- Query labels --->
				<cfquery name="qry_l" datasource="#arguments.dsn#">
				SELECT DISTINCT l.label_path
				FROM ct_labels ct, #arguments.prefix#labels l
				WHERE ct.ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND l.label_id = ct.ct_label_id
				AND l.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				</cfquery>
				<!--- Add labels to a list --->
				<cfset var l = valuelist(qry_l.label_path," ")>
				<cfset var l = replace(l,"/"," ","all")>
				<!--- Remove foreign chars for some columns --->
				<cfset var thefilename = REReplaceNoCase(qry_all.filename, theregchars, " ", "ALL")>
				<cfset var thedesc = REReplaceNoCase(qry_all.description, theregchars, " ", "ALL")>
				<cfset var thekeys = REReplaceNoCase(qry_all.keywords, theregchars, " ", "ALL")>
				<!--- Add labels to the query --->
				<cfquery dbtype="query" name="qry_all">
				SELECT id, folder, '#thefilename# #qry_all.filename#' as filename, filenameorg, link_kind, lucene_key,
			    '#thedesc#' as description, '#thekeys#' as keywords, rawmetadata, thecategory,
				theext, '#l#' as labels, '#REReplace(c,"#chr(13)#|#chr(9)#|\n|\r","","ALL")#' as customfieldvalue, '#folderpath#' as folderpath
				FROM qry_all
				</cfquery>
			<!--- FOR AUDIOS --->
			<cfelseif arguments.category EQ "aud">
				<!--- Query Record --->
				<cfquery name="qry_all" datasource="#arguments.dsn#">
			    SELECT DISTINCT a.aud_id id, a.folder_id_r folder, a.aud_name filename, a.aud_name_org filenameorg, a.link_kind, a.lucene_key,
			    aut.aud_description description, aut.aud_keywords keywords, 
				a.aud_meta as rawmetadata, '#arguments.category#' as thecategory,
				a.aud_extension theext
				FROM #arguments.prefix#audios a
				LEFT JOIN #arguments.prefix#audios_text aut ON a.aud_id = aut.aud_id_r
				WHERE a.aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				</cfquery>
				<!--- Get folder path --->
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qry_all.folder#" dsn="#arguments.dsn#" prefix="#arguments.prefix#" hostid="#arguments.hostid#" returnvariable="qry_bc" />
				<cfloop list="#qry_bc#" delimiters=";" index="p">
					<cfset folderpath = folderpath & "/" & listFirst(p, "|")>
				</cfloop>
				<!--- Get custom fields --->
				<cfquery name="qry_cf" datasource="#arguments.dsn#">
				SELECT DISTINCT <cfif arguments.thedatabase EQ "mssql">cast(ft.cf_id_r AS VARCHAR(100)) + ' ' + cast(v.cf_value AS NVARCHAR(max))<cfelse>CONCAT(cast(ft.cf_id_r AS CHAR),' ',cast(v.cf_value AS CHAR))</cfif> AS customfieldvalue
				FROM #arguments.prefix#custom_fields_values v, #arguments.prefix#custom_fields_text ft
				WHERE v.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND v.cf_value <cfif arguments.thedatabase EQ "oracle" OR arguments.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				AND v.cf_id_r = ft.cf_id_r 
				AND v.host_id = ft.host_id 
				AND ft.lang_id_r = 1
				</cfquery>
				<!--- Add custom fields to a list --->
				<cfset var c = valuelist(qry_cf.customfieldvalue, " ")>
				<!--- Query labels --->
				<cfquery name="qry_l" datasource="#arguments.dsn#">
				SELECT DISTINCT l.label_path
				FROM ct_labels ct, #arguments.prefix#labels l
				WHERE ct.ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND l.label_id = ct.ct_label_id
				AND l.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
				</cfquery>
				<!--- Add labels to a list --->
				<cfset var l = valuelist(qry_l.label_path," ")>
				<cfset var l = replace(l,"/"," ","all")>
				<!--- Remove foreign chars for some columns --->
				<cfset var thefilename = REReplaceNoCase(qry_all.filename, theregchars, " ", "ALL")>
				<cfset var thedesc = REReplaceNoCase(qry_all.description, theregchars, " ", "ALL")>
				<cfset var thekeys = REReplaceNoCase(qry_all.keywords, theregchars, " ", "ALL")>
				<!--- Add labels to the query --->
				<cfquery dbtype="query" name="qry_all">
				SELECT id, folder, '#thefilename# #qry_all.filename#' as filename, filenameorg, link_kind, lucene_key,
			    '#thedesc#' as description, '#thekeys#' as keywords, rawmetadata, thecategory,
				theext, '#l#' as labels, '#REReplace(c,"#chr(13)#|#chr(9)#|\n|\r","","ALL")#' as customfieldvalue, '#folderpath#' as folderpath
				FROM qry_all
				</cfquery>
			</cfif>
			<!--- Only for video and audio files --->
			<cfif arguments.category EQ "vid" OR arguments.category EQ "aud">
				<!--- Indexing --->
					<cfscript>
					args = {
					collection : arguments.hostid,
					query : qry_all,
					category : "thecategory",
					categoryTree : "id",
					key : "id",
					title : "id",
					body : "id,filename,filenameorg,keywords,description,rawmetadata,theext,labels,customfieldvalue,folderpath,folder",
					custommap :{
						id : "id",
						filename : "filename",
						filenameorg : "filenameorg",
						keywords : "keywords",
						description : "description",
						rawmetadata : "rawmetadata",
						extension : "theext",
						labels : "labels",
						customfieldvalue : "customfieldvalue",
						folderpath : "folderpath",
						folder : "folder"
						}
					};
					results = CollectionIndexCustom( argumentCollection=args );
					</cfscript>
			</cfif>
			<cfcatch type="any">
				<cfset consoleoutput(true)>
				<cfset console(cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Index only doc files --->
		<cfif qry_all.link_kind NEQ "url" AND arguments.category EQ "doc" AND arguments.fromapi EQ "F" AND arguments.notfile EQ "F">
			<cftry>
				<!--- Nirvanix or Amazon --->
				<cfif (arguments.storage EQ "nirvanix" OR arguments.storage EQ "amazon" OR arguments.storage EQ "akamai")>
					<!--- Check if windows or not --->
					<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
					<cfif !isWindows>
						<cfset qry_all.lucene_key = replacenocase(qry_all.lucene_key," ","\ ","all")>
						<cfset qry_all.lucene_key = replacenocase(qry_all.lucene_key,"&","\&","all")>
						<cfset qry_all.lucene_key = replacenocase(qry_all.lucene_key,"'","\'","all")>
					</cfif>
					<!--- Index: Update file --->
					<cfif fileExists(qry_all.lucene_key)>
							<cfindex action="update" type="file" extensions="*.*" collection="#arguments.hostid#" key="#qry_all.lucene_key#" category="#arguments.category#" categoryTree="#qry_all.id#">
					</cfif>
				<!--- Local Storage --->
				<cfelseif qry_all.link_kind NEQ "lan" AND arguments.storage EQ "local" AND fileexists("#arguments.thestruct.assetpath#/#arguments.hostid#/#qry_all.folder#/#arguments.category#/#qry_all.id#/#qry_all.filenameorg#")>
					<!--- Index: Update file --->
						<cfindex action="update" type="file" extensions="*.*" collection="#arguments.hostid#" key="#arguments.thestruct.assetpath#/#arguments.hostid#/#qry_all.folder#/#arguments.category#/#qry_all.id#/#qry_all.filenameorg#" category="#arguments.category#" categoryTree="#qry_all.id#">
				<!--- Linked file --->
				<cfelseif qry_all.link_kind EQ "lan" AND fileexists("#arguments.thestruct.qryfile.path#")>
					<!--- Index: Update file --->
						<cfindex action="update" type="file" extensions="*.*" collection="#arguments.hostid#" key="#arguments.thestruct.qryfile.path#" category="#arguments.category#" categoryTree="#qry_all.id#">
				</cfif>
				<cfcatch type="any">
					<cfset consoleoutput(true)>
					<cfset console(cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Call to GC to clean memory --->
		<cfset createObject( "java", "java.lang.Runtime" ).getRuntime().gc()>
	</cffunction>
	
	<!--- Get custom values --->
	<cffunction name="getcustomfields" access="private">
		<cfargument name="assetid" type="string" required="false">
		<cfargument name="dsn" type="string" required="true">
		<!--- Get Custom Values --->
		<cfquery name="qry_custom" datasource="#arguments.dsn#">
		SELECT v.cf_value, f.cf_id_r, asset_id_r
		FROM #session.hostdbprefix#custom_fields_values v
		LEFT JOIN #session.hostdbprefix#custom_fields_text f ON v.cf_id_r = f.cf_id_r AND f.lang_id_r = 1
		WHERE v.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
		AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND v.host_id = f.host_id
		AND v.cf_value <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
		</cfquery>
		<!--- Return --->
		<cfreturn qry_custom>
	</cffunction>
	
	<!--- INDEX: Delete --->
	<cffunction name="index_delete" access="public" output="false">
		<cfargument name="thestruct" type="struct">
		<cfargument name="category" type="string" required="true">
		<cfargument name="assetid" type="string" required="false">
		<cfargument name="notfile" type="string" default="F" required="false">
		<!--- Param --->
		<cfparam name="arguments.thestruct.link_kind" default="">
		<!--- Index: delete file --->
		<cftry>
			<!--- Only if notfile is f --->
			<cfif arguments.notfile EQ "F">
				<!--- Asset has URL --->
				<cfif arguments.thestruct.link_kind EQ "">
					<!--- Storage: Local --->
					<cfif application.razuna.storage EQ "local">
							<cfindex action="delete" collection="#session.hostid#" key="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qrydetail.path_to_asset#/#arguments.thestruct.filenameorg#">
					<!--- Storage: Nirvanix --->
					<cfelseif (application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "akamai")>
							<cfindex action="delete" collection="#session.hostid#" key="#arguments.thestruct.qrydetail.lucene_key#">
					</cfif>
				<!--- For linked local assets --->
				<cfelseif arguments.thestruct.link_kind EQ "lan">
						<cfindex action="delete" collection="#session.hostid#" key="#arguments.thestruct.qrydetail.link_path_url#">
				</cfif>
			</cfif>
			<!--- Index: delete records --->
			<cfindex action="delete" collection="#session.hostid#" key="#arguments.assetid#">
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- Call to GC to clean memory --->
		<cfset createObject( "java", "java.lang.Runtime" ).getRuntime().gc()>
	</cffunction>
	
	<!--- INDEX: Delete Folder --->
	<cffunction name="index_delete_folder" access="public" output="false">
		<cfargument name="thestruct" type="struct">
		<cfargument name="dsn" type="string" required="true">
		<!--- Get all records which have this folder id --->
		<!--- FILES --->
		<cfquery name="arguments.thestruct.qrydetail" datasource="#arguments.dsn#">
	    SELECT file_id id, folder_id_r, file_name_org filenameorg, link_kind, link_path_url, lucene_key, path_to_asset
		FROM #session.hostdbprefix#files
		WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif arguments.thestruct.qrydetail.recordcount NEQ 0>
			<cfloop query="arguments.thestruct.qrydetail">
				<cfset arguments.thestruct.link_kind = link_kind>
				<cfset arguments.thestruct.filenameorg = arguments.thestruct.qrydetail.filenameorg>
				<!--- Remove Lucene Index --->
			 	<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#id#" category="doc">
				<!--- Delete file in folder --->
				<cfquery datasource="#arguments.dsn#">
				DELETE FROM #session.hostdbprefix#files
				WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfloop>
		</cfif>
		<!--- IMAGES --->
		<cfquery name="arguments.thestruct.qrydetail" datasource="#arguments.dsn#">
	    SELECT img_id id, folder_id_r, img_filename_org filenameorg, link_kind, link_path_url, lucene_key, path_to_asset
		FROM #session.hostdbprefix#images
		WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif arguments.thestruct.qrydetail.recordcount NEQ 0>
			<cfloop query="arguments.thestruct.qrydetail">
				<cfset arguments.thestruct.link_kind = link_kind>
				<cfset arguments.thestruct.filenameorg = arguments.thestruct.qrydetail.filenameorg>
				<!--- Remove Lucene Index --->
			 	<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#id#" category="img">
			 	<!--- Delete file in folder --->
				<cfquery datasource="#arguments.dsn#">
				DELETE FROM #session.hostdbprefix#images
				WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			 </cfloop>
		</cfif>
		<!--- VIDEOS --->
		<cfquery name="arguments.thestruct.qrydetail" datasource="#arguments.dsn#">
	    SELECT vid_id id, folder_id_r, vid_name_org filenameorg, link_kind, link_path_url, lucene_key, path_to_asset
		FROM #session.hostdbprefix#videos
		WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif arguments.thestruct.qrydetail.recordcount NEQ 0>
			<cfloop query="arguments.thestruct.qrydetail">
				<cfset arguments.thestruct.link_kind = link_kind>
				<cfset arguments.thestruct.filenameorg = arguments.thestruct.qrydetail.filenameorg>
				<!--- Remove Lucene Index --->
			 	<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#id#" category="vid">
				<!--- Delete file in folder --->
				<cfquery datasource="#arguments.dsn#">
				DELETE FROM #session.hostdbprefix#videos
				WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery> 
			</cfloop>
		</cfif>
		<!--- AUDIOS --->
		<cfquery name="arguments.thestruct.qrydetail" datasource="#arguments.dsn#">
	    SELECT aud_id id, folder_id_r, aud_name_org filenameorg, link_kind, link_path_url, lucene_key, path_to_asset
		FROM #session.hostdbprefix#audios
		WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif arguments.thestruct.qrydetail.recordcount NEQ 0>
			<cfloop query="arguments.thestruct.qrydetail">
				<cfset arguments.thestruct.link_kind = link_kind>
				<cfset arguments.thestruct.filenameorg = arguments.thestruct.qrydetail.filenameorg>
				<!--- Remove Lucene Index --->
			 	<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#id#" category="aud">
				<!--- Delete file in folder --->
				<cfquery datasource="#arguments.dsn#">
				DELETE FROM #session.hostdbprefix#audios
				WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
				</cfquery> 
			</cfloop>
		</cfif>
	</cffunction>
	
	<!--- SEARCH --->
	<cffunction name="search" access="remote" output="false" returntype="query">
		<cfargument name="criteria" type="string">
		<cfargument name="category" type="string">
		<cfargument name="hostid" type="numeric">
		<!--- If criteria is empty --->
		<cfif arguments.criteria EQ "">
			<cfset arguments.criteria = "">
		<!--- Put search together. If the criteria contains a ":" then we assume the user wants to search with his own fields --->
		<cfelseif NOT arguments.criteria CONTAINS ":" AND NOT arguments.criteria EQ "*">
			<cfset arguments.criteria = "(#arguments.criteria#) filename:(#arguments.criteria#) filenameorg:(#arguments.criteria#) keywords:(#arguments.criteria#) description:(#arguments.criteria#) rawmetadata:(#arguments.criteria#) id:(#arguments.criteria#) labels:(#arguments.criteria#)">
		</cfif>
		<cftry>
			<cfsearch collection="#arguments.hostid#" criteria="#arguments.criteria#" name="qrylucene" category="#arguments.category#">
			<cfcatch type="any">
				<cfset qrylucene = querynew("x")>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn qrylucene>
	</cffunction>
	
	<!--- SEARCH DECODED --->
	<cffunction name="searchdec" access="public" output="false">
		<cfargument name="criteria" type="string">
		<cfargument name="category" type="string">
		<!--- If we come from VP we only query collection VP --->
		<cfif structkeyexists(session, "thisapp") AND session.thisapp EQ "vp">
			<cfsearch collection="#session.hostid#vp" criteria="#arguments.criteria#" name="qrylucenedec" category="#arguments.category#">
		<cfelse>
			<cfsearch collection="#session.hostid#" criteria="#arguments.criteria#" name="qrylucenedec" category="#arguments.category#">
		</cfif>
		<cfreturn qrylucenedec>
	</cffunction>

	<!--- Get all assets for Lucene Rebuilding --->
	<cffunction name="rebuild" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Feedback --->
		<cfoutput><strong>Starting the Re-Indexing process...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Param --->
		<cfset application.razuna.processid = createuuid("")>
		<cfset arguments.thestruct.rebuild = 1>
		<!--- Set time for remove --->
		<cfset removetime = DateAdd("h", -24, "#now()#")>
		<!--- Clean the db with all entries that are older then one day
		<cfquery datasource="#variables.dsn#">
		DELETE FROM search_reindex
		WHERE datetime < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
		</cfquery> --->
		<!--- Feedback --->
		<cfoutput><strong>Removing current index...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Remove the index --->
		<!--- <cfif application.razuna.storage EQ "local">
			<cfindex action="purge" collection="#session.hostid#" />
		</cfif> --->
		<!--- Feedback --->
		<cfoutput><strong>Let's see how many documents we have to re-index...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Get all assets --->
		<cfquery name="qry" datasource="#application.razuna.datasource#"> 
	    <!--- Files --->
	    SELECT file_id id, 'doc' as cat, 'F' as notfile, folder_id_r, file_name_org, link_kind, link_path_url, 
	    file_name as thisassetname, path_to_asset, cloud_url_org, file_size thesize
		FROM #session.hostdbprefix#files
		WHERE (folder_id_r IS NOT NULL OR folder_id_r <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			AND cloud_url_org IS NOT NULL 
			AND cloud_url_org <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
		</cfif>
		UNION ALL
		<!--- Images --->
		SELECT img_id id, 'img' as cat, 'T' as notfile, folder_id_r, img_filename_org as file_name_org, link_kind, link_path_url,
		img_filename as thisassetname, path_to_asset, cloud_url_org, img_size thesize
		FROM #session.hostdbprefix#images
		WHERE (img_group IS NULL OR img_group = '')
		AND (folder_id_r IS NOT NULL OR folder_id_r <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			AND cloud_url_org IS NOT NULL 
			AND cloud_url_org <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
		</cfif>
		UNION ALL
		<!--- Videos --->
		SELECT vid_id id, 'vid' as cat, 'T' as notfile, folder_id_r, vid_name_org as file_name_org, link_kind, link_path_url,
		vid_filename as thisassetname, path_to_asset, cloud_url_org, vid_size thesize
		FROM #session.hostdbprefix#videos
		WHERE (vid_group IS NULL OR vid_group = '')
		AND (folder_id_r IS NOT NULL OR folder_id_r <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			AND cloud_url_org IS NOT NULL 
			AND cloud_url_org <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
		</cfif>
		UNION ALL
		<!--- Audios --->
		SELECT aud_id id, 'aud' as cat, 'T' as notfile, folder_id_r, aud_name_org as file_name_org, link_kind, link_path_url,
		aud_name as thisassetname, path_to_asset, cloud_url_org, aud_size thesize
		FROM #session.hostdbprefix#audios
		WHERE (aud_group IS NULL OR aud_group = '')
		AND (folder_id_r IS NOT NULL OR folder_id_r <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			AND cloud_url_org IS NOT NULL 
			AND cloud_url_org <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> ''
		</cfif>
		</cfquery>
		<!--- Feedback --->
		<cfoutput><strong>There are over #qry.recordcount# assets that we need to index. Ok, let's do this...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Feedback --->
		<cfoutput><strong>Starting re-indexing...</strong><br><br></cfoutput>
		<cfflush>
		<!--- CLOUD --->
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "akamai">
			<!--- Params --->
			<cfset arguments.thestruct.qryfile.path = arguments.thestruct.thepath & "/incoming/reindex_" & application.razuna.processid>
			<cfset arguments.thestruct.hostid = session.hostid>
			<!--- Create a temp folder for the documents --->
			<cfdirectory action="create" directory="#arguments.thestruct.qryfile.path#" mode="775">
			<!--- The tool paths --->
			<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
			<!--- Go grab the platform --->
			<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
			<!--- Loop over records --->
			<cfloop query="qry">
				<cfif link_kind NEQ "url">
					<!--- Params --->
					<cfset arguments.thestruct.link_kind = link_kind>
					<!--- DOCS download them and index --->
					<cfif cat EQ "doc">
						<!--- Feedback --->
						<cfoutput><strong>Indexing: #thisassetname# (#thesize# bytes)</strong><br></cfoutput>
						<cfflush>
						<!--- Download --->
						<cfif application.razuna.storage EQ "akamai">
							<cfhttp url="#arguments.thestruct.akaurl##arguments.thestruct.akadoc#/#file_name_org#" file="#file_name_org#" path="#arguments.thestruct.qryfile.path#"></cfhttp>
						<cfelseif cloud_url_org CONTAINS "://">
							<cfhttp url="#cloud_url_org#" file="#file_name_org#" path="#arguments.thestruct.qryfile.path#"></cfhttp>
						</cfif>
						<!--- If download was successful --->
						<cfif fileexists("#arguments.thestruct.qryfile.path#/#file_name_org#")>
							<!--- Call to update asset --->
							<cfinvoke method="index_update">
								<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
								<cfinvokeargument name="assetid" value="#id#">
								<cfinvokeargument name="category" value="#cat#">
								<cfinvokeargument name="dsn" value="#application.razuna.datasource#">
								<cfinvokeargument name="notfile" value="#notfile#">
							</cfinvoke>
							<!--- Update file DB with new lucene_key --->
							<cfquery datasource="#application.razuna.datasource#">
							UPDATE #session.hostdbprefix#files
							SET lucene_key = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.path#/#file_name_org#">
							WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
							</cfquery>
						</cfif>
					<!--- All other assets simply index --->
					<cfelse>
						<!--- Feedback --->
						<cfoutput><strong>Indexing: #thisassetname# (#thesize# bytes)...</strong><br></cfoutput>
						<cfflush>
						<!--- Call to update asset --->
						<cfinvoke method="index_update">
							<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
							<cfinvokeargument name="assetid" value="#id#">
							<cfinvokeargument name="category" value="#cat#">
							<cfinvokeargument name="dsn" value="#application.razuna.datasource#">
							<cfinvokeargument name="notfile" value="#notfile#">
						</cfinvoke>
					</cfif>
				</cfif>
			</cfloop>
		<!--- LOCAL --->
		<cfelse>
			<cfloop query="qry">
				<!--- Check if file exists if not don't index --->
				<!--- <cfif fileexists("#arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#/#file_name_org#")> --->
					<!--- Feedback --->
					<cfoutput><strong>Indexing: #thisassetname# (#thesize# bytes)...</strong><br></cfoutput>
					<cfflush>
					<!--- Params --->
					<cfset arguments.thestruct.link_kind = link_kind>
					<cfset arguments.thestruct.qryfile.path = link_path_url>
					<!--- Call to update asset --->
					<cfinvoke method="index_update">
						<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
						<cfinvokeargument name="assetid" value="#id#">
						<cfinvokeargument name="category" value="#cat#">
						<cfinvokeargument name="dsn" value="#application.razuna.datasource#">
					</cfinvoke>
				<!---
<cfelse>
					<cfoutput><strong>NOT: #arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#/#file_name_org#...</strong><br></cfoutput>
					<cfflush>
				</cfif>
--->
			</cfloop>
		</cfif>
		<!--- Reset all caches --->
		<cfset resetcachetokenall()>
		<!--- Feedback --->
		<cfoutput><br><span style="font-weight:bold;color:green;">Re-Index successfully completed!</span><br><br><a href="##" onclick="window.close();">Click this link to close this window</a></cfoutput>
		<cfflush>
		<cfreturn />
	</cffunction>
	
	<!--- INDEX: Update from API --->
	<cffunction name="index_update_api" access="remote" output="false">
		<cfargument name="assetid" type="string" required="true">
		<cfargument name="assetcategory" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="storage" type="string" required="true">
		<cfargument name="thedatabase" type="string" required="true">
		<cfargument name="prefix" type="string" required="true">
		<cfargument name="hostid" type="string" required="true">
		<!--- Call to update asset --->
		<cfinvoke method="index_update">
			<cfinvokeargument name="assetid" value="#arguments.assetid#">
			<cfinvokeargument name="category" value="#arguments.assetcategory#">
			<cfinvokeargument name="dsn" value="#arguments.dsn#">
			<cfinvokeargument name="fromapi" value="t">
			<cfinvokeargument name="prefix" value="#arguments.prefix#">
			<cfinvokeargument name="hostid" value="#arguments.hostid#">
			<cfinvokeargument name="storage" value="#arguments.storage#">
			<cfinvokeargument name="thedatabase" value="#arguments.thedatabase#">
			<cfif arguments.storage EQ "nirvanix" OR arguments.storage EQ "amazon" OR arguments.storage EQ "akamai">
				<cfinvokeargument name="notfile" value="f">
			</cfif>
		</cfinvoke>
		<cfreturn />
	</cffunction>
	
	
</cfcomponent>