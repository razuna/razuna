<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.

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
<cfcomponent extends="extQueryCaching">

	<cfset consoleoutput(false)>

	<cffunction name="newSearch" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- <cfdump var="#arguments.thestruct#">
		<cfabort> --->
		<!--- <cfset console(arguments.thestruct.razuna.session.search.search_file_ids)> --->

		<!--- Default params --->
		<cfset var qry = "">
		<cfset var qry_lucene = "">
		<!--- For union --->
		<cfset var imgHere = false />
		<cfset var vidHere = false />
		<cfset var audHere = false />
		<cfset var docHere = false />
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="" name="arguments.thestruct.change_day">
		<cfparam default="" name="arguments.thestruct.change_month">
		<cfparam default="" name="arguments.thestruct.change_year">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- if advanced search this contains "adv" --->
		<cfparam default="" name="arguments.thestruct.search_type">
		<cfparam default="0" name="arguments.thestruct.razuna.session.thegroupofuser">
		<cfparam default="0" name="arguments.thestruct.razuna.session.customaccess">
		<cfparam default="0" name="arguments.thestruct.razuna.session.search.search_file_ids">
		<cfparam default="0" name="arguments.thestruct.razuna.session.search.total_records">

		<cfparam default="false" name="arguments.thestruct.searchupc">

		<!--- If there is a change then reset offset --->
		<cfif structKeyExists(arguments.thestruct, "rowmaxpagechange")>
			<cfset arguments.thestruct.razuna.session.offset = 0>
		</cfif>

		<!--- Only applicable for files --->
		<cfparam default="" name="arguments.thestruct.doctype">
		<cfparam default="False" name="arguments.thestruct.avoidpagination">

		<!--- Set sortby variable --->
		<cfset arguments.thestruct.sortby = arguments.thestruct.razuna.session.sortby>
		<!--- Set the order by --->
		<cfif arguments.thestruct.razuna.session.sortby EQ "name">
			<cfset arguments.thestruct.sortby = "filename_forsort">
		<cfelseif arguments.thestruct.razuna.session.sortby EQ "sizedesc">
			<cfset arguments.thestruct.sortby = "size DESC">
		<cfelseif arguments.thestruct.razuna.session.sortby EQ "sizeasc">
			<cfset arguments.thestruct.sortby = "size ASC">
		<cfelseif arguments.thestruct.razuna.session.sortby EQ "dateadd">
			<cfset arguments.thestruct.sortby = "date_create DESC">
		<cfelseif arguments.thestruct.razuna.session.sortby EQ "datechanged">
			<cfset arguments.thestruct.sortby = "date_change DESC">
		</cfif>

		<!--- MySQL Offset --->
		<cfset arguments.thestruct.mysqloffset = arguments.thestruct.razuna.session.offset * arguments.thestruct.razuna.session.rowmaxpage>

		<!--- if search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "*">
		</cfif>
		<!--- if we come from all set the category --->
		<cfif arguments.thestruct.thetype EQ "all">
			<cfset var thetype = "doc,vid,img,aud" />
		<cfelse>
			<cfset var thetype = arguments.thestruct.thetype />
		</cfif>

		<!--- Startrow for Lucene --->
		<cfif arguments.thestruct.razuna.session.offset EQ 0>
			<cfset var lucene_startrow = 1 />
		<cfelse>
			<cfset var lucene_startrow = arguments.thestruct.mysqloffset />
		</cfif>

		<!--- Only if we have dates --->
		<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
			<!--- If search text is * --->
			<cfif arguments.thestruct.searchtext EQ "*">
				<cfset arguments.thestruct.searchtext = "">
			<cfelse>
				<cfset arguments.thestruct.searchtext = arguments.thestruct.searchtext & " ">
			</cfif>
			<!--- Set the create time string --->
			<cfset arguments.thestruct.searchtext = '#arguments.thestruct.searchtext#create_time:("#arguments.thestruct.on_year##arguments.thestruct.on_month##arguments.thestruct.on_day#")'>
		</cfif>
		<cfif arguments.thestruct.change_day NEQ "" AND arguments.thestruct.change_month NEQ "" AND arguments.thestruct.change_year NEQ "">
			<!--- If search text is * --->
			<cfif arguments.thestruct.searchtext EQ "*">
				<cfset arguments.thestruct.searchtext = "">
			<cfelse>
				<cfset arguments.thestruct.searchtext = arguments.thestruct.searchtext & " ">
			</cfif>arguments.thestruct.prefs
			<!--- Set the change time string --->
			<cfset arguments.thestruct.searchtext = '#arguments.thestruct.searchtext#change_time:("#arguments.thestruct.change_year##arguments.thestruct.change_month##arguments.thestruct.change_day#")'>
		</cfif>

		<!--- Get all the folders the user is allowed to access but not if we are admin or list_recfolders has records --->
		<cfif ( arguments.thestruct.list_recfolders EQ "0" OR arguments.thestruct.list_recfolders EQ "" ) AND NOT ( arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator )>
			<cfinvoke component="users" method="getAllFolderOfUser" user_id="#arguments.thestruct.razuna.session.theuserid#" host_id="#arguments.thestruct.razuna.session.hostid#" returnvariable="arguments.thestruct.list_recfolders" thestruct="#arguments.thestruct#">
		</cfif>

		<!--- If we come from a search in a search we need to set row to 0 in order to find all records --->
		<cfif arguments.thestruct.newsearch EQ "T">
			<cfset var _startrow = lucene_startrow>
			<cfset var _maxrows = arguments.thestruct.razuna.session.rowmaxpage>
		<cfelse>
			<cfset var _startrow = 0>
			<cfset var _maxrows = 0>
		</cfif>

		<cfset arguments.thestruct.searchupc = arguments.thestruct.searchupc ? true : false>
		<cfset arguments.thestruct.razuna.session.search.searchupc = arguments.thestruct.searchupc ? true : false>
		<cfset arguments.thestruct.razuna.session.search.searchtext = arguments.thestruct.searchtext>
		<cfset arguments.thestruct.razuna.session.search.searchtype = thetype>
		<cfset arguments.thestruct.razuna.session.search.searchfolderid = arguments.thestruct.folder_id>
		<cfset arguments.thestruct.razuna.session.search.searchrenditions = arguments.thestruct.prefs.set2_rendition_search>

		<!--- Search in Lucene  --->
		<cfinvoke component="lucene" method="search" criteria="#arguments.thestruct.searchtext#" category="#thetype#" hostid="#arguments.thestruct.razuna.session.hostid#" startrow="#_startrow#" maxrows="#_maxrows#" folderid="#arguments.thestruct.list_recfolders#" search_type="#arguments.thestruct.search_type#" search_rendition="#arguments.thestruct.prefs.set2_rendition_search#" search_upc="#arguments.thestruct.searchupc#" thestruct="#arguments.thestruct#" returnvariable="qry_lucene">

		<!--- Get all ids --->
		<cfinvoke method="getAllIdsWithType" qry_lucene="#qry_lucene#" iscol="#arguments.thestruct.iscol#" newsearch="#arguments.thestruct.newsearch#" thestruct="#arguments.thestruct#" returnvariable="qry_idstype">

		<cfif qry_lucene.recordcount NEQ 0 AND qry_idstype.recordcount NEQ 0>
			<!--- Group type together --->
			<cfquery dbtype="query" name="grptype">
			SELECT category
			FROM qry_idstype
			GROUP BY category
			</cfquery>
			<!--- We got all the types. Now search in each table --->
			<cfloop query="grptype">
				<cfif category EQ "img">
					<cfinvoke method="_imgSearch" thestruct="#arguments.thestruct#" qry_idstype="#qry_idstype#" returnvariable="qry_img" />
					<!--- Set list --->
					<cfset arguments.thestruct.listimgid = valueList(qry_img.id) />
					<!--- For union --->
					<cfset var imgHere = true />
				<cfelseif category EQ "vid">
					<cfinvoke method="_vidSearch" thestruct="#arguments.thestruct#" qry_idstype="#qry_idstype#" returnvariable="qry_vid" />
					<!--- Set list --->
					<cfset arguments.thestruct.listvidid = valueList(qry_vid.id) />
					<!--- For union --->
					<cfset var vidHere = true />
				<cfelseif category EQ "doc">
					<cfinvoke method="_docSearch" thestruct="#arguments.thestruct#" qry_idstype="#qry_idstype#" returnvariable="qry_doc" />
					<!--- Set list --->
					<cfset arguments.thestruct.listdocid = valueList(qry_doc.id) />
					<!--- For union --->
					<cfset var docHere = true />
				<cfelseif category EQ "aud">
					<cfinvoke method="_audSearch" thestruct="#arguments.thestruct#" qry_idstype="#qry_idstype#" returnvariable="qry_aud" />
					<!--- Set list --->
					<cfset arguments.thestruct.listaudid = valueList(qry_aud.id) />
					<!--- For union --->
					<cfset var audHere = true />
				</cfif>
			</cfloop>
			<!--- Combine queries --->
			<!--- All found records, despite paging are in searchcount of the lucene query --->
			<cfif arguments.thestruct.newsearch EQ "T">
				<cfset var _imgCount = qry_lucene.searchcount>
				<cfset var _vidCount = qry_lucene.searchcount>
				<cfset var _audCount = qry_lucene.searchcount>
				<cfset var _docCount = qry_lucene.searchcount>
			<cfelse>
				<cfif imgHere>
					<cfset var _imgCount = qry_img.recordcount>
				</cfif>
				<cfif vidHere>
					<cfset var _vidCount = qry_vid.recordcount>
				</cfif>
				<cfif audHere>
					<cfset var _audCount = qry_aud.recordcount>
				</cfif>
				<cfif docHere>
					<cfset var _docCount = qry_doc.recordcount>
				</cfif>
			</cfif>
			<cfquery dbtype="query" name="qry">
			<cfif imgHere>
				SELECT #_imgCount# as searchcount, *
				FROM qry_img
			</cfif>
			<cfif vidHere>
				<cfif imgHere>
					UNION ALL
				</cfif>
				SELECT #_vidCount# as searchcount, *
				FROM qry_vid
			</cfif>
			<cfif docHere>
				<cfif vidHere OR imgHere>
					UNION ALL
				</cfif>
				SELECT #_docCount# as searchcount, *
				FROM qry_doc
			</cfif>
			<cfif audHere>
				<cfif docHere OR vidHere OR imgHere>
					UNION ALL
				</cfif>
				SELECT #_audCount# as searchcount, *
				FROM qry_aud
			</cfif>
			</cfquery>

			<!--- <cfset console("--- qry ---")>
			<cfset console(qry)> --->

			<!--- Only get the labels if in the combined view --->
			<cfif arguments.thestruct.razuna.session.view EQ "combined">
				<!--- Get the cachetoken for here --->
				<cfset var cachetokenlabels = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
				<!--- Loop over files and get labels and add to qry --->
				<cfloop query="qry">
					<!--- Query labels --->
					<cfquery name="qry_l" datasource="#arguments.thestruct.razuna.application.datasource#" cachedwithin="1" region="razcache">
					SELECT /* #cachetokenlabels#getallassetslabels */ ct_label_id
					FROM ct_labels
					WHERE ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
					</cfquery>
					<!--- Add labels query --->
					<cfif qry_l.recordcount NEQ 0>
						<cfset QuerySetCell(qry, "labels", valueList(qry_l.ct_label_id), currentRow)>
					</cfif>
				</cfloop>
			</cfif>
			<!--- Init var for new fileid --->
			<cfset var editids = "0,">
			<cfset var fileids = "">
			<cfif qry.recordcount>
				<cfloop query="qry_lucene">
					<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" thestruct="#arguments.thestruct#" folder_id="#folder#" />
					<!--- Get trash or not --->
					<cfset _in_trash = checkFilesForTrashStatus(type=category, id=categorytree, thestruct=arguments.thestruct)>
					<!--- Store only file_ids where folder access is not R --->
					<cfif theaccess NEQ "R" AND theaccess NEQ "n" AND _in_trash EQ "f">
						<!--- // <cfset editids = editids & listid & ","> --->
						<cfset editids = editids & categorytree & "-" & category & ",">
						<cfset fileids = fileids & categorytree & "-" & category & ",">
					</cfif>
					<!--- Set --->
					<cftry>
						<cfset QuerySetCell(qry, "permfolder", theaccess, currentRow)>
						<cfcatch></cfcatch>
					</cftry>
				</cfloop>
			</cfif>
			<!--- Save the editable ids in a session --->
			<cfset arguments.thestruct.razuna.session.search.edit_ids = editids>
			<!--- Save fileids into session --->
			<cfset arguments.thestruct.razuna.session.search.search_file_ids = fileids>
		<!--- Nothing found --->
		<cfelse>
			<!--- Save the editable ids in a session --->
			<cfset arguments.thestruct.razuna.session.search.edit_ids = "0">
			<!--- Save fileids into session --->
			<cfset arguments.thestruct.razuna.session.search.search_file_ids = "0">

			<cfset qry = querynew("searchcount")>
			<cfset queryaddrow(qry)>
			<cfset QuerySetCell(qry,"searchcount",0)>
		</cfif>

		<!--- Set var --->
		<cfset var _foundtotal = qry.searchcount>
		<cfset arguments.thestruct.razuna.session.search.total_records = qry.searchcount>

		<!--- If nothing found make foundtotal a number --->
		<cfif qry.recordcount EQ 0>
			<cfset var _foundtotal = 0>
			<!--- Save the editable ids in a session --->
			<cfset arguments.thestruct.razuna.session.search.edit_ids = "0">
			<!--- Save fileids into session --->
			<cfset arguments.thestruct.razuna.session.search.search_file_ids = "0">
			<cfset qry = querynew("searchcount")>
			<cfset queryaddrow(qry)>
			<cfset QuerySetCell(qry,"searchcount",0)>
		</cfif>

		<!--- Log Result --->
		<cfset log_search(theuserid=arguments.thestruct.razuna.session.theuserid, searchfor=arguments.thestruct.searchtext, foundtotal=_foundtotal,searchfrom='img', hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>

		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<cffunction name="checkFilesForTrashStatus" return="string">
		<cfargument name="type" type="string">
		<cfargument name="id" type="string">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset var qry = "">
		<cfif arguments.type EQ "img">
			<cfset var _db = "images">
			<cfset var _id = "img_id">
		<cfelseif arguments.type EQ "vid">
			<cfset var _db = "videos" />
			<cfset var _id = "vid_id" />
		<cfelseif arguments.type EQ "aud">
			<cfset var _db = "audios" />
			<cfset var _id = "aud_id" />
		<cfelseif arguments.type EQ "doc">
			<cfset var _db = "files" />
			<cfset var _id = "file_id" />
		</cfif>
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#checkFilesForTrashStatus */ in_trash
		FROM #arguments.thestruct.razuna.session.hostdbprefix##_db#
		WHERE #_id# = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfreturn qry.in_trash>
	</cffunction>

	<cffunction name="getAllIdsWithType">
		<cfargument name="qry_lucene" type="query">
		<cfargument name="iscol" type="string">
		<cfargument name="newsearch" type="string">

		<cfset var cattree = "">
		<!--- If lucene returns no records --->
		<cfif arguments.qry_lucene.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattree">
				SELECT categorytree, category
				FROM arguments.qry_lucene
				WHERE categorytree != ''
				GROUP BY categorytree, category
				ORDER BY rank
			</cfquery>
			<!--- This is only needed if we come from a share which is a collection. We filter on the asset id in the collection --->
			<cfif arguments.iscol EQ "T">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree, category
				FROM cattree
				WHERE categorytree
				<cfif arguments.qry_lucene.recordcount EQ 0>
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.qry_lucene.categorytree)#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
			<!--- Search in a search --->
			<cfif arguments.newsearch EQ "F">
				<cfset var _ids = 0>
				<!--- Get ids --->
				<cfloop list="#arguments.thestruct.razuna.session.search.search_file_ids#" delimiters="," index="i">
					<cfset _ids = _ids & ',' & listfirst(i,"-")>
				</cfloop>
				<!--- <cfset console("--- getAllIdsWithType : _ids ---")>
				<cfset console(_ids)> --->
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree, category
				FROM cattree
				WHERE categorytree IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#_ids#" list="true">)
				</cfquery>
			</cfif>
		<cfelse>
			<cfset var cattree = querynew("categorytree")>
		</cfif>

		<cfreturn cattree>
	</cffunction>


	<!--- PRIVATE --->

	<!--- Search for images --->
	<cffunction name="_imgSearch" returntype="query" access="private">
		<cfargument name="thestruct" type="struct">
		<cfargument name="qry_idstype" type="query">
		<!--- Param --->
		<cfset var qry = "" />
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			<!--- MSSQL --->
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				with myresult as (
					SELECT ROW_NUMBER() OVER ( ORDER BY <cfif arguments.thestruct.sortby NEQ 'filename_forsort'>#arguments.thestruct.sortby#,filename_forsort<cfelse>#arguments.thestruct.sortby#</cfif> ) AS RowNum,sorted_inline_view.* FROM (
			<cfelse>
				SELECT * FROM (
			</cfif>
				SELECT /* #cachetoken#imgSearch */ i.img_id id, i.img_filename filename, i.folder_id_r, i.img_group groupid,
				i.thumb_extension ext, i.img_filename_org filename_org, 'img' as kind, i.is_available,
				i.img_create_time date_create, i.img_change_date date_change, i.link_kind, i.link_path_url,
				i.path_to_asset, i.cloud_url, i.cloud_url_org, i.in_trash, it.img_description description, it.img_keywords keywords,
				'0' as vwidth, '0' as vheight, '0' isalias,
				(
					SELECT so.asset_format
					FROM #arguments.thestruct.razuna.session.hostdbprefix#share_options so
					WHERE i.img_id = so.group_asset_id
					AND so.folder_id_r = i.folder_id_r
					AND so.asset_type = 'img'
					AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				) AS theformat,
				i.img_filename filename_forsort,
				cast(i.img_size as decimal(12,0)) size,
				i.hashtag,
				fo.folder_name,
				'' as labels,
				i.img_width width, i.img_height height, x.xres xres, x.yres yres, x.colorspace colorspace, CASE WHEN NOT (i.img_group is null OR i.img_group='') THEN (SELECT expiry_date FROM #arguments.thestruct.razuna.session.hostdbprefix#images WHERE img_id=i.img_group) ELSE i.expiry_date END  expiry_date_actual,
				<cfif arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator AND arguments.thestruct.razuna.session.customaccess EQ "">
					'X' as permfolder
				<cfelseif arguments.thestruct.razuna.session.customaccess NEQ "">
					'#arguments.thestruct.razuna.session.customaccess#' as permfolder
				<cfelse>
					'R' as permfolder
				</cfif>
				,
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">i.img_id + '-img'<cfelse>concat(i.img_id,'-img')</cfif> as listid
				<!--- custom metadata fields to show --->
				<cfif arguments.thestruct.cs.images_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
						,<cfif m CONTAINS "keywords" OR m CONTAINS "description">it
						<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number" OR m CONTAINS "expiry_date">i
						<cfelse>x
						</cfif>.#m#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.videos_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.files_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.audios_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				FROM #arguments.thestruct.razuna.session.hostdbprefix#images i
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#xmp x ON i.img_id = x.id_r AND i.host_id = x.host_id
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON fo.folder_id = i.folder_id_r AND i.host_id = fo.host_id
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = <cfqueryparam value="#arguments.thestruct.razuna.session.thelangid#" cfsqltype="cf_sql_numeric"> AND i.host_id = it.host_id
				WHERE i.img_id IN (<cfif arguments.qry_idstype.categorytree EQ "">'0'<cfelse>'0'<cfloop query="arguments.qry_idstype">,'#categorytree#'</cfloop></cfif>)
				<!--- Only if we have a folder id that is not 0 --->
				<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
					AND i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
				</cfif>
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
				AND CASE
				<!--- Check if admin user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
				<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND i.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
				<!--- If rendition then look at expiry_date for original asset --->
				WHEN NOT (i.img_group is null OR i.img_group='')
				 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND i.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #arguments.thestruct.razuna.session.hostdbprefix#images WHERE img_id = i.img_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
				ELSE 1 END  = 1
				 GROUP BY i.img_id, i.img_filename, i.folder_id_r, i.thumb_extension, i.img_filename_org, i.is_available, i.img_create_time, i.img_change_date, i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org, it.img_description, it.img_keywords, i.img_size, i.img_width, i.img_height, x.xres, x.yres, x.colorspace, i.hashtag, fo.folder_name, i.img_group, fo.folder_of_user, fo.folder_owner, i.in_trash, i.img_upc_number, i.expiry_date
				<!--- Get Aliases --->
				UNION ALL
				SELECT /* #cachetoken#imgSearchAlias */ i.img_id id,  i.img_filename filename, ct.folder_id_r, i.img_group groupid,
				i.thumb_extension ext, i.img_filename_org filename_org, 'img' as kind, i.is_available,
				i.img_create_time date_create, i.img_change_date date_change, i.link_kind, i.link_path_url,
				i.path_to_asset, i.cloud_url, i.cloud_url_org, i.in_trash, it.img_description description, it.img_keywords keywords,
				'0' as vwidth, '0' as vheight,  '1' isalias,
				(
					SELECT so.asset_format
					FROM #arguments.thestruct.razuna.session.hostdbprefix#share_options so
					WHERE i.img_id = so.group_asset_id
					AND so.folder_id_r = max(i.folder_id_r)
					AND so.asset_type = 'img'
					AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				) AS theformat,
				i.img_filename filename_forsort,
				cast(i.img_size as decimal(12,0)) size,
				i.hashtag,
				fo.folder_name,
				'' as labels,
				i.img_width width, i.img_height height, x.xres xres, x.yres yres, x.colorspace colorspace, CASE WHEN NOT (i.img_group is null OR i.img_group='') THEN (SELECT expiry_date FROM #arguments.thestruct.razuna.session.hostdbprefix#images WHERE img_id=i.img_group) ELSE i.expiry_date END  expiry_date_actual,
				<cfif arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator AND arguments.thestruct.razuna.session.customaccess EQ "">
					'X' as permfolder
				<cfelseif arguments.thestruct.razuna.session.customaccess NEQ "">
					'#arguments.thestruct.razuna.session.customaccess#' as permfolder
				<cfelse>
					'R' as permfolder
				</cfif>
				,
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">i.img_id + '-img'<cfelse>concat(i.img_id,'-img')</cfif> as listid
				<!--- custom metadata fields to show --->
				<cfif arguments.thestruct.cs.images_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
						,<cfif m CONTAINS "keywords" OR m CONTAINS "description">it
						<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number" OR m CONTAINS "expiry_date">i
						<cfelse>x
						</cfif>.#m#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.videos_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.files_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.audios_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				FROM #arguments.thestruct.razuna.session.hostdbprefix#images i
				INNER JOIN ct_aliases ct ON i.img_id = ct.asset_id_r
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#xmp x ON i.img_id = x.id_r AND i.host_id = x.host_id
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON fo.folder_id = ct.folder_id_r AND i.host_id = fo.host_id
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = <cfqueryparam value="#arguments.thestruct.razuna.session.thelangid#" cfsqltype="cf_sql_numeric"> AND i.host_id = it.host_id
				WHERE i.img_id IN (<cfif arguments.qry_idstype.categorytree EQ "">'0'<cfelse>'0'<cfloop query="arguments.qry_idstype">,'#categorytree#'</cfloop></cfif>)
				<!--- Only if we have a folder id that is not 0 --->
				<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
					AND ct.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
				</cfif>
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
				AND CASE
				<!--- Check if admin user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
				<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND ct.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
				<!--- If rendition then look at expiry_date for original asset --->
				WHEN NOT (i.img_group is null OR i.img_group='')
				 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND ct.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #arguments.thestruct.razuna.session.hostdbprefix#images WHERE img_id = i.img_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
				ELSE 1 END  = 1
				GROUP BY i.img_id, i.img_filename, ct.folder_id_r, i.thumb_extension, i.img_filename_org, i.is_available, i.img_create_time, i.img_change_date, i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org, it.img_description, it.img_keywords, i.img_size, i.img_width, i.img_height, x.xres, x.yres, x.colorspace, i.hashtag, fo.folder_name, i.img_group, fo.folder_of_user, fo.folder_owner, i.in_trash, i.img_upc_number, i.expiry_date
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
					) sorted_inline_view
					)
					select *
			    	from myresult
					WHERE kind IS NOT NULL
					<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
						AND permfolder IS NOT NULL
					</cfif>
					<!---
					<cfif structKeyExists(arguments.thestruct,'avoidpagination') AND arguments.thestruct.avoidpagination EQ "False">
						AND RowNum >
							CASE WHEN
								(
									SELECT count(RowNum) FROM myresult
									<cfif arguments.thestruct.thetype NEQ "all" >
										where kind='#arguments.thestruct.thetype#'
									</cfif>
								) > #arguments.thestruct.mysqloffset#

								THEN #arguments.thestruct.mysqloffset#
								ELSE 0
								END
						AND
						RowNum <=
							CASE WHEN
								(
									SELECT count(RowNum) FROM myresult
									<cfif arguments.thestruct.thetype NEQ "all" >
										where kind='#arguments.thestruct.thetype#'
									</cfif>
								) > #arguments.thestruct.mysqloffset#

								THEN #arguments.thestruct.mysqloffset+arguments.thestruct.razuna.session.rowmaxpage#
								ELSE #arguments.thestruct.razuna.session.rowmaxpage#
								END
					</cfif>
					--->
				<!--- MySql OR H2 --->
				<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">
					) as t
					WHERE kind IS NOT NULL
					<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
						AND permfolder IS NOT NULL
					</cfif>
					ORDER BY #arguments.thestruct.sortby#
				</cfif>
			</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Search for Videos --->
	<cffunction name="_vidSearch" returntype="query" access="private">
		<cfargument name="thestruct" type="struct">
		<cfargument name="qry_idstype" type="query">
		<!--- Param --->
		<cfset var qry = "" />
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="videos", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			<!--- MSSQL --->
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				with myresult as (
					SELECT ROW_NUMBER() OVER ( ORDER BY <cfif arguments.thestruct.sortby NEQ 'filename_forsort'>#arguments.thestruct.sortby#,filename_forsort<cfelse>#arguments.thestruct.sortby#</cfif> ) AS RowNum,sorted_inline_view.* FROM (
			<cfelse>
				SELECT * FROM (
			</cfif>
			SELECT /* #cachetoken#vidSearch */ v.vid_id id, v.vid_filename filename, v.folder_id_r, v.vid_group groupid,
			v.vid_extension ext, v.vid_name_image filename_org, 'vid' as kind, v.is_available,
			v.vid_create_time date_create, v.vid_change_date date_change, v.link_kind, v.link_path_url,
			v.path_to_asset, v.cloud_url, v.cloud_url_org, v.in_trash, vt.vid_description description, vt.vid_keywords keywords, CAST(v.vid_width AS CHAR) as vwidth, CAST(v.vid_height AS CHAR) as vheight,  '0' isalias,
			(
				SELECT so.asset_format
				FROM #arguments.thestruct.razuna.session.hostdbprefix#share_options so
				WHERE v.vid_id = so.group_asset_id
				AND so.folder_id_r = v.folder_id_r
				AND so.asset_type = 'vid'
				AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
			) AS theformat,
			v.vid_filename filename_forsort,
			cast(v.vid_size as decimal(12,0)) size,
			v.hashtag,
			fo.folder_name,
			'' as labels,
			'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace, CASE WHEN NOT (v.vid_group is null OR v.vid_group='') THEN (SELECT expiry_date FROM #arguments.thestruct.razuna.session.hostdbprefix#videos WHERE vid_id=v.vid_group) ELSE v.expiry_date END  expiry_date_actual,
			<cfif arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator AND arguments.thestruct.razuna.session.customaccess EQ "">
				'X' as permfolder
			<cfelseif arguments.thestruct.razuna.session.customaccess NEQ "">
				'#arguments.thestruct.razuna.session.customaccess#' as permfolder
			<cfelse>
				'R' as permfolder
			</cfif>
			,
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">v.vid_id + '-vid'<cfelse>concat(v.vid_id,'-vid')</cfif> as listid
			<!--- custom metadata fields to show --->
			<cfif arguments.thestruct.cs.images_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.videos_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
					,<cfif m CONTAINS "keywords" OR m CONTAINS "description">vt
					<cfelse>v
					</cfif>.#m#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.files_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.audios_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			FROM #arguments.thestruct.razuna.session.hostdbprefix#videos v
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#videos_text vt ON vt.vid_id_r = v.vid_id AND vt.lang_id_r = <cfqueryparam value="#arguments.thestruct.razuna.session.thelangid#" cfsqltype="cf_sql_numeric"> AND v.host_id = vt.host_id
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON fo.folder_id = v.folder_id_r AND v.host_id = fo.host_id
			WHERE v.vid_id IN (<cfif arguments.qry_idstype.categorytree EQ "">'0'<cfelse>'0'<cfloop query="arguments.qry_idstype">,'#categorytree#'</cfloop></cfif>)
			<!--- Only if we have a folder id that is not 0 --->
			<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
				AND v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
			</cfif>
			AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			AND v.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND v.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
			<!--- If rendition then look at expiry_date for original asset --->
			WHEN NOT (v.vid_group is null OR v.vid_group='')
			 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND v.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #arguments.thestruct.razuna.session.hostdbprefix#videos WHERE vid_id = v.vid_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
			ELSE 1 END  = 1
			GROUP BY v.vid_id, v.vid_filename, v.folder_id_r, v.vid_extension, v.vid_name_image, v.is_available, v.vid_create_time, v.vid_change_date, v.link_kind, v.link_path_url, v.path_to_asset, v.cloud_url, v.cloud_url_org, vt.vid_description, vt.vid_keywords, v.vid_width, v.vid_height, v.vid_size, v.hashtag, fo.folder_name, v.vid_group, fo.folder_of_user, fo.folder_owner, v.in_trash, v.vid_upc_number, v.expiry_date

		<!--- Get aliases --->
		UNION ALL
		SELECT /* #cachetoken#vidSearchAlias */ v.vid_id id, v.vid_filename filename, ct.folder_id_r, v.vid_group groupid,
			v.vid_extension ext, v.vid_name_image filename_org, 'vid' as kind, v.is_available,
			v.vid_create_time date_create, v.vid_change_date date_change, v.link_kind, v.link_path_url,
			v.path_to_asset, v.cloud_url, v.cloud_url_org, v.in_trash, vt.vid_description description, vt.vid_keywords keywords, CAST(v.vid_width AS CHAR) as vwidth, CAST(v.vid_height AS CHAR) as vheight,  '1' isalias,
			(
				SELECT so.asset_format
				FROM #arguments.thestruct.razuna.session.hostdbprefix#share_options so
				WHERE v.vid_id = so.group_asset_id
				AND so.folder_id_r = max(v.folder_id_r)
				AND so.asset_type = 'vid'
				AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
			) AS theformat,
			v.vid_filename filename_forsort,
			cast(v.vid_size as decimal(12,0)) size,
			v.hashtag,
			fo.folder_name,
			'' as labels,
			'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace, CASE WHEN NOT (v.vid_group is null OR v.vid_group='') THEN (SELECT expiry_date FROM #arguments.thestruct.razuna.session.hostdbprefix#videos WHERE vid_id=v.vid_group) ELSE v.expiry_date END  expiry_date_actual,
			<cfif arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator AND arguments.thestruct.razuna.session.customaccess EQ "">
				'X' as permfolder
			<cfelseif arguments.thestruct.razuna.session.customaccess NEQ "">
				'#arguments.thestruct.razuna.session.customaccess#' as permfolder
			<cfelse>
				'R' as permfolder
			</cfif>
			,
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">v.vid_id + '-vid'<cfelse>concat(v.vid_id,'-vid')</cfif> as listid
			<!--- custom metadata fields to show --->
			<cfif arguments.thestruct.cs.images_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.videos_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
					,<cfif m CONTAINS "keywords" OR m CONTAINS "description">vt
					<cfelse>v
					</cfif>.#m#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.files_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.audios_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			FROM #arguments.thestruct.razuna.session.hostdbprefix#videos v
			INNER JOIN ct_aliases ct ON v.vid_id = ct.asset_id_r
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#videos_text vt ON vt.vid_id_r = v.vid_id AND vt.lang_id_r = <cfqueryparam value="#arguments.thestruct.razuna.session.thelangid#" cfsqltype="cf_sql_numeric"> AND v.host_id = vt.host_id
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON fo.folder_id = ct.folder_id_r AND v.host_id = fo.host_id
			WHERE v.vid_id IN (<cfif arguments.qry_idstype.categorytree EQ "">'0'<cfelse>'0'<cfloop query="arguments.qry_idstype">,'#categorytree#'</cfloop></cfif>)
			<!--- Only if we have a folder id that is not 0 --->
			<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
				AND ct.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
			</cfif>
			AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			AND v.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND ct.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
			<!--- If rendition then look at expiry_date for original asset --->
			WHEN NOT (v.vid_group is null OR v.vid_group='')
			 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND ct.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #arguments.thestruct.razuna.session.hostdbprefix#videos WHERE vid_id = v.vid_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
			ELSE 1 END  = 1
		GROUP BY v.vid_id, v.vid_filename, ct.folder_id_r, v.vid_extension, v.vid_name_image, v.is_available, v.vid_create_time, v.vid_change_date, v.link_kind, v.link_path_url, v.path_to_asset, v.cloud_url, v.cloud_url_org, vt.vid_description, vt.vid_keywords, v.vid_width, v.vid_height, v.vid_size, v.hashtag, fo.folder_name, v.vid_group, fo.folder_of_user, fo.folder_owner, v.in_trash, v.vid_upc_number, v.expiry_date
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				) sorted_inline_view
				)
				select *
				FROM myresult
				WHERE kind IS NOT NULL
				<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
					AND permfolder IS NOT NULL
				</cfif>
				<!---
				<cfif structKeyExists(arguments.thestruct,'avoidpagination') AND arguments.thestruct.avoidpagination EQ "False">
					AND RowNum >
						CASE WHEN
							(
								SELECT count(RowNum) FROM myresult
								<cfif arguments.thestruct.thetype NEQ "all" >
									where kind='#arguments.thestruct.thetype#'
								</cfif>
							) > #arguments.thestruct.mysqloffset#

							THEN #arguments.thestruct.mysqloffset#
							ELSE 0
							END
					AND
					RowNum <=
						CASE WHEN
							(
								SELECT count(RowNum) FROM myresult
								<cfif arguments.thestruct.thetype NEQ "all" >
									where kind='#arguments.thestruct.thetype#'
								</cfif>
							) > #arguments.thestruct.mysqloffset#

							THEN #arguments.thestruct.mysqloffset+arguments.thestruct.razuna.session.rowmaxpage#
							ELSE #arguments.thestruct.razuna.session.rowmaxpage#
							END
				</cfif>
				--->
			<!--- MySql OR H2 --->
			<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">
				) as t
				WHERE kind IS NOT NULL
				<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
					AND permfolder IS NOT NULL
				</cfif>
				ORDER BY #arguments.thestruct.sortby#
			</cfif>

		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Search for Files --->
	<cffunction name="_docSearch" returntype="query" access="private">
		<cfargument name="thestruct" type="struct">
		<cfargument name="qry_idstype" type="query">
		<!--- Param --->
		<cfset var qry = "" />
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="files", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			<!--- MSSQL --->
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				with myresult as (
					SELECT ROW_NUMBER() OVER ( ORDER BY <cfif arguments.thestruct.sortby NEQ 'filename_forsort'>#arguments.thestruct.sortby#,filename_forsort<cfelse>#arguments.thestruct.sortby#</cfif> ) AS RowNum,sorted_inline_view.* FROM (
			<cfelse>
				SELECT * FROM (
			</cfif>
			SELECT /* #cachetoken#docSearch */ f.file_id id, f.file_name filename, f.folder_id_r, '' as groupid,
			f.file_extension ext, f.file_name_org filename_org, f.file_type as kind, f.is_available,
			f.file_create_time date_create, f.file_change_date date_change, f.link_kind, f.link_path_url,
			f.path_to_asset, f.cloud_url, f.cloud_url_org, f.in_trash, fd.file_desc description, fd.file_keywords keywords,
			'0' as vwidth, '0' as vheight,  '0' isalias,
			'0' as theformat, f.file_name filename_forsort, cast(f.file_size as decimal(12,0)) size, f.hashtag,
			fo.folder_name,
			'' as labels,
			'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace,f.expiry_date expiry_date_actual,
			<cfif arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator AND arguments.thestruct.razuna.session.customaccess EQ "">
				'X' as permfolder
			<cfelseif arguments.thestruct.razuna.session.customaccess NEQ "">
				'#arguments.thestruct.razuna.session.customaccess#' as permfolder
			<cfelse>
				'R' as permfolder
			</cfif>
			,
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">f.file_id + '-doc'<cfelse>concat(f.file_id,'-doc')</cfif> as listid
			<!--- custom metadata fields to show --->
			<cfif arguments.thestruct.cs.images_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.videos_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.files_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
					,<cfif m CONTAINS "keywords" OR m CONTAINS "description">fd
					<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number" OR m CONTAINS "expiry_date">f
					<cfelse>x
					</cfif>.#m#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.audios_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			FROM #arguments.thestruct.razuna.session.hostdbprefix#files f
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON fo.folder_id = f.folder_id_r AND f.host_id = fo.host_id
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#files_desc fd ON f.file_id = fd.file_id_r AND fd.lang_id_r = <cfqueryparam value="#arguments.thestruct.razuna.session.thelangid#" cfsqltype="cf_sql_numeric"> AND f.host_id = fd.host_id
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#files_xmp x ON x.asset_id_r = f.file_id AND f.host_id = x.host_id
			WHERE f.file_id IN (<cfif arguments.qry_idstype.categorytree EQ "">'0'<cfelse>'0'<cfloop query="arguments.qry_idstype">,'#categorytree#'</cfloop></cfif>)
			<!--- Only if we have a folder id that is not 0 --->
			<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
				AND f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
			</cfif>
			AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND f.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
			ELSE 1 END  = 1
			GROUP BY f.file_id, f.file_name, f.folder_id_r, f.file_extension, f.file_name_org, f.file_type, f.is_available, f.file_create_time, f.file_change_date, f.link_kind, f.link_path_url, f.path_to_asset, f.cloud_url, f.cloud_url_org, fd.file_desc, fd.file_keywords, f.file_name, f.file_size, f.hashtag, fo.folder_name, fo.folder_of_user, fo.folder_owner, f.in_trash, f.file_upc_number, f.expiry_date
			<!--- Get aliases --->
			UNION ALL
			SELECT /* #cachetoken#docSearchAlias */ f.file_id id, f.file_name filename, ct.folder_id_r, '' as groupid,
			f.file_extension ext, f.file_name_org filename_org, f.file_type as kind, f.is_available,
			f.file_create_time date_create, f.file_change_date date_change, f.link_kind, f.link_path_url,
			f.path_to_asset, f.cloud_url, f.cloud_url_org, f.in_trash, fd.file_desc description, fd.file_keywords keywords,
			'0' as vwidth, '0' as vheight,  '1' isalias,
			'0' as theformat, f.file_name filename_forsort, cast(f.file_size as decimal(12,0)) size, f.hashtag,
			fo.folder_name,
			'' as labels,
			'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace,f.expiry_date expiry_date_actual,
			<cfif arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator AND arguments.thestruct.razuna.session.customaccess EQ "">
				'X' as permfolder
			<cfelseif arguments.thestruct.razuna.session.customaccess NEQ "">
				'#arguments.thestruct.razuna.session.customaccess#' as permfolder
			<cfelse>
				'R' as permfolder
			</cfif>
			,
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">f.file_id + '-doc'<cfelse>concat(f.file_id,'-doc')</cfif> as listid
			<!--- custom metadata fields to show --->
			<cfif arguments.thestruct.cs.images_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.videos_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.files_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
					,<cfif m CONTAINS "keywords" OR m CONTAINS "description">fd
					<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number" OR m CONTAINS "expiry_date">f
					<cfelse>x
					</cfif>.#m#
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.audios_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
					,'' AS #listlast(m," ")#
				</cfloop>
			</cfif>
			FROM #arguments.thestruct.razuna.session.hostdbprefix#files f
			INNER JOIN ct_aliases ct ON f.file_id = ct.asset_id_r
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON fo.folder_id = ct.folder_id_r AND f.host_id = fo.host_id
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#files_desc fd ON f.file_id = fd.file_id_r AND fd.lang_id_r = <cfqueryparam value="#arguments.thestruct.razuna.session.thelangid#" cfsqltype="cf_sql_numeric"> AND f.host_id = fd.host_id
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#files_xmp x ON x.asset_id_r = f.file_id AND f.host_id = x.host_id
			WHERE f.file_id IN (<cfif arguments.qry_idstype.categorytree EQ "">'0'<cfelse>'0'<cfloop query="arguments.qry_idstype">,'#categorytree#'</cfloop></cfif>)
			<!--- Only if we have a folder id that is not 0 --->
			<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
				AND ct.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
			</cfif>
			AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND ct.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND f.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
			ELSE 1 END  = 1
			GROUP BY f.file_id, f.file_name, ct.folder_id_r, f.file_extension, f.file_name_org, f.file_type, f.is_available, f.file_create_time, f.file_change_date, f.link_kind, f.link_path_url, f.path_to_asset, f.cloud_url, f.cloud_url_org, fd.file_desc, fd.file_keywords, f.file_name, f.file_size, f.hashtag, fo.folder_name, fo.folder_of_user, fo.folder_owner, f.in_trash, f.file_upc_number, f.expiry_date

			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				) sorted_inline_view
				)
				select *
				FROM myresult
				WHERE kind IS NOT NULL
				<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
					AND permfolder IS NOT NULL
				</cfif>
				<!---
				<cfif structKeyExists(arguments.thestruct,'avoidpagination') AND arguments.thestruct.avoidpagination EQ "False">
					AND RowNum >
						CASE WHEN
							(
								SELECT count(RowNum) FROM myresult
								<cfif arguments.thestruct.thetype NEQ "all" >
									where kind='#arguments.thestruct.thetype#'
								</cfif>
							) > #arguments.thestruct.mysqloffset#

							THEN #arguments.thestruct.mysqloffset#
							ELSE 0
							END
					AND
					RowNum <=
						CASE WHEN
							(
								SELECT count(RowNum) FROM myresult
								<cfif arguments.thestruct.thetype NEQ "all" >
									where kind='#arguments.thestruct.thetype#'
								</cfif>
							) > #arguments.thestruct.mysqloffset#

							THEN #arguments.thestruct.mysqloffset+arguments.thestruct.razuna.session.rowmaxpage#
							ELSE #arguments.thestruct.razuna.session.rowmaxpage#
							END
				</cfif>
				--->
			<!--- MySql OR H2 --->
			<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">
				) as t
				WHERE kind IS NOT NULL
				<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
					AND permfolder IS NOT NULL
				</cfif>
				ORDER BY #arguments.thestruct.sortby#
			</cfif>

		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Search for Files --->
	<cffunction name="_audSearch" returntype="query" access="private">
		<cfargument name="thestruct" type="struct">
		<cfargument name="qry_idstype" type="query">
		<!--- Param --->
		<cfset var qry = "" />
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="audios", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			<!--- MSSQL --->
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				with myresult as (
					SELECT ROW_NUMBER() OVER ( ORDER BY <cfif arguments.thestruct.sortby NEQ 'filename_forsort'>#arguments.thestruct.sortby#,filename_forsort<cfelse>#arguments.thestruct.sortby#</cfif> ) AS RowNum,sorted_inline_view.* FROM (
			<cfelse>
				SELECT * FROM (
			</cfif>
				SELECT /* #cachetoken#audSearch */ a.aud_id id, a.aud_name filename, a.folder_id_r, a.aud_group groupid,
				a.aud_extension ext, a.aud_name_org filename_org, 'aud' as kind, a.is_available,
				a.aud_create_time date_create, a.aud_change_date date_change, a.link_kind, a.link_path_url,
				a.path_to_asset, a.cloud_url, a.cloud_url_org, a.in_trash, aut.aud_description description, aut.aud_keywords keywords, '0' as vwidth, '0' as vheight,  '0' isalias,
				(
					SELECT so.asset_format
					FROM #arguments.thestruct.razuna.session.hostdbprefix#share_options so
					WHERE a.aud_id = so.group_asset_id
					AND so.folder_id_r = a.folder_id_r
					AND so.asset_type = 'aud'
					AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				) AS theformat,
				a.aud_name filename_forsort,
				cast(a.aud_size as decimal(12,0)) size,
				a.hashtag,
				fo.folder_name,
				'' as labels,
				'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace,CASE WHEN NOT (a.aud_group is null OR a.aud_group='') THEN (SELECT expiry_date FROM #arguments.thestruct.razuna.session.hostdbprefix#audios WHERE aud_id=a.aud_group) ELSE a.expiry_date END  expiry_date_actual,
				<cfif arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator AND arguments.thestruct.razuna.session.customaccess EQ "">
					'X' as permfolder
				<cfelseif arguments.thestruct.razuna.session.customaccess NEQ "">
					'#arguments.thestruct.razuna.session.customaccess#' as permfolder
				<cfelse>
					'R' as permfolder
				</cfif>
				,
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">a.aud_id + '-aud'<cfelse>concat(a.aud_id,'-aud')</cfif> as listid
				<!--- custom metadata fields to show --->
				<cfif arguments.thestruct.cs.images_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.videos_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.files_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.audios_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
						,<cfif m CONTAINS "keywords" OR m CONTAINS "description">aut
						<cfelse>a
						</cfif>.#m#
					</cfloop>
				</cfif>
				FROM #arguments.thestruct.razuna.session.hostdbprefix#audios a
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#audios_text aut ON aut.aud_id_r = a.aud_id AND aut.lang_id_r = <cfqueryparam value="#arguments.thestruct.razuna.session.thelangid#" cfsqltype="cf_sql_numeric"> AND a.host_id = aut.host_id
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON fo.folder_id = a.folder_id_r AND a.host_id = fo.host_id
				WHERE a.aud_id IN (<cfif arguments.qry_idstype.categorytree EQ "">'0'<cfelse>'0'<cfloop query="arguments.qry_idstype">,'#categorytree#'</cfloop></cfif>)
				<!--- Only if we have a folder id that is not 0 --->
				<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
					AND a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
				</cfif>
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
				AND CASE
				<!--- Check if admin user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
				<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND a.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
				<!--- If rendition then look at expiry_date for original asset --->
				WHEN NOT (a.aud_group is null OR a.aud_group='')
				 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND a.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #arguments.thestruct.razuna.session.hostdbprefix#audios WHERE aud_id = a.aud_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
				ELSE 1 END  = 1
				 GROUP BY a.aud_id, a.aud_name, a.folder_id_r, a.aud_extension, a.aud_name_org, a.is_available, a.aud_create_time, a.aud_change_date, a.link_kind, a.link_path_url, a.path_to_asset, a.cloud_url, a.cloud_url_org, aut.aud_description, aut.aud_keywords, a.aud_size, a.hashtag, fo.folder_name, a.aud_group, fo.folder_of_user, fo.folder_owner, a.in_trash, a.aud_upc_number, a.expiry_date
			<!--- Get aliases --->
			UNION ALL
			SELECT /* #cachetoken#audSearchAlias */ a.aud_id id, a.aud_name filename, ct.folder_id_r, a.aud_group groupid,
				a.aud_extension ext, a.aud_name_org filename_org, 'aud' as kind, a.is_available,
				a.aud_create_time date_create, a.aud_change_date date_change, a.link_kind, a.link_path_url,
				a.path_to_asset, a.cloud_url, a.cloud_url_org, a.in_trash, aut.aud_description description, aut.aud_keywords keywords, '0' as vwidth, '0' as vheight,  '1' isalias,
				(
					SELECT so.asset_format
					FROM #arguments.thestruct.razuna.session.hostdbprefix#share_options so
					WHERE a.aud_id = so.group_asset_id
					AND so.folder_id_r = max(a.folder_id_r)
					AND so.asset_type = 'aud'
					AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				) AS theformat,
				a.aud_name filename_forsort,
				cast(a.aud_size as decimal(12,0)) size,
				a.hashtag,
				fo.folder_name,
				'' as labels,
				'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace,CASE WHEN NOT (a.aud_group is null OR a.aud_group='') THEN (SELECT expiry_date FROM #arguments.thestruct.razuna.session.hostdbprefix#audios WHERE aud_id=a.aud_group) ELSE a.expiry_date END  expiry_date_actual,
				<cfif arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator AND arguments.thestruct.razuna.session.customaccess EQ "">
					'X' as permfolder
				<cfelseif arguments.thestruct.razuna.session.customaccess NEQ "">
					'#arguments.thestruct.razuna.session.customaccess#' as permfolder
				<cfelse>
					'R' as permfolder
				</cfif>
				,
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">a.aud_id + '-aud'<cfelse>concat(a.aud_id,'-aud')</cfif> as listid
				<!--- custom metadata fields to show --->
				<cfif arguments.thestruct.cs.images_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.videos_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.files_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
						,'' AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.audios_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
						,<cfif m CONTAINS "keywords" OR m CONTAINS "description">aut
						<cfelse>a
						</cfif>.#m#
					</cfloop>
				</cfif>
				FROM #arguments.thestruct.razuna.session.hostdbprefix#audios a
				INNER JOIN ct_aliases ct ON a.aud_id = ct.asset_id_r
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#audios_text aut ON aut.aud_id_r = a.aud_id AND aut.lang_id_r = <cfqueryparam value="#arguments.thestruct.razuna.session.thelangid#" cfsqltype="cf_sql_numeric"> AND a.host_id = aut.host_id
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON fo.folder_id = ct.folder_id_r AND a.host_id = fo.host_id
				WHERE a.aud_id IN (<cfif arguments.qry_idstype.categorytree EQ "">'0'<cfelse>'0'<cfloop query="arguments.qry_idstype">,'#categorytree#'</cfloop></cfif>)
				<!--- Only if we have a folder id that is not 0 --->
				<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
					AND ct.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
				</cfif>
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
				AND CASE
				<!--- Check if admin user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
				<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND ct.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
				<!--- If rendition then look at expiry_date for original asset --->
				WHEN NOT (a.aud_group is null OR a.aud_group='')
				 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND ct.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #arguments.thestruct.razuna.session.hostdbprefix#audios WHERE aud_id = a.aud_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
				ELSE 1 END  = 1
				GROUP BY a.aud_id, a.aud_name, ct.folder_id_r, a.aud_extension, a.aud_name_org, a.is_available, a.aud_create_time, a.aud_change_date, a.link_kind, a.link_path_url, a.path_to_asset, a.cloud_url, a.cloud_url_org, aut.aud_description, aut.aud_keywords, a.aud_size, a.hashtag, fo.folder_name, a.aud_group, fo.folder_of_user, fo.folder_owner, a.in_trash, a.aud_upc_number, a.expiry_date

			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				) sorted_inline_view
				)
				select *
				FROM myresult
				WHERE kind IS NOT NULL
				<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
					AND permfolder IS NOT NULL
				</cfif>
			<!--- MySql OR H2 --->
			<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">
				) as t
				WHERE kind IS NOT NULL
				<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
					AND permfolder IS NOT NULL
				</cfif>
				ORDER BY #arguments.thestruct.sortby#
			</cfif>

		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Call Search API --->
	<cffunction name="search_api" access="public" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<cfparam name="arguments.thestruct.razuna.session.search.edit_ids" default = "0">
		<!--- Param --->
		<cfset var qry_search = structNew()>
		<!--- Set vars for API --->
		<cfset arguments.thestruct.razuna.application.api.thedatabase = arguments.thestruct.razuna.application.thedatabase>
		<cfset arguments.thestruct.razuna.application.api.dsn = arguments.thestruct.razuna.application.datasource>
		<cfset arguments.thestruct.razuna.application.api.setid = arguments.thestruct.razuna.application.setid>
		<cfset arguments.thestruct.razuna.application.api.storage = arguments.thestruct.razuna.application.storage>
		<!--- Params --->
		<cfparam name="arguments.thestruct.show" default="all">
		<cfparam name="arguments.thestruct.doctype" default="">
		<cfparam name="arguments.thestruct.datechange" default="">
		<cfparam name="arguments.thestruct.folderid" default="">
		<cfparam name="arguments.thestruct.datecreateparam" default="">
		<cfparam name="arguments.thestruct.datecreatestart" default="">
		<cfparam name="arguments.thestruct.datecreatestop" default="">
		<cfparam name="arguments.thestruct.datechangeparam" default="">
		<cfparam name="arguments.thestruct.datechangestart" default="">
		<cfparam name="arguments.thestruct.datechangestop" default="">
		<cfparam name="arguments.thestruct.sortby" default="name">
		<cfparam name="arguments.thestruct.ui" default="false">
		<cfparam name="arguments.thestruct.cs" default="">
		<!--- Fire of search --->
		<cfinvoke component="global.api2.search" method="searchassets" returnvariable="qry_search.qall">
			<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
			<cfinvokeargument name="searchfor" value="#arguments.thestruct.searchfor#">
			<cfinvokeargument name="show" value="#arguments.thestruct.show#">
			<cfinvokeargument name="doctype" value="#arguments.thestruct.doctype#">
			<cfinvokeargument name="datechange" value="#arguments.thestruct.datechange#">
			<cfinvokeargument name="folderid" value="#arguments.thestruct.folderid#">
			<cfinvokeargument name="datecreateparam" value="#arguments.thestruct.datecreateparam#">
			<cfinvokeargument name="datecreatestart" value="#arguments.thestruct.datecreatestart#">
			<cfinvokeargument name="datecreatestop" value="#arguments.thestruct.datecreatestop#">
			<cfinvokeargument name="datechangeparam" value="#arguments.thestruct.datechangeparam#">
			<cfinvokeargument name="datechangestart" value="#arguments.thestruct.datechangestart#">
			<cfinvokeargument name="datechangestop" value="#arguments.thestruct.datechangestop#">
			<cfinvokeargument name="sortby" value="#arguments.thestruct.sortby#">
			<cfinvokeargument name="ui" value="#arguments.thestruct.ui#">
			<cfinvokeargument name="cs" value="#arguments.thestruct.cs#">
		</cfinvoke>
		<!--- Return --->
		<cfreturn qry_search>
	</cffunction>

	<!--- RAZ-2820 Search UPC --->
	<cffunction name="search_upc" access="public" output="false">
		<cfargument name="thestruct" type="struct" required="true">

		<cfset arguments.thestruct.razuna.session.search.searchupc = true>
		<cfset arguments.thestruct.searchupc = true>

		<cfset var _search_text = "">

		<!--- Create search criteria --->
		<cfloop list="#arguments.thestruct.search_upc#" index="single_upc_string">
			<cfset _search_text = _search_text EQ "" ? '' : _search_text & " OR ">
			<!--- <cfset _search_text = _search_text & "filename:(#single_upc_string#*) OR filename_reverse:(#Reverse(single_upc_string)#*) OR upc:(#single_upc_string#*) OR upc_reverse:(#Reverse(single_upc_string)#*)"> --->
			<cfset _search_text = _search_text & "filename:(*#single_upc_string#*) upc:(*#single_upc_string#*)">
		</cfloop>

		<cfset arguments.thestruct.searchtext = _search_text>

		<!--- Call search --->
		<cfset var qry = newSearch(thestruct=arguments.thestruct)>

		<!--- Qry Return --->
		<cfreturn qry>
	</cffunction>

	<cffunction name="search_combine_upc">
		<cfargument name="thestruct" type="struct">
		<cfset var qry = "">
		<!--- Trim UPC --->
		<cfset arguments.thestruct.search_upc = ListItemtrim(arguments.thestruct.search_upc, ",")>
		<!--- Get the all asset results.  --->
		<cfinvoke method="search_upc" thestruct="#arguments.thestruct#" returnvariable="qry">
		<cfif structkeyexists(arguments.thestruct,"offset")>
			<cfset arguments.thestruct.razuna.session.offset = arguments.thestruct.offset>
		</cfif>
		<!--- Set the session for offset correctly if the total count of assets in lower then the total rowmaxpage --->
		<cfif arguments.thestruct.razuna.session.search.total_records LTE arguments.thestruct.razuna.session.rowmaxpage>
			<cfset arguments.thestruct.razuna.session.offset = 0>
		</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>


	<!--- Get all ids --->
	<cffunction name="getAllIdsMain" cachedwithin="1" region="razcache">
		<cfargument name="thestruct" type="struct" required="true">
		<cfargument name="searchupc" type="string">
		<cfargument name="searchtext" type="string">
		<cfargument name="searchtype" type="string">
		<cfargument name="searchrenditions" type="string">
		<cfargument name="searchfolderid" type="string">
		<cfargument name="hostid" type="numeric">

		<!--- Var --->
		<cfset var ids = "0,">

		<!--- If UPC search --->
		<cfif arguments.searchupc EQ "true">
			<cfset var _func = "getAllIdsUpc">
		<cfelse>
			<cfset var _func = "getAllIds">
		</cfif>

		<cfinvoke component="search" method="#_func#" thestruct="#arguments.thestruct#" searchupc="#arguments.searchupc#" searchtext="#arguments.searchtext#" searchtype="#arguments.searchtype#" searchrenditions="#arguments.searchrenditions#" searchfolderid="#arguments.searchfolderid#" hostid="#arguments.hostid#" returnvariable="ids">

		<cfreturn ids>
	</cffunction>

	<!--- Get all ids if search is all --->
	<cffunction name="getAllIds" cachedwithin="1" region="razcache">
		<cfargument name="thestruct" type="struct" required="true">
		<cfargument name="searchtext" type="string">
		<cfargument name="searchtype" type="string">
		<cfargument name="searchrenditions" type="string">
		<cfargument name="searchfolderid" type="string">
		<cfargument name="hostid" type="numeric">
		<!--- Var --->
		<cfset var qry_lucene ="">
		<cfset var _ids ="0,">
		<!--- Get all records --->
		<cfinvoke component="lucene" method="search" criteria="#arguments.searchtext#" category="#arguments.searchtype#" hostid="#arguments.hostid#" startrow="0" maxrows="0" search_type="" search_rendition="#arguments.searchrenditions#" folderid="#arguments.searchfolderid#" returnvariable="qry_lucene" thestruct="#arguments.thestruct#">
		<!--- Loop over results --->
		<cfloop query="qry_lucene">
			<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" thestruct="#arguments.thestruct#" folder_id="#folder#" />
			<!--- Get trash or not --->
			<!--- Store only file_ids where folder access is not R --->
			<cfif theaccess NEQ "R" AND theaccess NEQ "n">
				<cfset _ids = _ids & full_id & ",">
			</cfif>
		</cfloop>
		<!--- Return --->
		<cfreturn _ids>
	</cffunction>

	<!--- Get all ids if search is all --->
	<cffunction name="getAllIdsUpc" cachedwithin="1" region="razcache">
		<cfargument name="thestruct" type="struct" required="true">
		<cfargument name="searchtext" type="string">
		<cfargument name="searchtype" type="string">
		<cfargument name="searchrenditions" type="string">
		<cfargument name="searchfolderid" type="string">
		<cfargument name="hostid" type="numeric">
		<!--- <cfset consoleoutput(true, true)>
		<cfset console(sessions)> --->
		<!--- Var --->
		<cfset var qry_lucene ="">
		<cfset var _ids ="0,">
		<cfset var _qry_img = "">
		<cfset var _qry_vid = "">
		<cfset var _qry_aud = "">
		<cfset var _qry_doc = "">
		<!--- Get the cachetoken for here --->
		<cfset var _cachetoken = getcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Get all records --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="_qry_img" cachedWithin="1" region="razcache">
			SELECT /* #_cachetoken#search_upc_files_img */ folder_id_r, <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">img_id + '-img'<cfelse>concat(img_id,'-img')</cfif> as listid
			FROM #arguments.thestruct.razuna.session.hostdbprefix#images
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND (
				<cfset var upcListLen = listlen(arguments.searchtext)>
				<cfset var currentListPos = 1>
				<cfloop list="#arguments.searchtext#" index="single_upc_string">
					img_filename LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
					OR
					img_upc_number LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
					<cfif currentListPos neq upcListLen> OR </cfif>
					<cfset currentListPos = currentListPos+1>
				</cfloop>
			)
			<!--- Filter renditions --->
			<cfif arguments.searchrenditions EQ "t">
				AND ( img_group IS NULL OR img_group = '' )
			</cfif>
		</cfquery>
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="_qry_vid" cachedWithin="1" region="razcache">
			SELECT /* #_cachetoken#search_upc_files_vid */ folder_id_r, <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">vid_id + '-vid'<cfelse>concat(vid_id,'-vid')</cfif> as listid
			FROM #arguments.thestruct.razuna.session.hostdbprefix#videos
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND (
				<cfset var upcListLen = listlen(arguments.searchtext)>
				<cfset var currentListPos = 1>
				<cfloop list="#arguments.searchtext#" index="single_upc_string">
					vid_filename LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
					OR
					vid_upc_number LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
					<cfif currentListPos neq upcListLen> OR </cfif>
					<cfset currentListPos = currentListPos+1>
				</cfloop>
			)
			<!--- Filter renditions --->
			<cfif arguments.searchrenditions EQ "t">
				AND ( vid_group IS NULL OR vid_group = '' )
			</cfif>
		</cfquery>
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="_qry_aud" cachedWithin="1" region="razcache">
			SELECT /* #_cachetoken#search_upc_files_aud */ folder_id_r, <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">aud_id + '-aud'<cfelse>concat(aud_id,'-aud')</cfif> as listid
			FROM #arguments.thestruct.razuna.session.hostdbprefix#audios
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND (
				<cfset var upcListLen = listlen(arguments.searchtext)>
				<cfset var currentListPos = 1>
				<cfloop list="#arguments.searchtext#" index="single_upc_string">
					aud_name LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
					OR
					aud_upc_number LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
					<cfif currentListPos neq upcListLen> OR </cfif>
					<cfset currentListPos = currentListPos+1>
				</cfloop>
			)
			<!--- Filter renditions --->
			<cfif arguments.searchrenditions EQ "t">
				AND ( aud_group IS NULL OR aud_group = '' )
			</cfif>
		</cfquery>
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="_qry_doc" cachedWithin="1" region="razcache">
			SELECT /* #_cachetoken#search_upc_files_doc */ folder_id_r, <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">file_id + '-doc'<cfelse>concat(file_id,'-doc')</cfif> as listid
			FROM #arguments.thestruct.razuna.session.hostdbprefix#files
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND (
				<cfset var upcListLen = listlen(arguments.searchtext)>
				<cfset var currentListPos = 1>
				<cfloop list="#arguments.searchtext#" index="single_upc_string">
					file_name LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
					OR
					file_upc_number LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
					<cfif currentListPos neq upcListLen> OR </cfif>
					<cfset currentListPos = currentListPos+1>
				</cfloop>
			)
		</cfquery>
		<cfquery dbtype="query" name="qry_lucene">
			SELECT * FROM _qry_img
			UNION
			SELECT * FROM _qry_vid
			UNION
			SELECT * FROM _qry_doc
			UNION
			SELECT * FROM _qry_aud
		</cfquery>
		<!--- Loop over results --->
		<cfloop query="qry_lucene">
			<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" thestruct="#arguments.thestruct#" folder_id="#folder_id_r#" />
			<!--- Store only file_ids where folder access is not R --->
			<cfif theaccess NEQ "R" AND theaccess NEQ "n">
				<cfset _ids = _ids & listid & ",">
			</cfif>
		</cfloop>
		<!--- <cfset consoleoutput(true, true)>
		<cfset console("getAllIdsUpc RESULT: #_ids#")> --->

		<!--- Return --->
		<cfreturn _ids>
	</cffunction>

</cfcomponent>
