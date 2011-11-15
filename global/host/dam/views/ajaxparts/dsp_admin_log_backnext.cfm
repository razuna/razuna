<cfparam default="" name="attributes.logaction">
<cfoutput>
	<tr>
		<td colspan="6" nowrap="true">
			<div style="float:left;">Total: #qry_log.thetotal# | <a href="##" onclick="loadcontent('log_show','#myself#c.#attributes.logswhat#_remove');return false;">#defaultsObj.trans("delete_log")#</a></div>
			<div style="float:right;">
			<cfif attributes.offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = attributes.offset - 1>
				<a href="##" onclick="loadcontent('log_show','#myself#c.#attributes.logswhat#&offset=#newoffset#&rowmaxpage=#attributes.rowmaxpage#&logaction=#attributes.logaction#');return false;"><<< #defaultsObj.trans("back")#</a>
			</cfif>
			<cfset showoffset = attributes.offset * attributes.rowmaxpage>
			<cfset shownextrecord = (attributes.offset + 1) * attributes.rowmaxpage>
			<cfif qry_log.thetotal GT attributes.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_log.thetotal GT attributes.rowmaxpage AND NOT shownextrecord GTE qry_log.thetotal> | 
				<!--- For Next --->
				<cfset newoffset = attributes.offset + 1>
				<a href="##" onclick="loadcontent('log_show','#myself#c.#attributes.logswhat#&offset=#newoffset#&rowmaxpage=#attributes.rowmaxpage#&logaction=#attributes.logaction#');return false;">#defaultsObj.trans("next")# >>></a>
			</cfif>
			</div>
		</td>
	</tr>
</cfoutput>