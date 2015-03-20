<cfsilent>

	<cfset fileQry	= DebuggerInspectFileStack( url.id )>

</cfsilent><cfinclude template="header.inc">

<style type="text/css">
.cfdump_table { cell-spacing: 2; background-color: #cccccc }.cfdump_th { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #666666 }
.cfdump_td_name  { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: black; text-align: left; padding: 3px; background-color: #e0e0e0; vertical-align: top }
.cfdump_td_value { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: black; text-align: left; padding: 3px; background-color: #ffffff; vertical-align: top }
.cfdump_table_struct { cell-spacing: 2; background-color: #336699 }.cfdump_th_struct { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #3366cc }.cfdump_td_struct  { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: black; text-align: left; padding: 3px; background-color: #99ccff; vertical-align: top }.cfdump_table_array { cell-spacing: 2; background-color: #006600 }.cfdump_th_array { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #009900 }.cfdump_td_array  { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: black; text-align: left; padding: 3px; background-color: #ccffcc; vertical-align: top }.cfdump_table_binary { cell-spacing: 2; background-color: #ff6600 }.cfdump_th_binary { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #ff9900 }.cfdump_table_object { cell-spacing: 2; background-color: #990000 }.cfdump_th_object { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #cc3300 }.cfdump_td_object  { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: black; text-align: left; padding: 3px; background-color: #ffcccc; vertical-align: top }.cfdump_table_query { cell-spacing: 2; background-color: #990066 }.cfdump_th_query { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #993399 }.cfdump_td_query  { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: black; text-align: left; padding: 3px; background-color: #ffccff; vertical-align: top }.cfdump_table_xml { cell-spacing: 2; background-color: #666666 }.cfdump_th_xml { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #999999 }.cfdump_td_xml  { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: black; text-align: left; padding: 3px; background-color: #dddddd; vertical-align: top }.cfdump_table_udf { cell-spacing: 2; background-color: #660033 }.cfdump_th_udf { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #996633 }.cfdump_td_udf  { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; font-style: italic; color: black; text-align: left; padding: 3px; background-color: #ffffff; vertical-align: top }.cfdump_table_udf_args { cell-spacing: 2; background-color: #996600 }.cfdump_th_udf_args { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; color: white; text-align: left; padding: 5px; background-color: #cc9900 }</style>

<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div id="varname" class="filename">Current File Stack</div></th>
</tr>
<cfoutput>
<cfloop array="#ArrayReverse(fileQry)#" index="file">
<tr>
	<td><pre>#file.pf#</pre></td>
</tr>
</cfloop>
</cfoutput>
<tr>
	<td><pre style="color:silver"><em>request start</em></pre></td>
</tr>
</table>

<cfinclude template="footer.inc">