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
<cfcomponent output="false" extends="authentication">

	<!--- Add to basket --->
	<cffunction name="addToBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="basket_id" required="true" type="string" />
		<cfargument name="asset_id" required="true" type="string" />
		<!--- Local vars --->
		<cfset var qry = '' />
		<cfset var responsecode = 0 />
		<!--- Set time for remove --->
		<cfset var removetime = DateAdd("h", -72, "#now()#")>
		<!--- Loop over the asset_id --->
		<cfloop list="#arguments.asset_id#" index="assetid" delimiters=",">
			<!--- Check if we already have the same id of the same basket id--->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT asset_id
			FROM api_basket
			WHERE asset_id = <cfqueryparam value="#assetid#" cfsqltype="cf_sql_varchar">
			AND basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- if not found insert --->
			<cfif qry.recordcount EQ 0>
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				INSERT INTO api_basket
				(basket_id, asset_id, date_added)
				VALUES (
					<cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#assetid#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Remove records that are older than 72 hours --->
		<cfquery datasource="#application.razuna.api.dsn#">
		DELETE FROM api_basket
		WHERE date_added < <cfqueryparam value="#removetime#" cfsqltype="cf_sql_timestamp">
		</cfquery>
		<!--- Return --->
		<cfset thexml.responsecode = 0 />
		<cfset thexml.message = "File has been added to the basket" />
		<cfreturn thexml />
	</cffunction>

	<!--- Show basket --->
	<cffunction name="showBasket" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="basket_id" required="true" type="string" />
		<!--- Local vars --->
		<cfset var qry = '' />
		<cfset var responsecode = 0 />
		<!--- Query--->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry">
		SELECT asset_id
		FROM api_basket
		WHERE basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Delete basket --->
	<cffunction name="deleteBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="basket_id" required="true" type="string" />
		<!--- Local vars --->
		<cfset var qry = '' />
		<cfset var responsecode = 0 />
		<!--- Query--->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry">
		DELETE FROM api_basket
		WHERE basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Return --->
		<cfset thexml.responsecode = 0 />
		<cfset thexml.message = "All files in your basket have been removed" />
		<cfreturn thexml />
	</cffunction>

	<!--- Delete item in basket --->
	<cffunction name="deleteItemInBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="basket_id" required="true" type="string" />
		<!--- Local vars --->
		<cfset var qry = '' />
		<cfset var responsecode = 0 />
		<!--- Loop over the asset_id --->
		<cfloop list="#arguments.asset_id#" index="assetid" delimiters=",">
			<!--- Query all asset_ids with same basket id--->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			DELETE FROM api_basket
			WHERE basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
			AND asset_id = <cfqueryparam value="#assetid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfloop>
		<!--- Return --->
		<cfset thexml.responsecode = 0 />
		<cfset thexml.message = "All files in your basket have been removed" />
		<cfreturn thexml />
	</cffunction>

	<!--- Delete item in basket --->
	<cffunction name="downloadBasket" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="basket_id" required="true" type="string" />
		<!--- Local vars --->
		<cfset var qry = ''>
		<cfset var responsecode = 0>
		<cfset var basketname = createuuid("")>
		<cfset var path = ExpandPath("../tmp/")>
		<cfset var tmpdir = GetTempDirectory() & "#basketname#">
		<!--- Create directory --->
		<cfdirectory action="create" directory="#tmpdir#" mode="775" />
		<!--- Get all files in basket --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry">
		SELECT asset_id
		FROM api_basket
		WHERE basket_id = <cfqueryparam value="#arguments.basket_id#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Loop trough the basket --->
		<cfloop query="qry">
			
		</cfloop>
		<!--- All done. Now zip up the folder --->
		<cfset var downloadname = "basket-" & basketname & ".zip">
		<cfset consoleoutput(true)>
		<cfset console("#path##downloadname#")>
		<cfset console("#tmpdir#")>

		<cfzip action="create" zipfile="#path##downloadname#" source="#tmpdir#" recurse="true" timeout="300" />
		<!--- Remove the tmp dir --->
		<cfdirectory action="delete" directory="#tmpdir#" recurse="true" />

		<!--- Return --->
		<cfset thexml.responsecode = 0 />
		<cfset thexml.message = "All files in your basket have been removed" />
		<cfreturn thexml />
	</cffunction>

</cfcomponent>