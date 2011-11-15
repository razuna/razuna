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
<cfcomponent hint="Translation table functionality" output="false" extends="extQueryCaching">

<!--- GET THE TRANSLATION --->
<cffunction hint="Get the Translation" name="trans" output="false" access="public" returntype="string">
	<cfargument name="trans_id" required="yes" type="string">
	<cfargument name="lang" default="#Request.cl#" required="no" type="string">
	<!--- init local vars --->
	<cfset var qTrans = 0>
	<cfquery datasource="#Variables.dsn#" name="qTrans">
		SELECT TRIM(trans_text) AS trans_text
		FROM #session.hostdbprefix#translations
		WHERE lower(trans_id) = <cfqueryparam value="#lcase(arguments.trans_id)#" cfsqltype="cf_sql_varchar">
		and lang_id_r = <cfqueryparam value="#Arguments.lang#" cfsqltype="cf_sql_numeric">
	</cfquery>
	<cfreturn qTrans.trans_text>
</cffunction>

</cfcomponent>