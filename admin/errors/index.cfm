<!DOCTYPE html>
<html lang="en">
<title>Razuna Errors</title>
<meta charset="utf-8" />
<head>
	<link rel="stylesheet" type="text/css" href="js/datatables/css/jquery.dataTables.css">
	<link rel="stylesheet" type="text/css" href="js/datatables/jquery-ui.custom/css/jquery-ui.custom.min.css">	
	<style type="text/css" title="currentStyle">
		@import "js/datatables/css/demo_table_jui.css";	
    </style>
	<script src="js/datatables/js/jquery.js" type="text/javascript"></script>
	<script src="js/datatables/js/jquery.dataTables.min.js" type="text/javascript"></script>
	<script src="js/datatables/js/jquery.dataTables.columnFilter.js" type="text/javascript"></script>
	<script src="js/datatables/js/jquery.dataTables.editable.js" type="text/javascript"></script>
	<script src="js/datatables/js/jquery.jeditable.js" type="text/javascript"></script>
	<script src="js/datatables/js/jquery-ui.js" type="text/javascript"></script>
	<cfsavecontent variable="dt_settings">
			"bJQueryUI": true,
            "sPaginationType": "full_numbers",
            "iDisplayLength":25,
            "aaSorting": []
	</cfsavecontent>
	<script>	 
    $(document).ready(function() {		  
    	var id = -1;//simulation of id
    	oTable1 = $("#dberrtbl")
    	// Initialise datatable woth default settings
    	.dataTable({"sDom": '<"H"<"#tableOne"flr>>t<"F"p>',<cfoutput>#dt_settings#</cfoutput>})
    	// Make datatable editable and allow selection and deletion of rows. This is achieved using the datatables data manager addon
    	// http://jquery-datatables-editable.googlecode.com/svn/trunk/index.html
    	.makeEditable({
				   		sReadOnlyCellClass: "read_only",
				   		sDeleteRowButtonId: "btnDeleteErr",	
				        sDeleteHttpMethod: "GET",
						sDeleteURL: "myfunctions.cfc?method=delete_err",
						sUpdateURL: "myfunctions.cfc?method=update_err",
						oDeleteRowButtonOptions: {label: "Delete",icons: {primary:'ui-icon-trash'}},
						sAddDeleteToolbarSelector: "#tableOne"								
		})
		// Allow column level filtering in datatables using the Column Filter addon
		// http://jquery-datatables-column-filter.googlecode.com/svn/trunk/index.html
		.columnFilter();	
    
    	oTable2 = $("#bderrtbl").dataTable({"sDom": '<"H"<"#tableTwo"flr>>t<"F"p>',<cfoutput>#dt_settings#</cfoutput>})
    	.makeEditable({
				   		sReadOnlyCellClass: "read_only",
				   		sDeleteRowButtonId: "btnDeleteLog",
				        sDeleteHttpMethod: "GET",
						sDeleteURL: "myfunctions.cfc?method=delete_log",
						oDeleteRowButtonOptions: {label: "Delete",icons: {primary:'ui-icon-trash'}},
						sAddDeleteToolbarSelector: "#tableTwo"								
		});	
        $("[id*=btnDelete]").attr("style","font-size:0.9em;");//make remove button text smaller
    } );	

	</script>
</head>

<body>	
<cfset session.BDlogdir = "../../WEB-INF/bluedragon/work/temp/rtelogs">

<!--- Delete all database errors --->
<cfif isdefined("form.deldberr")>
	<cfquery datasource="#session.datasource#" name="deldberrors">
		delete from #session.shard_group#errors
	</cfquery>
</cfif>	

<!--- Delete all bluedragon errors --->
<cfif isdefined("form.delbderr")>
 	<cftry>
 	<cfdirectory action="delete" directory="#expandpath('./temp')#" recurse="true"/>
 	<cfcatch></cfcatch>
 	</cftry>
 	<cftry>
 	<cfdirectory action="delete" directory="#expandpath(session.BDlogdir)#" recurse="true"/>
 	<cfdirectory action="create" directory="#expandpath(session.BDlogdir)#"/>
 	<cfcatch></cfcatch>
 	</cftry>	
</cfif>

<!--- Create temp directory if it doesn't exist --->
<cfif not directoryExists("#expandpath('.')#/temp")>
	<cfdirectory action="create" directory="#expandpath('.')#/temp"/>
</cfif>

<!--- Get errors stored in user database --->
<cfquery datasource="#session.datasource#" name="dberrors" ><!--- cachedwithin="#CreateTimeSpan(0,0,0,10)#" --->
	select e.id, e.err_header, e.err_date, e.host_id, h.host_name
	from #session.shard_group#errors e left join hosts h
	on e.host_id = h.host_id
	order by e.id desc
</cfquery>

<!--- Output errors logged in database --->
<div>
<h2 class="inline">Errors Logged in Database</h2><br>
<span class="fineprint">Double click any cell in error column to edit and hit enter to save changes to database</span><br/>
<form method="post" onsubmit="return confirm('Do you really want to delete these errors? This process is undoable!');">
	<input type="submit" name="deldberr" id="delbderr" value="Delete All Errors" class="ui-state-default ui-corner-tr ui-corner-tl">
</form>
<table class="display" id="dberrtbl">
	<thead>
		<tr><th>ID</th><th>Timestamp</th><th>Error</th><th>HostName</th><th>HostID</th></tr>
	</thead>
	<tbody>
		<cfoutput query="dberrors">
		<tr id="#id#">
			<td class="read_only">#id#</td>
			<td class="read_only"><a href="dsp_viewdberr.cfm?id=#id#" target="_blank">#dateformat(err_date,"mm/dd/yyyy")# #timeformat(err_date,"hh:mm tt")#</a></td>
			<td>#err_header#</td>	
			<td class="read_only">#host_name#</td>
			<td class="read_only">#host_id#</td>
		</tr>
		</cfoutput>
	</tbody>
	<tfoot>
		<tr><th>ID</th><th>Timestamp</th><th>Error</th><th>HostName</th><th>HostID</th></tr>
	</tfoot>
</table>
</div>

<!--- Get list of error logs in Bluedragon --->
<cfdirectory action="list" directory="#expandpath(session.BDlogdir)#" name="BDloglist" filter="*.html" sort="datelastmodified desc"/>
<div>
<h2>Errors logged in Bluedragon</h2>
<form method="post" onsubmit="return confirm('Do you really want to delete these errors? This process is undoable!');">
	<input type="submit" name="delbderr" id="delbderr" value="Delete All Errors" class="ui-state-default ui-corner-tr ui-corner-tl">
</form>
<!--- Output errors logged in Bluedragon --->
<table class="display" id="bderrtbl">
	<thead>
		<tr><th>Timestamp</th></tr>
	</thead>	
	<tbody>
		<cfoutput query="BDloglist">
		<cfif name does not contain "latest"> <!--- exclude latest file as that is a duplicate --->
			<cfif not fileExists("#expandpath('./temp')#/#name#")>
				<cffile action="copy" source="#expandpath(session.BDlogdir)#/#name#" destination="#expandpath('./temp')#">
			</cfif>
			<tr id="#name#">
				<td class="read_only"><a href="temp/#name#" target="_blank">#dateformat(datelastmodified,"mm/dd/yyyy")# #timeformat(datelastmodified,"hh:mm tt")#</a></td>
			</tr>
		</cfif>		
		</cfoutput>
	</tbody>
</table>
</div>

</body>
</html>
