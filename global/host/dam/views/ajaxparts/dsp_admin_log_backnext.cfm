<cfparam default="" name="attributes.logaction">
<cfparam default="0" name="attributes.id">
<cfparam default="false" name="attributes.bot">
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
			<div style="float:left;">Total: #qry_log.thetotal# | <a href="##" onclick="loadcontent('#thediv#','#myself#c.#theact#_remove&id=#attributes.id#');return false;">#myFusebox.getApplicationData().defaults.trans("delete_log")#</a></div>
			<div style="float:right;">
			<cfif session.offset_log GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.offset_log - 1>
				<a href="##" onclick="loadcontent('#thediv#','#myself#c.#theact#&offset_log=#newoffset#&logaction=#attributes.logaction#&id=#attributes.id#');return false;">< #myFusebox.getApplicationData().defaults.trans("back")#</a>
			</cfif>
			<cfset showoffset = session.offset_log * session.rowmaxpage_log>
			<cfset shownextrecord = (session.offset_log + 1) * session.rowmaxpage_log>
			<cfif qry_log.thetotal GT session.rowmaxpage_log>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_log.thetotal GT session.rowmaxpage_log AND NOT shownextrecord GTE qry_log.thetotal> | 
				<!--- For Next --->
				<cfset newoffset = session.offset_log + 1>
				<a href="##" onclick="loadcontent('#thediv#','#myself#c.#theact#&offset_log=#newoffset#&logaction=#attributes.logaction#&id=#attributes.id#');return false;">#myFusebox.getApplicationData().defaults.trans("next")# ></a>
			</cfif>
			<!--- Pages --->
			<cfif attributes.bot eq "true">
				<cfif qry_log.thetotal GT session.rowmaxpage>
					<span style="padding-left:10px;">
						<cfset thepage = ceiling(qry_log.thetotal / session.rowmaxpage)>
						Page: 
							<select class="thepagelist"  onChange="loadcontent('#thediv#', $('.thepagelist :selected').val());">
							<cfloop from="1" to="#thepage#" index="i">
								<cfset loopoffset = i - 1>
								<option value="#myself#c.#theact#&offset_log=#loopoffset#&logaction=#attributes.logaction#&id=#attributes.id#"<cfif (session.offset_log + 1) EQ i> selected</cfif>>#i#</option>
							</cfloop>
							</select>
					</span>
				</cfif>
			<cfelse>
				<cfif qry_log.thetotal GT session.rowmaxpage>
					<span style="padding-left:10px;">
						<cfset thepage = ceiling(qry_log.thetotal / session.rowmaxpage)>
						Page: 
							<select id="thepagelist" onChange="loadcontent('#thediv#', $('##thepagelist :selected').val());">
							<cfloop from="1" to="#thepage#" index="i">
								<cfset loopoffset = i - 1>
								<option value="#myself#c.#theact#&offset_log=#loopoffset#&logaction=#attributes.logaction#&id=#attributes.id#"<cfif (session.offset_log + 1) EQ i> selected</cfif>>#i#</option>
							</cfloop>
							</select>
					</span>
				</cfif>
			</cfif>
			</div>
		</td>
	</tr>
</cfoutput>