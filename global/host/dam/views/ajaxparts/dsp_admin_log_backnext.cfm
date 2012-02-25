<cfparam default="" name="attributes.logaction">
<cfparam default="0" name="attributes.id">
<cfif attributes.id EQ 0>
	<cfset thediv = "log_show">
	<cfset theact = attributes.logswhat>
<cfelse>
	<cfset thediv = "history">
	<cfset theact = "log_history">
</cfif>
<cfoutput>
	<tr>
		<td colspan="6" nowrap="true">
			<div style="float:left;">Total: #qry_log.thetotal# | <a href="##" onclick="loadcontent('#thediv#','#myself#c.#theact#_remove&id=#attributes.id#');return false;">#defaultsObj.trans("delete_log")#</a></div>
			<div style="float:right;">
			<cfif session.offset_log GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.offset_log - 1>
				<a href="##" onclick="loadcontent('#thediv#','#myself#c.#theact#&offset_log=#newoffset#&logaction=#attributes.logaction#&id=#attributes.id#');return false;"><<< #defaultsObj.trans("back")#</a>
			</cfif>
			<cfset showoffset = session.offset_log * session.rowmaxpage_log>
			<cfset shownextrecord = (session.offset_log + 1) * session.rowmaxpage_log>
			<cfif qry_log.thetotal GT session.rowmaxpage_log>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_log.thetotal GT session.rowmaxpage_log AND NOT shownextrecord GTE qry_log.thetotal> | 
				<!--- For Next --->
				<cfset newoffset = session.offset_log + 1>
				<a href="##" onclick="loadcontent('#thediv#','#myself#c.#theact#&offset_log=#newoffset#&logaction=#attributes.logaction#&id=#attributes.id#');return false;">#defaultsObj.trans("next")# >>></a>
			</cfif>
			</div>
		</td>
	</tr>
</cfoutput>