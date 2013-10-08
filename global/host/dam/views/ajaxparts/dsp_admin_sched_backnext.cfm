<cfparam default="0" name="attributes.id">
<cfparam default="false" name="attributes.bot">
<cfoutput>
	<tr>
		<td colspan="6" nowrap="true">
			<div style="float:right;">
				<cfif session.offset_sched GTE 1>
					<!--- For Back --->
					<cfset newoffset = session.offset_sched - 1>
					<a href="##" onclick="loadcontent('admin_schedules','#myself#c.scheduler_list&offset_sched=#newoffset#');return false;"><<< #myFusebox.getApplicationData().defaults.trans("back")#</a>
				</cfif>
				<cfset showoffset = session.offset_sched * session.rowmaxpage_sched>
				<cfset shownextrecord = (session.offset_sched + 1) * session.rowmaxpage_sched>
				<cfif qry_schedules.recordcount GT session.rowmaxpage_sched>#showoffset# - #shownextrecord#</cfif>
				<cfif qry_schedules.recordcount GT session.rowmaxpage_sched AND NOT shownextrecord GTE qry_schedules.recordcount> | 
					<!--- For Next --->
					<cfset newoffset = session.offset_sched + 1>
					<a href="##" onclick="loadcontent('admin_schedules','#myself#c.scheduler_list&offset_sched=#newoffset#');return false;">#myFusebox.getApplicationData().defaults.trans("next")# >>></a>
				</cfif>
				<!--- Pages --->
				<cfif attributes.bot eq "true">
					<cfif qry_schedules.recordcount GT session.rowmaxpage>
						<span style="padding-left:10px;">
							<cfset thepage = ceiling(qry_schedules.recordcount / session.rowmaxpage)>
							Page: 
								<select class="theschedlist"  onChange="loadcontent('admin_schedules', $('.theschedlist :selected').val());">
								<cfloop from="1" to="#thepage#" index="i">
									<cfset loopoffset = i - 1>
									<option value="#myself#c.scheduler_list&offset_sched=#loopoffset#"<cfif (session.offset_sched + 1) EQ i> selected</cfif>>#i#</option>
								</cfloop>
								</select>
						</span>
					</cfif>
				<cfelse>
					<cfif qry_schedules.recordcount GT session.rowmaxpage>
						<span style="padding-left:10px;">
							<cfset thepage = ceiling(qry_schedules.recordcount / session.rowmaxpage)>
							Page: 
								<select id="theschedlist" onChange="loadcontent('admin_schedules', $('##theschedlist :selected').val());">
								<cfloop from="1" to="#thepage#" index="i">
									<cfset loopoffset = i - 1>
									<option value="#myself#c.scheduler_list&offset_sched=#loopoffset#"<cfif (session.offset_sched + 1) EQ i> selected</cfif>>#i#</option>
								</cfloop>
								</select>
						</span>
					</cfif>
				</cfif>
			</div>
		</td>
	</tr>
</cfoutput>