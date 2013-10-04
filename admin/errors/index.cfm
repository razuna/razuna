<!DOCTYPE html>
<html lang="en">
<meta charset="utf-8" />
<head>
	<link rel="stylesheet" type="text/css" href="js/datatables/css/jquery.dataTables.css">
	<link rel="stylesheet" type="text/css" href="js/datatables/jquery-ui.custom/css/jquery-ui.custom.min.css">
	<link rel="stylesheet" type="text/css" href="css/styles.css">
	<style type="text/css" title="currentStyle"> 
		@import "js/datatables/css/demo_table_jui.css";	
    </style>

	<script src="js/datatables/js/jquery.js" type="text/javascript"></script>
	<script src="js/datatables/js/jquery.dataTables.min.js" type="text/javascript"></script>
	<script>	 
    $(document).ready(function() {		  
        oTable = $('table').dataTable({	
            "bJQueryUI": true,
            "sPaginationType": "full_numbers",
            "iDisplayLength":10,
            "asStripeClasses": [],
            "aaSorting": [[0,'desc']],
            "asStripeClasses": [ 'strip1', 'strip2']
        });	
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
<cfquery datasource="#session.datasource#" name="dberrors">
	select id, err_date, host_id
	from #session.shard_group#errors
</cfquery> 

<!--- Output errors logged in database --->
<div style="width:49%;float:left">
<h2 style="color:#5f4d28">Errors Logged in Database</h2>
<form method="post" onsubmit="return confirm('Do you really want to delete these errors? This process is undoable!');">
	<input type="submit" name="deldberr" value="Delete All Errors" class="ui-state-default ui-corner-tr ui-corner-tl">
</form>
<table class="display">
	<thead>
		<tr><th>ID</th><th>Timestamp</th><th>Error</th><th>HostID</th></tr>
	</thead>
	<tbody style="color:#5f4d28">
		<cfoutput query="dberrors">
		<tr>
			<td>#id#</td>
			<td>#dateformat(err_date,"mm/dd/yyyy")# #timeformat(err_date,"hh:mm tt")#</td>
			<td><a href="dsp_viewdberr.cfm?id=#id#" target="_blank">View Error</a></td>	
			<td>#host_id#</td>
		</tr>
		</cfoutput>
	</tbody>
</table>
</div>

<!--- Get list of error logs in Bluedragon --->
<cfdirectory action="list" directory="#expandpath(session.BDlogdir)#" name="BDloglist" filter="*.html" sort="desc"/>
<div style="width:49%;float:right;">
<h2 style="color:#5f4d28">Errors logged in Bluedragon</h2>
<form method="post" onsubmit="return confirm('Do you really want to delete these errors? This process is undoable!');">
	<input type="submit" name="delbderr" value="Delete All Errors" class="ui-state-default ui-corner-tr ui-corner-tl">
</form>
<!--- Output errors logged in Bluedragon --->
<table class="display">
	<thead>
		<tr><th>Timestamp</th><th>Error</th></tr>
	</thead>	
	<tbody>
		<cfoutput query="BDloglist">
		<cfif name does not contain "latest"> <!--- exclude latest file as that is a duplicate --->
			<cfif not fileExists("#expandpath('./temp')#/#name#")>
				<cffile action="copy" source="#expandpath(session.BDlogdir)#/#name#" destination="#expandpath('./temp')#">
			</cfif>
			<tr>
				<td>#dateformat(datelastmodified,"mm/dd/yyyy")# #timeformat(datelastmodified,"hh:mm tt")#</td>
				<td><a href="temp/#name#" target="_blank">View Error</a></td>
			</tr>
		</cfif>		
		</cfoutput>
	</tbody>
</table>
</div>

</body>
</html>
