<!---
	$Id: _requests_all.cfm 2121 2012-06-22 10:29:03Z alan $
	--->
<cfset activeSessions	= DebuggerGetSessions()>

<table class="queries">
<tbody>

<cfoutput query="activeSessions">
<tr>
	<td width="20px" align="center">#id#</td>
	<td width="20px" align="center"><a sessionid="#id#" href="javascript:void(null);" class="<cfif isTerm>stopping<cfelse>kill</cfif>" title="<cfif isTerm>waiting to die<cfelse>kill this request</cfif>">kill</a></td>
	<td>#uri#<div class="file filepathsize j-template-file" title="template file" f="#f#" l="#cl#">#f#</div></td>
	<td width="1%">#ip#</td>
	<td width="1%" style="text-align: right;" nowrap>#NumberFormat(time)#<div class="file"><strong>ms</strong></div></td>
	<td width="1%" style="text-align: right;" nowrap>#NumberFormat(bytes)#<div class="file"><strong>bytes</strong></div></td>
	<td width="1%" style="text-align: right;" nowrap>#ct#<div class="file">Line #cl#</div></td>
 	<td width="20px" align="center"><a title="inspect" class="inspect-show j-inspect-show" href="javascript:void(null);" sessionid="#id#">inspect</a></td>
</tr>
</cfoutput>

</tbody>
</table>

<!---
<cfdump var="#activeSessions#">
--->