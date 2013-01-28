<!---
	$Id: _requests_all.cfm 2204 2012-07-23 15:27:58Z tony $
	--->
<cfset activeSessions	= DebuggerGetSessions()>

<cfoutput query="activeSessions">
<table class="queries">
	<tbody>
	
		<tr>
			<td width="50px" align="center">#id#</td>
			<td width="16px" align="center"><a sessionid="#id#" href="javascript:void(null);" class="<cfif isTerm>stopping<cfelse>kill</cfif>" title="<cfif isTerm>waiting to die<cfelse>kill this request</cfif>">kill</a></td>
			<td>#uri#<div class="file filepathsize j-template-file" title="template file" f="#f#" l="#cl#">#f#</div></td>
			<td width="65px">#ip#</td>
			<td width="75px" style="text-align: right;" nowrap>#NumberFormat(time)#<div class="file"><strong>ms</strong></div></td>
			<td width="40px" style="text-align: right;" nowrap>#NumberFormat(bytes)#<div class="file"><strong>bytes</strong></div></td>
			<td width="85px" style="text-align: right;" nowrap>#ct#<div class="file">Line #cl#</div></td>
		 	<td width="16px" align="center"><a title="inspect" class="inspect-show j-inspect-show" href="javascript:void(null);" sessionid="#id#">inspect</a></td>
		</tr>
	
	</tbody>
</table>

</cfoutput>

<!---
<cfdump var="#activeSessions#">
--->