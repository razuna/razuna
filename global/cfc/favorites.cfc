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

<!--- PUT FILE OR FOLDER INTO FAVORITES --->
<cffunction name="tofavorites" output="false">
	<cfargument name="thestruct" type="struct">
	<cfloop index="thenr" delimiters="," list="#arguments.thestruct.favid#">
		<!--- If we come from a overview we have numbers with the type --->
		<cfif thenr CONTAINS "-">
			<cfset favid = listfirst(thenr,"-")>
			<cfset favkind = listlast(thenr,"-")>
		<cfelse>
			<cfset favid = thenr>
			<cfset favkind = arguments.thestruct.favkind>
		</cfif>
		<!--- Add the favorites to the user table but first check that the same one does not exist --->
		<cfquery datasource="#variables.dsn#" name="here">
		SELECT fav_id
		FROM #session.hostdbprefix#users_favorites
		WHERE fav_id = <cfqueryparam value="#favid#" cfsqltype="CF_SQL_VARCHAR">
		AND user_id_r = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">
		AND fav_kind = <cfqueryparam value="#favkind#" cfsqltype="cf_sql_varchar">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- no record found insert the fav id --->
		<cfif here.recordcount EQ 0>
			<!--- get the highest order and add one --->
			<cfquery datasource="#variables.dsn#" name="theorder">
			SELECT max(fav_order) as fav_order 
			FROM #session.hostdbprefix#users_favorites
			WHERE user_id_r = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfif theorder.fav_order EQ "">
				<cfset var neworder = 1>
			<cfelse>
				<cfset var neworder = theorder.fav_order + 1>
			</cfif>
			<!--- do the insert --->
			<cfquery datasource="#variables.dsn#">
			INSERT INTO #session.hostdbprefix#users_favorites
			(user_id_r, fav_type, fav_id, fav_kind, fav_order, host_id, rec_uuid)
			VALUES(
			<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.thestruct.favtype#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#favid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#favkind#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#neworder#" cfsqltype="cf_sql_numeric">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- LIST FAVORITES FOR THIS USER --->
<cffunction name="readfavorites" output="false">
	<!--- select the favorites --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#readfavorites */ f.fav_id cart_product_id, f.fav_type, f.fav_kind, f.fav_order,
		CASE
			WHEN f.fav_type = 'file'
				THEN
					CASE 
						WHEN f.fav_kind = 'doc' 
							THEN (
								SELECT file_name 
								FROM #session.hostdbprefix#files 
								WHERE file_id = f.fav_id
								AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
								)
						WHEN f.fav_kind = 'img'
							THEN (
								SELECT img_filename 
								FROM #session.hostdbprefix#images 
								WHERE img_id = f.fav_id
								AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
								)
						WHEN f.fav_kind = 'vid'
							THEN (
								SELECT vid_filename 
								FROM #session.hostdbprefix#videos 
								WHERE vid_id = f.fav_id
								AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
								)
						WHEN f.fav_kind = 'aud'
							THEN (
								SELECT aud_name 
								FROM #session.hostdbprefix#audios 
								WHERE aud_id = f.fav_id
								AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
								)
					END
			WHEN f.fav_type = 'folder'
				THEN (
						SELECT folder_name
						FROM #session.hostdbprefix#folders
						WHERE folder_id = f.fav_id
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
		END as thename,
		CASE
			WHEN f.fav_kind = 'doc' 
				THEN (
					SELECT file_extension
					FROM #session.hostdbprefix#files 
					WHERE file_id = f.fav_id
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
			WHEN f.fav_kind = 'aud' 
				THEN (
					SELECT aud_extension
					FROM #session.hostdbprefix#audios 
					WHERE aud_id = f.fav_id
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
		END as theextension
	FROM #session.hostdbprefix#users_favorites f
	WHERE f.user_id_r = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY f.fav_type DESC
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- REMOVE FAVORITE --->
<cffunction name="removeitem" output="false">
	<cfargument name="favid" default="" required="yes" type="string">
	<!--- Remove --->
	<cfquery datasource="#variables.dsn#">
	DELETE FROM #session.hostdbprefix#users_favorites
	WHERE user_id_r = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">
	AND fav_id = <cfqueryparam value="#arguments.favid#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

</cfcomponent>