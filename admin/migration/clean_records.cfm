<cfabort>

<!---  --->
<!--- VARIABLES --->
<!---  --->

<!--- DB --->
<cfset the_db = "">

<!--- HOSTID --->
<cfset host_id = "">





<!--- --------------------------------------------------------------------------------------- --->
<!--- INTERNAL STUFF --->
<!--- --------------------------------------------------------------------------------------- --->

<!--- List of tables that need to be fetched and value to be transfered --->
<cfset fetch_tables = "raz1_additional_versions,raz1_comments,raz1_custom_fields,raz1_custom_fields_text,raz1_custom_fields_values,raz1_files,raz1_files_desc,raz1_files_xmp,raz1_folders,raz1_folders_desc,raz1_folders_groups,raz1_images,raz1_images_text,raz1_labels,raz1_share_options,raz1_users_favorites,raz1_versions,raz1_videos,raz1_videos_text,raz1_xmp">

<!--- MySQL: Drop all constraints --->
<cfquery datasource="#the_db#">
SET FOREIGN_KEY_CHECKS = 0
</cfquery>

<cfloop list="#fetch_tables#" index="table">
	<!--- MySQL: Drop all constraints --->
	<cfquery datasource="#the_db#">
	SET FOREIGN_KEY_CHECKS = 0
	</cfquery>
	<cfflush>
	<cfoutput><br />Delete #table# <br /></cfoutput>
	<!--- delete from local table --->
	<cfquery datasource="#the_db#">
	DELETE FROM #table#
	WHERE host_id = #host_id#
	</cfquery>
	<cfflush>
	<cfoutput><br />Records for hostid #host_id# in #table# are deleted!<br /><br /></cfoutput>
</cfloop>
