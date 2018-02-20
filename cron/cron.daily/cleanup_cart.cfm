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
<cfset consoleoutput(true)>

<!--- Get database --->
<cfquery datasource="razuna_default" name="_config">
SELECT conf_datasource, conf_database
FROM razuna_config
</cfquery>

<!--- Set time for remove --->
<cfset _removetime = DateAdd("d", -30, now())>

<!--- Remove expired assets from cart --->
<cftry>
	<cfquery datasource="#_config.conf_datasource#">
		<cfif _config.conf_database NEQ "h2">
			DELETE c FROM raz1_cart c
			LEFT JOIN raz1_images i ON c.cart_product_id = i.img_id AND cart_file_type = 'img' AND c.host_id = i.host_id
			LEFT JOIN raz1_audios a ON c.cart_product_id = a.aud_id AND cart_file_type = 'aud' AND c.host_id = a.host_id
			LEFT JOIN raz1_videos v ON c.cart_product_id = v.vid_id AND cart_file_type = 'vid' AND c.host_id = v.host_id
			LEFT JOIN raz1_files f ON c.cart_product_id = f.file_id AND cart_file_type = 'doc' AND c.host_id = f.host_id
			WHERE i.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR a.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR v.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR f.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR c.cart_change_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime#">
		<cfelse>
			DELETE FROM raz1_cart c
			WHERE EXISTS (
				SELECT 1 FROM raz1_cart cc
				LEFT JOIN raz1_images i ON cc.cart_product_id = i.img_id AND cc.cart_file_type = 'img' AND cc.host_id = i.host_id
				LEFT JOIN raz1_audios a ON cc.cart_product_id = a.aud_id AND cc.cart_file_type = 'aud' AND cc.host_id = a.host_id
				LEFT JOIN raz1_videos v ON cc.cart_product_id = v.vid_id AND cc.cart_file_type = 'vid' AND cc.host_id = v.host_id
				LEFT JOIN raz1_files f ON cc.cart_product_id = f.file_id AND cc.cart_file_type = 'doc' AND cc.host_id = f.host_id
				WHERE c.cart_product_id=cc.cart_product_id
				AND
				(
					i.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					OR a.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					OR v.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					OR f.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					OR cc.cart_change_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime#">
				)
			)
		</cfif>
	</cfquery>
	<cfcatch>
		<!--- <cfset console(cfcatch)> --->
	</cfcatch>
</cftry>
<cftry>
	<cfquery datasource="#_config.conf_datasource#">
		<cfif _config.conf_database NEQ "h2">
			DELETE c FROM raz2_cart c
			LEFT JOIN raz2_images i ON c.cart_product_id = i.img_id AND cart_file_type = 'img' AND c.host_id = i.host_id
			LEFT JOIN raz2_audios a ON c.cart_product_id = a.aud_id AND cart_file_type = 'aud' AND c.host_id = a.host_id
			LEFT JOIN raz2_videos v ON c.cart_product_id = v.vid_id AND cart_file_type = 'vid' AND c.host_id = v.host_id
			LEFT JOIN raz2_files f ON c.cart_product_id = f.file_id AND cart_file_type = 'doc' AND c.host_id = f.host_id
			WHERE i.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR a.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR v.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR f.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			OR c.cart_change_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime#">
		<cfelse>
			DELETE FROM raz2_cart c
			WHERE EXISTS (
				SELECT 1 FROM raz2_cart cc
				LEFT JOIN raz2_images i ON cc.cart_product_id = i.img_id AND cc.cart_file_type = 'img' AND cc.host_id = i.host_id
				LEFT JOIN raz2_audios a ON cc.cart_product_id = a.aud_id AND cc.cart_file_type = 'aud' AND cc.host_id = a.host_id
				LEFT JOIN raz2_videos v ON cc.cart_product_id = v.vid_id AND cc.cart_file_type = 'vid' AND cc.host_id = v.host_id
				LEFT JOIN raz2_files f ON cc.cart_product_id = f.file_id AND cc.cart_file_type = 'doc' AND cc.host_id = f.host_id
				WHERE c.cart_product_id=cc.cart_product_id
				AND
				(
					i.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					OR a.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					OR v.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					OR f.expiry_date < <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					OR cc.cart_change_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime#">
				)
			)
		</cfif>
	</cfquery>
	<cfcatch>
		<!--- <cfset console(cfcatch)> --->
	</cfcatch>
</cftry>